import { FulfillmentType, OrderStatus, PaymentMethod, Prisma } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { env } from '../config/env';
import { prisma } from '../lib/prisma';
import { requireUser } from '../middleware/auth';
import { notifyNewOrder, notifyOrderRestock } from '../services/notifications';
import { restoreStock } from '../services/orderStock';
import { assertPromoUsable, claimPromo, findPromo, promoDiscount } from '../services/promo';
import { assertAcceptingOrders, getStoreStatus } from '../services/storeSettings';
import { asyncHandler } from '../utils/asyncHandler';
import { AppError } from '../utils/errors';
import { toOrderDto } from '../utils/orderDto';
import { pageArgs, paginationShape } from '../utils/pagination';
import { isValidPhone, normalizePhone } from '../utils/phone';
import { pack } from '../utils/i18n';
import { created, ok } from '../utils/response';

export const ordersRouter = Router();
ordersRouter.use(requireUser);

ordersRouter.get(
  '/options',
  asyncHandler(async (_req, res) =>
    ok(res, {
      deliveryFee: env.DELIVERY_FEE,
      minLeadMinutes: env.ORDER_MIN_LEAD_MINUTES,
      maxDaysAhead: env.ORDER_MAX_DAYS_AHEAD,
      ...(await getStoreStatus()),
    }),
  ),
);

const createSchema = z.object({
  items: z
    .array(
      z.object({
        productId: z.string().min(1).max(100),
        variantIds: z.array(z.string().min(1).max(100)).max(10).default([]),
        quantity: z.coerce.number().int().min(1).max(99),
      }),
    )
    .min(1)
    .max(50),
  fulfillment: z.nativeEnum(FulfillmentType),
  paymentMethod: z.nativeEnum(PaymentMethod),
  scheduledAt: z.coerce.date(),
  customerNote: z
    .string()
    .trim()
    .max(500)
    .optional()
    .transform((v) => (v ? v : null)),
  address: z.string().trim().max(255).optional(),
  phone: z.string().trim().max(40).optional(),
  promoCode: z.string().trim().max(40).optional(),
});

ordersRouter.post(
  '/',
  asyncHandler(async (req, res) => {
    const data = createSchema.parse(req.body);
    const user = req.user!;

    await assertAcceptingOrders();

    const now = Date.now();
    const earliest = now + env.ORDER_MIN_LEAD_MINUTES * 60_000;
    const latest = now + env.ORDER_MAX_DAYS_AHEAD * 24 * 60 * 60_000;
    const at = data.scheduledAt.getTime();
    if (Number.isNaN(at) || at < earliest || at > latest) throw AppError.badRequest('INVALID_SCHEDULE');

    const phone = normalizePhone(data.phone || user.phone || '');
    if (!phone || phone === '+') throw AppError.badRequest('PHONE_REQUIRED');
    if (!isValidPhone(phone)) throw AppError.badRequest('INVALID_PHONE');

    const isDelivery = data.fulfillment === FulfillmentType.DELIVERY;
    const address = isDelivery ? data.address || user.address || null : null;
    if (isDelivery && !address) throw AppError.badRequest('ADDRESS_REQUIRED');

    const order = await prisma.$transaction(async (tx) => {
      const productIds = [...new Set(data.items.map((i) => i.productId))];
      const products = await tx.product.findMany({
        where: {
          id: { in: productIds },
          isActive: true,
          OR: [{ categoryId: null }, { category: { isActive: true } }],
        },
        include: { variants: { where: { isActive: true } } },
      });
      const byId = new Map(products.map((p) => [p.id, p]));

      const lines: Prisma.OrderItemCreateWithoutOrderInput[] = [];
      const wanted = new Map<string, number>();
      let subtotal = 0;

      for (const item of data.items) {
        const product = byId.get(item.productId);
        if (!product) throw AppError.conflict('ITEMS_CHANGED');

        const ids = [...new Set(item.variantIds)];
        const chosen = product.variants.filter((v) => ids.includes(v.id));
        if (chosen.length !== ids.length) throw AppError.conflict('ITEMS_CHANGED');

        const unitPrice = Math.max(
          0,
          Number(product.price) + chosen.reduce((sum, v) => sum + Number(v.priceDelta), 0),
        );
        const lineTotal = unitPrice * item.quantity;
        subtotal += lineTotal;
        wanted.set(product.id, (wanted.get(product.id) ?? 0) + item.quantity);

        lines.push({
          product: { connect: { id: product.id } },
          productName: product.nameUz,
          options: {
            variants: chosen.map((v) => ({
              id: v.id,
              group: v.group,
              name: pack(v, 'name'),
              priceDelta: Number(v.priceDelta),
            })),
          },
          unitPrice,
          quantity: item.quantity,
          lineTotal,
        });
      }

      // Ombordan shartli ayirish: boshqa buyurtma bilan bir vaqtda ham manfiy qoldiq bo'lmaydi.
      for (const [productId, quantity] of wanted) {
        const updated = await tx.product.updateMany({
          where: { id: productId, stock: { gte: quantity } },
          data: { stock: { decrement: quantity } },
        });
        if (updated.count !== 1) throw AppError.conflict('ITEMS_CHANGED');
      }

      // Promokod: chegirma serverda qayta hisoblanadi va foydalanish hisobi band qilinadi.
      let discount = 0;
      let promoCodeId: string | null = null;
      if (data.promoCode) {
        const promo = await findPromo(tx, data.promoCode);
        assertPromoUsable(promo);
        discount = promoDiscount(promo, subtotal);
        await claimPromo(tx, promo);
        promoCodeId = promo.id;
      }

      const deliveryFee = isDelivery ? env.DELIVERY_FEE : 0;

      return tx.order.create({
        data: {
          userId: user.id,
          paymentMethod: data.paymentMethod,
          fulfillment: data.fulfillment,
          scheduledAt: data.scheduledAt,
          customerNote: data.customerNote,
          address,
          phone,
          subtotal,
          deliveryFee,
          discount,
          promoCodeId,
          total: subtotal - discount + deliveryFee,
          items: { create: lines },
        },
        include: { items: true },
      });
    });

    void notifyNewOrder(order.id);
    return created(res, toOrderDto(order));
  }),
);

const idParam = z.object({ id: z.string().min(1).max(100) });

/** Mijozning o'z buyurtmalari (eng yangisi birinchi). */
ordersRouter.get(
  '/',
  asyncHandler(async (req, res) => {
    const { page, limit } = z.object(paginationShape).parse(req.query);
    const where: Prisma.OrderWhereInput = { userId: req.user!.id };

    const [rows, total] = await Promise.all([
      prisma.order.findMany({
        where,
        include: { items: true },
        orderBy: { createdAt: 'desc' },
        ...pageArgs(page, limit),
      }),
      prisma.order.count({ where }),
    ]);

    return ok(res, rows.map(toOrderDto), { page, limit, total });
  }),
);

ordersRouter.get(
  '/:id',
  asyncHandler(async (req, res) => {
    const { id } = idParam.parse(req.params);
    const order = await prisma.order.findFirst({
      where: { id, userId: req.user!.id },
      include: { items: true },
    });
    if (!order) throw AppError.notFound();
    return ok(res, toOrderDto(order));
  }),
);

/** Variant id'lari buyurtma qatoriga yozib qo'yilgan (options.variants[].id). */
function storedVariantIds(options: Prisma.JsonValue): string[] {
  if (!options || typeof options !== 'object' || Array.isArray(options)) return [];
  const variants = (options as { variants?: unknown }).variants;
  if (!Array.isArray(variants)) return [];
  return variants
    .map((v) => (v && typeof v === 'object' ? (v as { id?: unknown }).id : null))
    .filter((id): id is string => typeof id === 'string');
}

/**
 * «Qayta buyurtma»: topshirilgan buyurtmadagi mahsulotlarni hozirgi narx va mavjudlik bilan
 * savatga qo'shishga tayyor qilib qaytaradi. Tugagan yoki o'chirilganlar `unavailable`da,
 * miqdori omborga moslab kamaytirilgan bo'lsa `reduced: true`.
 */
ordersRouter.get(
  '/:id/reorder',
  asyncHandler(async (req, res) => {
    const { id } = idParam.parse(req.params);
    const order = await prisma.order.findFirst({
      where: { id, userId: req.user!.id },
      include: { items: true },
    });
    if (!order) throw AppError.notFound();
    if (order.status !== OrderStatus.DELIVERED) throw AppError.conflict('REORDER_NOT_ALLOWED');

    const productIds = [
      ...new Set(order.items.map((i) => i.productId).filter((v): v is string => !!v)),
    ];
    const products = await prisma.product.findMany({
      where: {
        id: { in: productIds },
        isActive: true,
        OR: [{ categoryId: null }, { category: { isActive: true } }],
      },
      include: { variants: { where: { isActive: true } } },
    });
    const byId = new Map(products.map((p) => [p.id, p]));
    const left = new Map(products.map((p) => [p.id, p.stock]));

    const items: unknown[] = [];
    const unavailable: { uz: string; en: string; ru: string }[] = [];
    let reduced = false;

    for (const item of order.items) {
      const product = item.productId ? byId.get(item.productId) : undefined;
      if (!product) {
        unavailable.push({ uz: item.productName, en: item.productName, ru: item.productName });
        continue;
      }

      const wanted = [...new Set(storedVariantIds(item.options))];
      const chosen = product.variants.filter((v) => wanted.includes(v.id));
      const remaining = left.get(product.id) ?? 0;
      const quantity = Math.min(item.quantity, remaining, 99);

      if (chosen.length !== wanted.length || quantity <= 0) {
        unavailable.push(pack(product, 'name'));
        continue;
      }
      if (quantity < item.quantity) reduced = true;
      left.set(product.id, remaining - quantity);

      items.push({
        productId: product.id,
        variantIds: chosen.map((v) => v.id),
        quantity,
        stock: product.stock,
        unitPrice: Math.max(
          0,
          Number(product.price) + chosen.reduce((sum, v) => sum + Number(v.priceDelta), 0),
        ),
        name: pack(product, 'name'),
        image: product.images[0] ?? null,
        variants: chosen.map((v) => ({ id: v.id, name: pack(v, 'name') })),
      });
    }

    return ok(res, { items, unavailable, reduced });
  }),
);

/** Mijoz buyurtmani faqat admin qabul qilishidan oldin ("kutilmoqda") bekor qila oladi. */
ordersRouter.post(
  '/:id/cancel',
  asyncHandler(async (req, res) => {
    const { id } = idParam.parse(req.params);
    const userId = req.user!.id;

    const exists = await prisma.order.findFirst({ where: { id, userId }, select: { id: true } });
    if (!exists) throw AppError.notFound();

    const order = await prisma.$transaction(async (tx) => {
      // Shartli holat o'zgartirish: admin shu paytda qabul qilgan bo'lsa, bekor qilinmaydi.
      const claimed = await tx.order.updateMany({
        where: { id, userId, status: OrderStatus.PENDING },
        data: { status: OrderStatus.CANCELLED },
      });
      if (claimed.count !== 1) throw AppError.conflict('ORDER_NOT_CANCELLABLE');

      await restoreStock(tx, id);
      return tx.order.findUniqueOrThrow({ where: { id }, include: { items: true } });
    });

    void notifyOrderRestock(id);
    return ok(res, toOrderDto(order));
  }),
);
