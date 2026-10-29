import { Prisma } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../utils/asyncHandler';
import { AppError } from '../utils/errors';
import { pageArgs, paginationShape } from '../utils/pagination';
import { ok } from '../utils/response';
import { adminReviewInclude, toAdminReviewDto } from '../utils/reviewDto';

export const adminReviewsRouter = Router();

const idParam = z.object({ id: z.string().min(1).max(100) });

const listQuery = z.object({
  ...paginationShape,
  visibility: z.enum(['all', 'visible', 'hidden']).default('all'),
  productId: z.string().min(1).max(100).optional(),
});

adminReviewsRouter.get(
  '/',
  asyncHandler(async (req, res) => {
    const q = listQuery.parse(req.query);
    const where: Prisma.ReviewWhereInput = {
      ...(q.visibility === 'hidden' ? { isHidden: true } : {}),
      ...(q.visibility === 'visible' ? { isHidden: false } : {}),
      ...(q.productId ? { productId: q.productId } : {}),
    };

    const [rows, total] = await prisma.$transaction([
      prisma.review.findMany({
        where,
        include: adminReviewInclude,
        orderBy: [{ createdAt: 'desc' }, { id: 'asc' }],
        ...pageArgs(q.page, q.limit),
      }),
      prisma.review.count({ where }),
    ]);
    return ok(res, rows.map(toAdminReviewDto), { page: q.page, limit: q.limit, total });
  }),
);

async function update(id: string, data: Prisma.ReviewUpdateInput) {
  const exists = await prisma.review.findUnique({ where: { id }, select: { id: true } });
  if (!exists) throw AppError.notFound();
  return prisma.review.update({ where: { id }, data, include: adminReviewInclude });
}

/** Nomaqbul izohni yashiradi: mahsulot sahifasida va o'rtacha bahoda hisobga olinmaydi. */
adminReviewsRouter.post(
  '/:id/hide',
  asyncHandler(async (req, res) => {
    const { id } = idParam.parse(req.params);
    return ok(res, toAdminReviewDto(await update(id, { isHidden: true })));
  }),
);

adminReviewsRouter.post(
  '/:id/show',
  asyncHandler(async (req, res) => {
    const { id } = idParam.parse(req.params);
    return ok(res, toAdminReviewDto(await update(id, { isHidden: false })));
  }),
);

const replySchema = z.object({ reply: z.string().trim().min(1).max(1000) });

adminReviewsRouter.put(
  '/:id/reply',
  asyncHandler(async (req, res) => {
    const { id } = idParam.parse(req.params);
    const { reply } = replySchema.parse(req.body);
    return ok(res, toAdminReviewDto(await update(id, { adminReply: reply })));
  }),
);

adminReviewsRouter.delete(
  '/:id/reply',
  asyncHandler(async (req, res) => {
    const { id } = idParam.parse(req.params);
    return ok(res, toAdminReviewDto(await update(id, { adminReply: null })));
  }),
);
