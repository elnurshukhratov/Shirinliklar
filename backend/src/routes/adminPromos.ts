import { Prisma } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { normalizePromoCode } from '../services/promo';
import { asyncHandler } from '../utils/asyncHandler';
import { AppError } from '../utils/errors';
import { pageArgs, paginationShape } from '../utils/pagination';
import { toPromoDto } from '../utils/promoDto';
import { created, ok } from '../utils/response';

export const adminPromosRouter = Router();

const idParam = z.object({ id: z.string().min(1).max(100) });

const codeSchema = z
  .string()
  .trim()
  .transform(normalizePromoCode)
  .pipe(z.string().regex(/^[A-Z0-9_-]{3,32}$/, 'INVALID_CODE'));

const percent = z.coerce.number().int().min(1).max(100);
const amount = z.coerce.number().positive().max(1_000_000_000);
const limit = z.coerce.number().int().min(1).max(1_000_000);
const futureDate = z.coerce.date().refine((d) => d.getTime() > Date.now(), 'EXPIRY_IN_PAST');

const createSchema = z
  .object({
    code: codeSchema,
    discountPercent: percent.optional(),
    discountAmount: amount.optional(),
    expiresAt: futureDate.optional(),
    usageLimit: limit.optional(),
    isActive: z.boolean().default(true),
  })
  .refine((v) => (v.discountPercent == null) !== (v.discountAmount == null), {
    message: 'DISCOUNT_REQUIRED',
  });

const updateSchema = z
  .object({
    discountPercent: percent.nullable().optional(),
    discountAmount: amount.nullable().optional(),
    expiresAt: z.union([z.null(), z.coerce.date()]).optional(),
    usageLimit: limit.nullable().optional(),
    isActive: z.boolean().optional(),
  })
  .refine(
    (v) => {
      const touched = v.discountPercent !== undefined || v.discountAmount !== undefined;
      if (!touched) return true;
      // Chegirma o'zgartirilsa, aniq bittasi (foiz yoki summa) qolishi kerak.
      return (v.discountPercent != null) !== (v.discountAmount != null);
    },
    { message: 'DISCOUNT_REQUIRED' },
  );

const listQuery = z.object({
  ...paginationShape,
  status: z.enum(['all', 'active', 'inactive']).default('all'),
});

adminPromosRouter.get(
  '/',
  asyncHandler(async (req, res) => {
    const q = listQuery.parse(req.query);
    const where: Prisma.PromoCodeWhereInput =
      q.status === 'active' ? { isActive: true } : q.status === 'inactive' ? { isActive: false } : {};

    const [rows, total] = await prisma.$transaction([
      prisma.promoCode.findMany({
        where,
        orderBy: [{ createdAt: 'desc' }, { id: 'asc' }],
        ...pageArgs(q.page, q.limit),
      }),
      prisma.promoCode.count({ where }),
    ]);
    return ok(res, rows.map(toPromoDto), { page: q.page, limit: q.limit, total });
  }),
);

function isUniqueViolation(e: unknown) {
  return e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002';
}

adminPromosRouter.post(
  '/',
  asyncHandler(async (req, res) => {
    const data = createSchema.parse(req.body);
    try {
      const promo = await prisma.promoCode.create({
        data: {
          code: data.code,
          discountPercent: data.discountPercent ?? null,
          discountAmount: data.discountAmount ?? null,
          expiresAt: data.expiresAt ?? null,
          usageLimit: data.usageLimit ?? null,
          isActive: data.isActive,
        },
      });
      return created(res, toPromoDto(promo));
    } catch (e) {
      if (isUniqueViolation(e)) throw AppError.conflict('PROMO_EXISTS');
      throw e;
    }
  }),
);

adminPromosRouter.patch(
  '/:id',
  asyncHandler(async (req, res) => {
    const { id } = idParam.parse(req.params);
    const data = updateSchema.parse(req.body);

    const exists = await prisma.promoCode.findUnique({ where: { id }, select: { id: true } });
    if (!exists) throw AppError.notFound();

    const touchedDiscount = data.discountPercent !== undefined || data.discountAmount !== undefined;
    const promo = await prisma.promoCode.update({
      where: { id },
      data: {
        ...(touchedDiscount
          ? { discountPercent: data.discountPercent ?? null, discountAmount: data.discountAmount ?? null }
          : {}),
        ...(data.expiresAt !== undefined ? { expiresAt: data.expiresAt } : {}),
        ...(data.usageLimit !== undefined ? { usageLimit: data.usageLimit } : {}),
        ...(data.isActive !== undefined ? { isActive: data.isActive } : {}),
      },
    });
    return ok(res, toPromoDto(promo));
  }),
);

/** Buyurtmalardagi yozuv saqlanadi (promokod havolasi bo'shaydi), faqat kodning o'zi o'chadi. */
adminPromosRouter.delete(
  '/:id',
  asyncHandler(async (req, res) => {
    const { id } = idParam.parse(req.params);
    const removed = await prisma.promoCode.deleteMany({ where: { id } });
    if (removed.count === 0) throw AppError.notFound();
    return ok(res, { deleted: true });
  }),
);
