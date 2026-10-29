import { Prisma } from '@prisma/client';

/** Nomi bo'yicha (uch tilda) katta-kichik harfga qaramay qidirish. */
export function searchWhere(search?: string): Prisma.ProductWhereInput | undefined {
  if (!search) return undefined;
  const c = { contains: search, mode: 'insensitive' as const };
  return { OR: [{ nameUz: c }, { nameEn: c }, { nameRu: c }] };
}