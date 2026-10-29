import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../utils/asyncHandler';
import { toCategoryDto } from '../utils/dto';
import { flatAll, flatPartial, langs } from '../utils/i18n';
import { created, ok } from '../utils/response';

export const adminCategoriesRouter = Router();

const createSchema = z
  .object({
    name: langs(z.string().trim().min(1).max(80)),
    sortOrder: z.number().int().min(0).max(10000).default(0),
    isActive: z.boolean().default(true),
  })
  .strict();

const updateSchema = z
  .object({
    name: langs(z.string().trim().min(1).max(80).optional()).optional(),
    sortOrder: z.number().int().min(0).max(10000).optional(),
    isActive: z.boolean().optional(),
  })
  .strict();

adminCategoriesRouter.get(
  '/',
  asyncHandler(async (_req, res) => {
    const rows = await prisma.category.findMany({
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
      include: { _count: { select: { products: true } } },
    });
    return ok(res, rows.map((c) => toCategoryDto(c, c._count.products)));
  }),
);

adminCategoriesRouter.post(
  '/',
  asyncHandler(async (req, res) => {
    const d = createSchema.parse(req.body);
    const row = await prisma.category.create({
      data: { ...flatAll('name', d.name), sortOrder: d.sortOrder, isActive: d.isActive },
    });
    return created(res, toCategoryDto(row, 0));
  }),
);

adminCategoriesRouter.patch(
  '/:id',
  asyncHandler(async (req, res) => {
    const d = updateSchema.parse(req.body);
    const row = await prisma.category.update({
      where: { id: req.params.id },
      data: { ...flatPartial('name', d.name), sortOrder: d.sortOrder, isActive: d.isActive },
      include: { _count: { select: { products: true } } },
    });
    return ok(res, toCategoryDto(row, row._count.products));
  }),
);

/** Toifa o'chirilsa, undagi mahsulotlar toifasiz qoladi. */
adminCategoriesRouter.delete(
  '/:id',
  asyncHandler(async (req, res) => {
    await prisma.category.delete({ where: { id: req.params.id } });
    return ok(res, { deleted: true });
  }),
);