import { Prisma, VariantGroup } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { deleteImagesByUrl, isOwnImageUrl } from '../lib/storage';
import { notifyRestocked } from '../services/notifications';
import { asyncHandler } from '../utils/asyncHandler';
import { toProductDto } from '../utils/dto';
import { AppError } from '../utils/errors';
import { flatAll, flatPartial, langs } from '../utils/i18n';
import { pageArgs, paginationShape } from '../utils/pagination';
import { searchWhere } from '../utils/productQuery';
import { created, ok } from '../utils/response';

export const adminProductsRouter = Router();

const include = {
  category: true,
  variants: { orderBy: [{ sortOrder: 'asc' }, { id: 'asc' }] },
} satisfies Prisma.ProductInclude;

const imagesSchema = z
  .array(z.string().max(500).refine(isOwnImageUrl, 'INVALID_IMAGE_URL'))
  .max(8);

const variantSchema = z
  .object({
    id: z.string().min(1).optional(),
    group: z.nativeEnum(VariantGroup),
    name: langs(z.string().trim().min(1).max(80)),
    priceDelta: z.number().finite().min(-1_000_000_000).max(1_000_000_000).default(0),
    sortOrder: z.number().int().min(0).max(1000).default(0),
    isActive: z.boolean().default(true),
  })
  .strict();

const text = (max: number) => z.string().trim().max(max);

const createSchema = z
  .object({
    name: langs(z.string().trim().min(1).max(150)),
    description: langs(text(4000).default('')).default({}),
    ingredients: langs(text(2000).default('')).default({}),
    allergens: langs(text(500).default('')).default({}),
    price: z.number().finite().min(0).max(1_000_000_000),
    stock: z.number().int().min(0).max(100_000).default(0),
    images: imagesSchema.default([]),
    isActive: z.boolean().default(true),
    categoryId: z.string().min(1).nullable().optional(),
    variants: z.array(variantSchema).max(30).default([]),
  })
  .strict();

const updateSchema = z
  .object({
    name: langs(z.string().trim().min(1).max(150).optional()).optional(),
    description: langs(text(4000).optional()).optional(),
    ingredients: langs(text(2000).optional()).optional(),
    allergens: langs(text(500).optional()).optional(),
    price: z.number().finite().min(0).max(1_000_000_000).optional(),
    stock: z.number().int().min(0).max(100_000).optional(),
    images: imagesSchema.optional(),
    isActive: z.boolean().optional(),
    categoryId: z.string().min(1).nullable().optional(),
    variants: z.array(variantSchema).max(30).optional(),
  })
  .strict();

const listQuery = z.object({
  search: z.string().trim().max(100).optional(),
  categoryId: z.string().min(1).optional(),
  isActive: z.enum(['true', 'false']).optional(),
  ...paginationShape,
});

async function assertCategory(categoryId?: string | null) {
  if (!categoryId) return;
  const exists = await prisma.category.findUnique({ where: { id: categoryId }, select: { id: true } });
  if (!exists) throw AppError.badRequest('CATEGORY_NOT_FOUND');
}

adminProductsRouter.get(
  '/',
  asyncHandler(async (req, res) => {
    const q = listQuery.parse(req.query);

    const and: Prisma.ProductWhereInput[] = [];
    if (q.categoryId) and.push({ categoryId: q.categoryId });
    if (q.isActive) and.push({ isActive: q.isActive === 'true' });
    const search = searchWhere(q.search);
    if (search) and.push(search);
    const where: Prisma.ProductWhereInput = and.length ? { AND: and } : {};

    const [rows, total] = await prisma.$transaction([
      prisma.product.findMany({
        where,
        include,
        orderBy: [{ createdAt: 'desc' }, { id: 'asc' }],
        ...pageArgs(q.page, q.limit),
      }),
      prisma.product.count({ where }),
    ]);

    return ok(res, rows.map(toProductDto), { page: q.page, limit: q.limit, total });
  }),
);

adminProductsRouter.get(
  '/:id',
  asyncHandler(async (req, res) => {
    const product = await prisma.product.findUnique({ where: { id: req.params.id }, include });
    if (!product) throw AppError.notFound();
    return ok(res, toProductDto(product));
  }),
);

adminProductsRouter.post(
  '/',
  asyncHandler(async (req, res) => {
    const d = createSchema.parse(req.body);
    await assertCategory(d.categoryId);

    const product = await prisma.product.create({
      data: {
        ...flatAll('name', d.name),
        ...flatAll('description', d.description),
        ...flatAll('ingredients', d.ingredients),
        ...flatAll('allergens', d.allergens),
        price: d.price,
        stock: d.stock,
        images: d.images,
        isActive: d.isActive,
        categoryId: d.categoryId ?? null,
        variants: {
          create: d.variants.map((v) => ({
            group: v.group,
            ...flatAll('name', v.name),
            priceDelta: v.priceDelta,
            sortOrder: v.sortOrder,
            isActive: v.isActive,
          })),
        },
      },
      include,
    });

    return created(res, toProductDto(product));
  }),
);

adminProductsRouter.patch(
  '/:id',
  asyncHandler(async (req, res) => {
    const id = req.params.id;
    const d = updateSchema.parse(req.body);

    const existing = await prisma.product.findUnique({ where: { id }, include: { variants: true } });
    if (!existing) throw AppError.notFound();
    await assertCategory(d.categoryId);

    if (d.variants) {
      const known = new Set(existing.variants.map((v) => v.id));
      if (d.variants.some((v) => v.id && !known.has(v.id))) throw AppError.badRequest('INVALID_VARIANT');
    }

    const updated = await prisma.$transaction(async (tx) => {
      await tx.product.update({
        where: { id },
        data: {
          ...flatPartial('name', d.name),
          ...flatPartial('description', d.description),
          ...flatPartial('ingredients', d.ingredients),
          ...flatPartial('allergens', d.allergens),
          price: d.price,
          stock: d.stock,
          images: d.images,
          isActive: d.isActive,
          categoryId: d.categoryId,
        },
      });

      if (d.variants) {
        const keep = d.variants.flatMap((v) => (v.id ? [v.id] : []));
        await tx.productVariant.deleteMany({ where: { productId: id, id: { notIn: keep } } });

        for (const v of d.variants) {
          const data = {
            group: v.group,
            ...flatAll('name', v.name),
            priceDelta: v.priceDelta,
            sortOrder: v.sortOrder,
            isActive: v.isActive,
          };
          if (v.id) {
            await tx.productVariant.update({ where: { id: v.id }, data });
          } else {
            await tx.productVariant.create({ data: { ...data, productId: id } });
          }
        }
      }

      return tx.product.findUniqueOrThrow({ where: { id }, include });
    });

    // Miqdori qaytgan bo'lsa, «mavjud bo'lganda xabar bering» obunachilariga xabar ketadi.
    void notifyRestocked([id]);

    if (d.images) {
      const kept = new Set(d.images);
      await deleteImagesByUrl(existing.images.filter((url) => !kept.has(url)));
    }

    return ok(res, toProductDto(updated));
  }),
);

adminProductsRouter.delete(
  '/:id',
  asyncHandler(async (req, res) => {
    const existing = await prisma.product.findUnique({ where: { id: req.params.id } });
    if (!existing) throw AppError.notFound();

    // Buyurtma qatorlarida mahsulot nomi saqlanadi, shuning uchun o'chirish xavfsiz.
    await prisma.product.delete({ where: { id: existing.id } });
    await deleteImagesByUrl(existing.images);

    return ok(res, { deleted: true });
  }),
);