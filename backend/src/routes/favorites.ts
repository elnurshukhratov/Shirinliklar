import { Prisma } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { requireUser } from '../middleware/auth';
import { asyncHandler } from '../utils/asyncHandler';
import { toProductDto } from '../utils/dto';
import { AppError } from '../utils/errors';
import { pageArgs, paginationShape } from '../utils/pagination';
import { ratingOf, ratingsFor } from '../utils/ratings';
import { ok } from '../utils/response';

export const favoritesRouter = Router();
favoritesRouter.use(requireUser);

const param = z.object({ productId: z.string().min(1).max(100) });

/** Mijozga ko'rinadigan mahsulot: faol va (toifasi bo'lsa) toifasi ham faol. */
const visibleProduct: Prisma.ProductWhereInput = {
  isActive: true,
  OR: [{ categoryId: null }, { category: { isActive: true } }],
};

const productInclude = {
  category: true,
  variants: { where: { isActive: true }, orderBy: [{ sortOrder: 'asc' }, { id: 'asc' }] },
} satisfies Prisma.ProductInclude;

/** Sevimli mahsulotlar ro'yxati: oxirgi qo'shilgani birinchi. */
favoritesRouter.get(
  '/',
  asyncHandler(async (req, res) => {
    const q = z.object({ ...paginationShape }).parse(req.query);
    const where: Prisma.FavoriteWhereInput = { userId: req.user!.id, product: visibleProduct };

    const [rows, total] = await prisma.$transaction([
      prisma.favorite.findMany({
        where,
        include: { product: { include: productInclude } },
        orderBy: [{ createdAt: 'desc' }, { productId: 'asc' }],
        ...pageArgs(q.page, q.limit),
      }),
      prisma.favorite.count({ where }),
    ]);

    const ratings = await ratingsFor(rows.map((r) => r.productId));
    const data = rows.map((r) => ({ ...toProductDto(r.product), ...ratingOf(ratings, r.productId) }));
    return ok(res, data, { page: q.page, limit: q.limit, total });
  }),
);

/** Yurakchalarni belgilash uchun: sevimli mahsulotlar id'lari. */
favoritesRouter.get(
  '/ids',
  asyncHandler(async (req, res) => {
    const rows = await prisma.favorite.findMany({
      where: { userId: req.user!.id, product: visibleProduct },
      select: { productId: true },
    });
    return ok(res, rows.map((r) => r.productId));
  }),
);

favoritesRouter.put(
  '/:productId',
  asyncHandler(async (req, res) => {
    const { productId } = param.parse(req.params);
    const userId = req.user!.id;

    const product = await prisma.product.findFirst({
      where: { AND: [visibleProduct, { id: productId }] },
      select: { id: true },
    });
    if (!product) throw AppError.notFound();

    await prisma.favorite.upsert({
      where: { userId_productId: { userId, productId } },
      create: { userId, productId },
      update: {},
    });
    return ok(res, { favorite: true });
  }),
);

favoritesRouter.delete(
  '/:productId',
  asyncHandler(async (req, res) => {
    const { productId } = param.parse(req.params);
    await prisma.favorite.deleteMany({ where: { userId: req.user!.id, productId } });
    return ok(res, { favorite: false });
  }),
);
