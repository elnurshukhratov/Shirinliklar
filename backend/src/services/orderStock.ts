import { OrderStatus, Prisma } from '@prisma/client';
import { AppError } from '../utils/errors';
import { releasePromo } from './promo';

/**
 * Buyurtmadagi mahsulotlar miqdorini omborga qaytaradi (o'chirilgan mahsulotlar o'tkazib yuboriladi)
 * va ishlatilgan promokod hisobini qaytaradi.
 */
export async function restoreStock(tx: Prisma.TransactionClient, orderId: string) {
  const items = await tx.orderItem.findMany({ where: { orderId, productId: { not: null } } });
  for (const item of items) {
    await tx.product.updateMany({
      where: { id: item.productId! },
      data: { stock: { increment: item.quantity } },
    });
  }
  await releasePromo(tx, orderId);
}

/**
 * Buyurtmani bekor qiladi va ombor miqdorini qaytaradi. Yakunlangan yoki allaqachon bekor
 * qilingan buyurtma qayta bekor qilinmaydi (miqdor ikki marta qaytib ketmasligi uchun).
 */
export async function cancelOrderWithRestock(
  tx: Prisma.TransactionClient,
  orderId: string,
  reason: string | null,
) {
  const claimed = await tx.order.updateMany({
    where: { id: orderId, status: { notIn: [OrderStatus.CANCELLED, OrderStatus.DELIVERED] } },
    data: { status: OrderStatus.CANCELLED, cancelReason: reason },
  });
  if (claimed.count === 0) throw AppError.conflict('ORDER_NOT_CANCELLABLE');

  await restoreStock(tx, orderId);
  return tx.order.findUniqueOrThrow({ where: { id: orderId }, include: { items: true } });
}
