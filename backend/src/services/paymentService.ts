import { OrderStatus, PaymentMethod, PaymentStatus, PaymentTxnStatus } from '@prisma/client';
import { env } from '../config/env';
import { prisma } from '../lib/prisma';
import { getPaymentProvider } from '../payments';
import { AppError } from '../utils/errors';

/** Mijoz o'z buyurtmasi uchun onlayn to'lov sahifasi manzilini oladi (oldindan yoki olayotganda). */
export async function startPayment(orderId: string, userId: string) {
  const order = await prisma.order.findFirst({ where: { id: orderId, userId } });
  if (!order) throw AppError.notFound();

  const payable =
    order.paymentMethod === PaymentMethod.ONLINE &&
    order.paymentStatus === PaymentStatus.UNPAID &&
    order.status !== OrderStatus.CANCELLED &&
    order.status !== OrderStatus.DELIVERED;
  if (!payable) throw AppError.conflict('PAYMENT_NOT_ALLOWED');

  const provider = getPaymentProvider();
  const base = env.PUBLIC_BASE_URL?.replace(/\/+$/, '');
  const returnUrl = base ? `${base}/api/v1/payments/return?order=${encodeURIComponent(order.id)}` : undefined;

  return {
    provider: provider.name,
    url: provider.createPaymentUrl({ orderId: order.id, amount: Number(order.total), returnUrl }),
  };
}

/** Onlayn to'langan buyurtma pulini qaytaradi va to'lov holatini "qaytarilgan" qiladi. */
export async function refundOrder(orderId: string) {
  const order = await prisma.order.findUnique({ where: { id: orderId } });
  if (!order) throw AppError.notFound();
  if (order.paymentMethod !== PaymentMethod.ONLINE || order.paymentStatus !== PaymentStatus.PAID) {
    throw AppError.conflict('REFUND_NOT_ALLOWED');
  }

  const payment = await prisma.payment.findFirst({
    where: { orderId, status: PaymentTxnStatus.PAID },
    orderBy: { createdAt: 'desc' },
  });
  if (!payment || !payment.providerPaymentId) throw AppError.conflict('REFUND_NOT_ALLOWED');

  await getPaymentProvider(payment.provider).refund({ providerPaymentId: payment.providerPaymentId });

  await prisma.$transaction([
    prisma.payment.update({ where: { id: payment.id }, data: { status: PaymentTxnStatus.REFUNDED } }),
    prisma.order.update({ where: { id: orderId }, data: { paymentStatus: PaymentStatus.REFUNDED } }),
  ]);
}
