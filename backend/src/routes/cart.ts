import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../utils/asyncHandler';
import { pack } from '../utils/i18n';
import { ok } from '../utils/response';

export const cartRouter = Router();

const validateBody = z.object({
  items: z
    .array(
      z.object({
        key: z.string().min(1).max(500),
        productId: z.string().min(1).max(100),
        variantIds: z.array(z.string().min(1).max(100)).max(10).default([]),
        quantity: z.coerce.number().int().min(1).max(99),
      }),
    )
    .max(50),
});

/**
 * Savatdagi har bir qator uchun joriy narx va mavjudlikni qaytaradi.
 * status: OK | OUT_OF_STOCK | UNAVAILABLE (yashirilgan, o'chirilgan yoki variant yo'q).
 */
cartRouter.post(
  '/validate',
  asyncHandler(async (req, res) => {
    const { items } = validateBody.parse(req.body);

    const ids = [...new Set(items.map((i) => i.productId))];
    const products = await prisma.product.findMany({
      where: {
        id: { in: ids },
        isActive: true,
        OR: [{ categoryId: null }, { category: { isActive: true } }],
      },
      include: { variants: { where: { isActive: true } } },
    });
    const byId = new Map(products.map((p) => [p.id, p]));

    const data = items.map((item) => {
      const unavailable = { key: item.key, status: 'UNAVAILABLE', stock: 0, unitPrice: 0 };

      const product = byId.get(item.productId);
      if (!product) return unavailable;

      const wanted = [...new Set(item.variantIds)];
      const chosen = product.variants.filter((v) => wanted.includes(v.id));
      if (chosen.length !== wanted.length) return unavailable;

      const unitPrice = Math.max(
        0,
        Number(product.price) + chosen.reduce((sum, v) => sum + Number(v.priceDelta), 0),
      );

      return {
        key: item.key,
        status: product.stock > 0 ? 'OK' : 'OUT_OF_STOCK',
        stock: product.stock,
        unitPrice,
        name: pack(product, 'name'),
        image: product.images[0] ?? null,
        variants: chosen.map((v) => ({ id: v.id, name: pack(v, 'name') })),
      };
    });

    return ok(res, { items: data });
  }),
);
