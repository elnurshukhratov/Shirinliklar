import { Prisma } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../utils/asyncHandler';
import { toCategoryDto, toProductDto } from '../utils/dto';
import { AppError } from '../utils/errors';
import { pageArgs, paginationShape } from '../utils/pagination';
import { searchWhere } from '../utils/productQuery';
import { ratingOf, ratingsFor } from '../utils/ratings';
import { ok } from '../utils/response';

export const catalogRouter = Router();

const visibleProduct: Prisma.ProductWhereInput = {
  isActive: true,
  OR: [{ categoryId: null }, { category: { isActive: true } }],
};

const include = {
  category: true,
  variants: { where: { isActive: true }, orderBy: [{ sortOrder: 'asc' }, { id: 'asc' }] },
} satisfies Prisma.ProductInclude;

catalogRouter.get(
  '/categories',
  asyncHandler(async (_req, res) => {
    const rows = await prisma.category.findMany({
      where: { isActive: true },
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    });
    return ok(res, rows.map((c) => toCategoryDto(c)));
  }),
);

const listQuery = z.object({
  search: z.string().trim().max(100).optional(),
  categoryId: z.string().min(1).optional(),
  sort: z.enum(['newest', 'price_asc', 'price_desc']).default('newest'),
  ...paginationShape,
});

catalogRouter.get(
  '/products',
  asyncHandler(async (req, res) => {
    const q = listQuery.parse(req.query);

    const and: Prisma.ProductWhereInput[] = [visibleProduct];
    if (q.categoryId) and.push({ categoryId: q.categoryId });
    const search = searchWhere(q.search);
    if (search) and.push(search);
    const where: Prisma.ProductWhereInput = { AND: and };

    const orderBy: Prisma.ProductOrderByWithRelationInput =
      q.sort === 'price_asc'
        ? { price: 'asc' }
        : q.sort === 'price_desc'
          ? { price: 'desc' }
          : { createdAt: 'desc' };

    const [rows, total] = await prisma.$transaction([
      prisma.product.findMany({ where, include, orderBy: [orderBy, { id: 'asc' }], ...pageArgs(q.page, q.limit) }),
      prisma.product.count({ where }),
    ]);

    const ratings = await ratingsFor(rows.map((r) => r.id));
    const data = rows.map((r) => ({ ...toProductDto(r), ...ratingOf(ratings, r.id) }));

    return ok(res, data, { page: q.page, limit: q.limit, total });
  }),
);

catalogRouter.get(
  '/products/:id',
  asyncHandler(async (req, res) => {
    const product = await prisma.product.findFirst({
      where: { AND: [visibleProduct, { id: req.params.id }] },
      include,
    });
    if (!product) throw AppError.notFound();
    const ratings = await ratingsFor([product.id]);
    return ok(res, { ...toProductDto(product), ...ratingOf(ratings, product.id) });
  }),
);