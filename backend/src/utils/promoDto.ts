import { PromoCode } from '@prisma/client';

export type PromoStatus = 'ACTIVE' | 'INACTIVE' | 'EXPIRED' | 'EXHAUSTED';

export function promoStatus(p: PromoCode, now = new Date()): PromoStatus {
  if (!p.isActive) return 'INACTIVE';
  if (p.expiresAt && p.expiresAt.getTime() <= now.getTime()) return 'EXPIRED';
  if (p.usageLimit != null && p.usedCount >= p.usageLimit) return 'EXHAUSTED';
  return 'ACTIVE';
}

export function toPromoDto(p: PromoCode) {
  return {
    id: p.id,
    code: p.code,
    discountPercent: p.discountPercent,
    discountAmount: p.discountAmount == null ? null : Number(p.discountAmount),
    expiresAt: p.expiresAt,
    usageLimit: p.usageLimit,
    usedCount: p.usedCount,
    isActive: p.isActive,
    status: promoStatus(p),
    createdAt: p.createdAt,
  };
}
