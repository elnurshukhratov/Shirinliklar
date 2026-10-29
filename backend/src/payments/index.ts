import { env } from '../config/env';
import { AppError } from '../utils/errors';
import { ClickProvider, clickConfig } from './click';
import { PaymentProvider } from './types';

/** Tanlangan to'lov tizimi adapteri. Kalitlar sozlanmagan bo'lsa 503 qaytadi. */
export function getPaymentProvider(name: string = env.PAYMENT_PROVIDER): PaymentProvider {
  switch (name) {
    case 'click': {
      const cfg = clickConfig();
      if (!cfg) throw new AppError(503, 'SERVICE_UNAVAILABLE', 'PAYMENT_UNAVAILABLE');
      return new ClickProvider(cfg);
    }
    default:
      throw new AppError(503, 'SERVICE_UNAVAILABLE', 'PAYMENT_UNAVAILABLE');
  }
}
