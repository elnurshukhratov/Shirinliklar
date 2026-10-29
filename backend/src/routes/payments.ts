import { PaymentStatus, PaymentTxnStatus } from '@prisma/client';
import { Request, Response, Router } from 'express';
import { z } from 'zod';
import { ClickCallback, clickConfig, verifyClickSign } from '../payments/click';
import { prisma } from '../lib/prisma';
import { requireUser } from '../middleware/auth';
import { startPayment } from '../services/paymentService';
import { asyncHandler } from '../utils/asyncHandler';
import { ok } from '../utils/response';

export const paymentsRouter = Router();

// ---- Mijoz: to'lovni boshlash ----

paymentsRouter.post(
  '/orders/:id/start',
  requireUser,
  asyncHandler(async (req, res) => {
    const { id } = z.object({ id: z.string().min(1).max(100) }).parse(req.params);
    return ok(res, await startPayment(id, req.user!.id));
  }),
);

// ---- To'lovdan keyin brauzerda ko'rinadigan sahifa (ilovaga qaytish) ----

paymentsRouter.get('/return', (_req, res) => {
  res
    .type('html')
    .send(
      `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">` +
        `<title>Shirinliklar</title><style>body{font-family:sans-serif;background:#FBF6EF;color:#2B211A;` +
        `display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;padding:24px;text-align:center}` +
        `p{margin:8px 0;line-height:1.4}</style></head><body><div>` +
        `<p><b>Ilovaga qayting — to'lov holati avtomatik tekshiriladi.</b></p>` +
        `<p>Return to the app — the payment status is checked automatically.</p>` +
        `<p>Вернитесь в приложение — статус оплаты проверится автоматически.</p>` +
        `</div></body></html>`,
    );
});

// ---- Click callback'lari (Prepare / Complete) ----

const clickBody = z.object({
  click_trans_id: z.coerce.string().min(1),
  service_id: z.coerce.string().min(1),
  click_paydoc_id: z.coerce.string().optional(),
  merchant_trans_id: z.coerce.string().min(1),
  merchant_prepare_id: z.coerce.string().optional(),
  amount: z.coerce.string().min(1),
  action: z.coerce.number().int(),
  error: z.coerce.number().int().default(0),
  sign_time: z.coerce.string().min(1),
  sign_string: z.coerce.string().min(1),
});

const E = {
  OK: [0, 'Success'],
  SIGN: [-1, 'SIGN CHECK FAILED!'],
  AMOUNT: [-2, 'Incorrect parameter amount'],
  ACTION: [-3, 'Action not found'],
  PAID: [-4, 'Already paid'],
  NO_ORDER: [-5, 'Order not found'],
  NO_TXN: [-6, 'Transaction does not exist'],
  REQUEST: [-8, 'Error in request from click'],
  CANCELLED: [-9, 'Transaction cancelled'],
} as const;

type ErrorPair = (typeof E)[keyof typeof E];

const sameAmount = (a: string, b: number) => Math.abs(Number(a) - b) < 0.01;

function reply(res: Response, b: { click_trans_id: string; merchant_trans_id: string }, err: ErrorPair, extra: object = {}) {
  return res.json({
    click_trans_id: b.click_trans_id,
    merchant_trans_id: b.merchant_trans_id,
    ...extra,
    error: err[0],
    error_note: err[1],
  });
}

/** Imzo, xizmat ID va action ni tekshiradi; xato bo'lsa javob yuboradi va null qaytaradi. */
function parseClick(req: Request, res: Response, expectedAction: 0 | 1) {
  const cfg = clickConfig();
  if (!cfg) {
    res.status(503).json({ error: E.REQUEST[0], error_note: 'Payments not configured' });
    return null;
  }
  const parsed = clickBody.safeParse(req.body);
  if (!parsed.success) {
    res.json({ error: E.REQUEST[0], error_note: E.REQUEST[1] });
    return null;
  }
  const b = parsed.data;
  if (b.service_id !== cfg.serviceId || !verifyClickSign(cfg, b as ClickCallback)) {
    reply(res, b, E.SIGN);
    return null;
  }
  if (b.action !== expectedAction) {
    reply(res, b, E.ACTION);
    return null;
  }
  return b;
}

paymentsRouter.post(
  '/click/prepare',
  asyncHandler(async (req, res) => {
    const b = parseClick(req, res, 0);
    if (!b) return;

    const order = await prisma.order.findUnique({ where: { id: b.merchant_trans_id } });
    if (!order) return reply(res, b, E.NO_ORDER);
    if (!sameAmount(b.amount, Number(order.total))) return reply(res, b, E.AMOUNT);
    if (order.paymentStatus === PaymentStatus.PAID) return reply(res, b, E.PAID);
    if (order.paymentStatus === PaymentStatus.REFUNDED || order.status === 'CANCELLED') {
      return reply(res, b, E.CANCELLED);
    }

    // Takroriy so'rovda xuddi shu tranzaksiya qaytariladi (idempotent).
    const existing = await prisma.payment.findUnique({
      where: { provider_providerTxnId: { provider: 'click', providerTxnId: b.click_trans_id } },
    });
    if (existing) {
      if (existing.status === PaymentTxnStatus.PAID) return reply(res, b, E.PAID);
      if (existing.status === PaymentTxnStatus.FAILED) return reply(res, b, E.CANCELLED);
      return reply(res, b, E.OK, { merchant_prepare_id: existing.id });
    }

    const payment = await prisma.payment.create({
      data: {
        orderId: order.id,
        provider: 'click',
        amount: order.total,
        status: PaymentTxnStatus.PREPARED,
        providerTxnId: b.click_trans_id,
        providerPaymentId: b.click_paydoc_id ?? null,
      },
    });
    return reply(res, b, E.OK, { merchant_prepare_id: payment.id });
  }),
);

paymentsRouter.post(
  '/click/complete',
  asyncHandler(async (req, res) => {
    const b = parseClick(req, res, 1);
    if (!b) return;

    const payment = b.merchant_prepare_id
      ? await prisma.payment.findFirst({
          where: { id: b.merchant_prepare_id, provider: 'click', orderId: b.merchant_trans_id },
        })
      : null;
    if (!payment) return reply(res, b, E.NO_TXN);
    if (!sameAmount(b.amount, Number(payment.amount))) return reply(res, b, E.AMOUNT);
    if (payment.status === PaymentTxnStatus.PAID) return reply(res, b, E.PAID, { merchant_confirm_id: payment.id });
    if (payment.status !== PaymentTxnStatus.PREPARED) return reply(res, b, E.CANCELLED);

    // Click o'zi xato bildirsa to'lov bekor qilinadi.
    if (b.error < 0) {
      await prisma.payment.updateMany({
        where: { id: payment.id, status: PaymentTxnStatus.PREPARED },
        data: { status: PaymentTxnStatus.FAILED },
      });
      return reply(res, b, E.CANCELLED);
    }

    await prisma.$transaction(async (tx) => {
      const claimed = await tx.payment.updateMany({
        where: { id: payment.id, status: PaymentTxnStatus.PREPARED },
        data: { status: PaymentTxnStatus.PAID },
      });
      if (claimed.count !== 1) return;
      await tx.order.updateMany({
        where: { id: payment.orderId, paymentStatus: PaymentStatus.UNPAID },
        data: { paymentStatus: PaymentStatus.PAID },
      });
    });
    return reply(res, b, E.OK, { merchant_confirm_id: payment.id });
  }),
);
