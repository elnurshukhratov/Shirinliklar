import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { requireUser } from '../middleware/auth';
import { asyncHandler } from '../utils/asyncHandler';
import { AppError } from '../utils/errors';
import { ok } from '../utils/response';

export const stockAlertsRouter = Router();
stockAlertsRouter.use(requireUser);

const param = z.object({ productId: z.string().min(1).max(100) });

stockAlertsRouter.get(
  '/:productId',
  asyncHandler(async (req, res) => {
    const { productId } = param.parse(req.params);
    const sub = await prisma.stockSubscription.findUnique({
      where: { userId_productId: { userId: req.user!.id, productId } },
    });
    return ok(res, { subscribed: sub !== null });
  }),
);

/** Faqat tugagan (miqdori 0) va ko'rinadigan mahsulotga obuna bo'linadi. */
stockAlertsRouter.put(
  '/:productId',
  asyncHandler(async (req, res) => {
    const { productId } = param.parse(req.params);
    const userId = req.user!.id;

    const product = await prisma.product.findFirst({
      where: { id: productId, isActive: true, OR: [{ categoryId: null }, { category: { isActive: true } }] },
      select: { id: true, stock: true },
    });
    if (!product) throw AppError.notFound();
    if (product.stock > 0) throw AppError.conflict('PRODUCT_IN_STOCK');

    await prisma.stockSubscription.upsert({
      where: { userId_productId: { userId, productId } },
      create: { userId, productId },
      update: {},
    });
    return ok(res, { subscribed: true });
  }),
);

stockAlertsRouter.delete(
  '/:productId',
  asyncHandler(async (req, res) => {
    const { productId } = param.parse(req.params);
    await prisma.stockSubscription.deleteMany({ where: { userId: req.user!.id, productId } });
    return ok(res, { subscribed: false });
  }),
);
