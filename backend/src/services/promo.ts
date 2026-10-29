import { Prisma, PrismaClient, PromoCode } from '@prisma/client';
import { AppError } from '../utils/errors';

type Db = Prisma.TransactionClient | PrismaClient;

/** Kod katta-kichik harfga bog'liq emas: bazada doim katta harfda saqlanadi. */
export function normalizePromoCode(raw: string): string {
  return raw.trim().toUpperCase();
}

export function findPromo(db: Db, code: string) {
  return db.promoCode.findUnique({ where: { code: normalizePromoCode(code) } });
}

/** Promokod hozir ishlatilishi mumkinligini tekshiradi. */
export function assertPromoUsable(promo: PromoCode | null, now = new Date()): asserts promo is PromoCode {
  if (!promo || !promo.isActive) throw AppError.badRequest('PROMO_NOT_FOUND');
  if (promo.expiresAt && promo.expiresAt.getTime() <= now.getTime()) {
    throw AppError.badRequest('PROMO_EXPIRED');
  }
  if (promo.usageLimit != null && promo.usedCount >= promo.usageLimit) {
    throw AppError.badRequest('PROMO_LIMIT_REACHED');
  }
}

/** Chegirma summasi (so'm): jami summadan oshmaydi. Yetkazish narxiga chegirma qo'llanmaydi. */
export function promoDiscount(
  promo: Pick<PromoCode, 'discountPercent' | 'discountAmount'>,
  subtotal: number,
): number {
  let discount = 0;
  if (promo.discountPercent != null) {
    discount = Math.round((subtotal * promo.discountPercent) / 100);
  } else if (promo.discountAmount != null) {
    discount = Number(promo.discountAmount);
  }
  return Math.max(0, Math.min(discount, subtotal));
}

/** Foydalanishni band qiladi: chegara boshqa buyurtma bilan bir vaqtda ham oshib ketmaydi. */
export async function claimPromo(tx: Prisma.TransactionClient, promo: PromoCode) {
  const claimed = await tx.promoCode.updateMany({
    where: {
      id: promo.id,
      isActive: true,
      ...(promo.usageLimit != null ? { usedCount: { lt: promo.usageLimit } } : {}),
    },
    data: { usedCount: { increment: 1 } },
  });
  if (claimed.count !== 1) throw AppError.badRequest('PROMO_LIMIT_REACHED');
}

/** Buyurtma bekor bo'lganda promokod foydalanishini qaytaradi. */
export async function releasePromo(tx: Prisma.TransactionClient, orderId: string) {
  const order = await tx.order.findUnique({ where: { id: orderId }, select: { promoCodeId: true } });
  if (!order?.promoCodeId) return;
  await tx.promoCode.updateMany({
    where: { id: order.promoCodeId, usedCount: { gt: 0 } },
    data: { usedCount: { decrement: 1 } },
  });
}
