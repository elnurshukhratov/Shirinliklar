import { OrderStatus, Prisma } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { requireUser } from '../middleware/auth';
import { asyncHandler } from '../utils/asyncHandler';
import { AppError } from '../utils/errors';
import { pageArgs, paginationShape } from '../utils/pagination';
import { created, ok } from '../utils/response';
import { toOwnReviewDto, toPublicReviewDto } from '../utils/reviewDto';

export const reviewsRouter = Router();

const idParam = z.object({ id: z.string().min(1).max(100) });
const productParam = z.object({ productId: z.string().min(1).max(100) });

const rating = z.coerce.number().int().min(1).max(5);
const reviewText = z
  .string()
  .trim()
  .max(1000)
  .nullable()
  .transform((v) => (v ? v : null));

/** Mijoz shu mahsulotni olgan (buyurtma «topshirildi» holatida) bo'lsa true. */
async function hasReceived(userId: string, productId: string): Promise<boolean> {
  const item = await prisma.orderItem.findFirst({
    where: { productId, order: { userId, status: OrderStatus.DELIVERED } },
    select: { id: true },
  });
  return item !== null;
}

/** Mahsulot sharhlari: yashirilmaganlari, yangilari birinchi. Hamma uchun ochiq. */
reviewsRouter.get(
  '/product/:productId',
  asyncHandler(async (req, res) => {
    const { productId } = productParam.parse(req.params);
    const q = z.object({ ...paginationShape }).parse(req.query);
    const where: Prisma.ReviewWhereInput = { productId, isHidden: false };

    const [rows, total] = await prisma.$transaction([
      prisma.review.findMany({
        where,
        include: { user: { select: { firstName: true, lastName: true } } },
        orderBy: [{ createdAt: 'desc' }, { id: 'asc' }],
        ...pageArgs(q.page, q.limit),
      }),
      prisma.review.count({ where }),
    ]);
    return ok(res, rows.map(toPublicReviewDto), { page: q.page, limit: q.limit, total });
  }),
);

/** Mijozning shu mahsulotga sharhi va sharh qoldirish huquqi. */
reviewsRouter.get(
  '/product/:productId/mine',
  requireUser,
  asyncHandler(async (req, res) => {
    const { productId } = productParam.parse(req.params);
    const userId = req.user!.id;

    const [review, received] = await Promise.all([
      prisma.review.findUnique({ where: { userId_productId: { userId, productId } } }),
      hasReceived(userId, productId),
    ]);
    return ok(res, {
      canReview: received || review !== null,
      review: review ? toOwnReviewDto(review) : null,
    });
  }),
);

const createSchema = z.object({
  productId: z.string().min(1).max(100),
  rating,
  text: reviewText.optional().transform((v) => v ?? null),
});

reviewsRouter.post(
  '/',
  requireUser,
  asyncHandler(async (req, res) => {
    const data = createSchema.parse(req.body);
    const userId = req.user!.id;

    const product = await prisma.product.findUnique({ where: { id: data.productId }, select: { id: true } });
    if (!product) throw AppError.notFound();
    if (!(await hasReceived(userId, data.productId))) throw AppError.forbidden('REVIEW_NOT_ALLOWED');

    const existing = await prisma.review.findUnique({
      where: { userId_productId: { userId, productId: data.productId } },
      select: { id: true },
    });
    if (existing) throw AppError.conflict('REVIEW_EXISTS');

    const review = await prisma.review.create({
      data: { userId, productId: data.productId, rating: data.rating, text: data.text },
    });
    return created(res, toOwnReviewDto(review));
  }),
);

const updateSchema = z
  .object({
    rating: rating.optional(),
    text: reviewText.optional(),
  })
  .strict()
  .refine((v) => v.rating !== undefined || v.text !== undefined, 'EMPTY_UPDATE');

async function ownReview(id: string, userId: string) {
  const review = await prisma.review.findUnique({ where: { id } });
  if (!review) throw AppError.notFound();
  if (review.userId !== userId) throw AppError.forbidden();
  return review;
}

reviewsRouter.patch(
  '/:id',
  requireUser,
  asyncHandler(async (req, res) => {
    const { id } = idParam.parse(req.params);
    const data = updateSchema.parse(req.body);
    await ownReview(id, req.user!.id);

    const review = await prisma.review.update({
      where: { id },
      data: {
        ...(data.rating !== undefined ? { rating: data.rating } : {}),
        ...(data.text !== undefined ? { text: data.text } : {}),
      },
    });
    return ok(res, toOwnReviewDto(review));
  }),
);

reviewsRouter.delete(
  '/:id',
  requireUser,
  asyncHandler(async (req, res) => {
    const { id } = idParam.parse(req.params);
    await ownReview(id, req.user!.id);
    await prisma.review.delete({ where: { id } });
    return ok(res, { deleted: true });
  }),
);
