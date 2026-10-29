import { createHash, timingSafeEqual } from 'node:crypto';
import { env } from '../config/env';
import { AppError } from '../utils/errors';
import { PaymentProvider } from './types';

export interface ClickConfig {
  serviceId: string;
  merchantId: string;
  merchantUserId: string;
  secretKey: string;
}

/** Sozlanmagan bo'lsa null qaytaradi (kalitlar faqat env orqali beriladi). */
export function clickConfig(): ClickConfig | null {
  const { CLICK_SERVICE_ID, CLICK_MERCHANT_ID, CLICK_MERCHANT_USER_ID, CLICK_SECRET_KEY } = env;
  if (!CLICK_SERVICE_ID || !CLICK_MERCHANT_ID || !CLICK_MERCHANT_USER_ID || !CLICK_SECRET_KEY) return null;
  return {
    serviceId: CLICK_SERVICE_ID,
    merchantId: CLICK_MERCHANT_ID,
    merchantUserId: CLICK_MERCHANT_USER_ID,
    secretKey: CLICK_SECRET_KEY,
  };
}

const md5 = (s: string) => createHash('md5').update(s).digest('hex');
const sha1 = (s: string) => createHash('sha1').update(s).digest('hex');

export interface ClickCallback {
  click_trans_id: string;
  service_id: string;
  merchant_trans_id: string;
  merchant_prepare_id?: string;
  amount: string;
  action: number;
  sign_time: string;
  sign_string: string;
}

/** Click imzosini tekshiradi: prepare (action=0) va complete (action=1) uchun. */
export function verifyClickSign(cfg: ClickConfig, b: ClickCallback): boolean {
  const parts =
    b.action === 1
      ? [b.click_trans_id, b.service_id, cfg.secretKey, b.merchant_trans_id, b.merchant_prepare_id ?? '', b.amount, b.action, b.sign_time]
      : [b.click_trans_id, b.service_id, cfg.secretKey, b.merchant_trans_id, b.amount, b.action, b.sign_time];
  const expected = Buffer.from(md5(parts.join('')));
  const actual = Buffer.from(String(b.sign_string).toLowerCase());
  return expected.length === actual.length && timingSafeEqual(expected, actual);
}

export class ClickProvider implements PaymentProvider {
  readonly name = 'click';

  constructor(private readonly cfg: ClickConfig) {}

  createPaymentUrl({ orderId, amount, returnUrl }: { orderId: string; amount: number; returnUrl?: string }) {
    const q = new URLSearchParams({
      service_id: this.cfg.serviceId,
      merchant_id: this.cfg.merchantId,
      amount: String(Number(amount.toFixed(2))),
      transaction_param: orderId,
    });
    if (returnUrl) q.set('return_url', returnUrl);
    return `https://my.click.uz/services/pay?${q.toString()}`;
  }

  async refund({ providerPaymentId }: { providerPaymentId: string }) {
    const timestamp = Math.floor(Date.now() / 1000);
    const auth = `${this.cfg.merchantUserId}:${sha1(`${timestamp}${this.cfg.secretKey}`)}:${timestamp}`;
    const url = `https://api.click.uz/v2/merchant/payment/reversal/${this.cfg.serviceId}/${encodeURIComponent(providerPaymentId)}`;

    let body: { error_code?: number } | null = null;
    try {
      const res = await fetch(url, {
        method: 'DELETE',
        headers: { Accept: 'application/json', 'Content-Type': 'application/json', Auth: auth },
        signal: AbortSignal.timeout(15_000),
      });
      body = (await res.json()) as { error_code?: number };
    } catch {
      throw new AppError(502, 'PAYMENT_PROVIDER_ERROR', 'PAYMENT_PROVIDER_ERROR');
    }
    if (!body || body.error_code !== 0) throw new AppError(502, 'PAYMENT_PROVIDER_ERROR', 'PAYMENT_PROVIDER_ERROR');
  }
}
