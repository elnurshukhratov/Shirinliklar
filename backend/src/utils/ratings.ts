import { prisma } from '../lib/prisma';

export interface RatingSummary {
  averageRating: number;
  reviewsCount: number;
}

const empty: RatingSummary = { averageRating: 0, reviewsCount: 0 };

/** Berilgan mahsulotlar uchun yashirilmagan sharhlar bo'yicha o'rtacha baho va soni. */
export async function ratingsFor(productIds: string[]): Promise<Map<string, RatingSummary>> {
  const map = new Map<string, RatingSummary>();
  if (productIds.length === 0) return map;

  const rows = await prisma.review.groupBy({
    by: ['productId'],
    where: { productId: { in: productIds }, isHidden: false },
    _avg: { rating: true },
    _count: { rating: true },
  });

  for (const r of rows) {
    map.set(r.productId, {
      averageRating: Math.round((r._avg.rating ?? 0) * 10) / 10,
      reviewsCount: r._count.rating,
    });
  }
  return map;
}

export function ratingOf(map: Map<string, RatingSummary>, productId: string): RatingSummary {
  return map.get(productId) ?? empty;
}
