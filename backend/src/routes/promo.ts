import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { requireUser } from '../middleware/auth';
import { assertPromoUsable, findPromo, promoDiscount } from '../services/promo';
import { asyncHandler } from '../utils/asyncHandler';
import { ok } from '../utils/response';

export const promoRouter = Router();
promoRouter.use(requireUser);

const validateBody = z.object({
  code: z.string().trim().min(1).max(40),
  subtotal: z.coerce.number().min(0).max(1_000_000_000),
});

/**
 * Savatda promokodni tekshiradi va chegirmani ko'rsatadi. Bu faqat oldindan ko'rish:
 * yakuniy chegirma buyurtma yaratilganda serverda qayta hisoblanadi.
 */
promoRouter.post(
  '/validate',
  asyncHandler(async (req, res) => {
    const { code, subtotal } = validateBody.parse(req.body);
    const promo = await findPromo(prisma, code);
    assertPromoUsable(promo);
    return ok(res, {
      code: promo.code,
      discountPercent: promo.discountPercent,
      discountAmount: promo.discountAmount == null ? null : Number(promo.discountAmount),
      discount: promoDiscount(promo, subtotal),
      expiresAt: promo.expiresAt,
    });
  }),
);
