import { Product, Review, User } from '@prisma/client';
import { pack } from './i18n';

export function authorName(u: Pick<User, 'firstName' | 'lastName'>): string | null {
  const first = u.firstName?.trim();
  const last = u.lastName?.trim();
  if (!first && !last) return null;
  return [first, last ? `${last[0].toUpperCase()}.` : null].filter(Boolean).join(' ');
}

/** Mahsulot sahifasida hamma ko'radigan sharh. */
export function toPublicReviewDto(r: Review & { user: Pick<User, 'firstName' | 'lastName'> }) {
  return {
    id: r.id,
    rating: r.rating,
    text: r.text,
    authorName: authorName(r.user),
    adminReply: r.adminReply,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
  };
}

/** Mijozning o'z sharhi (yashirilgan bo'lsa ham ko'radi). */
export function toOwnReviewDto(r: Review) {
  return {
    id: r.id,
    productId: r.productId,
    rating: r.rating,
    text: r.text,
    isHidden: r.isHidden,
    adminReply: r.adminReply,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
  };
}

export type AdminReviewRow = Review & {
  user: Pick<User, 'id' | 'firstName' | 'lastName' | 'email'>;
  product: Pick<Product, 'id' | 'nameUz' | 'nameEn' | 'nameRu'>;
};

export const adminReviewInclude = {
  user: { select: { id: true, firstName: true, lastName: true, email: true } },
  product: { select: { id: true, nameUz: true, nameEn: true, nameRu: true } },
} as const;

export function toAdminReviewDto(r: AdminReviewRow) {
  return {
    id: r.id,
    rating: r.rating,
    text: r.text,
    isHidden: r.isHidden,
    adminReply: r.adminReply,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
    product: { id: r.product.id, name: pack(r.product, 'name') },
    user: {
      id: r.user.id,
      name: [r.user.firstName, r.user.lastName].filter(Boolean).join(' ') || null,
      email: r.user.email,
    },
  };
}
