import { FulfillmentType, OrderStatus, PaymentMethod, PaymentStatus, Prisma } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { requireOwner } from '../middleware/auth';
import { notifyOrderRestock, notifyOrderStatus } from '../services/notifications';
import { refundOrder } from '../services/paymentService';
import { cancelOrderWithRestock } from '../services/orderStock';
import { asyncHandler } from '../utils/asyncHandler';
import { adminOrderInclude, toAdminOrderDto } from '../utils/adminOrderDto';
import { AppError } from '../utils/errors';
import { pageArgs, paginationShape } from '../utils/pagination';
import { ok } from '../utils/response';

export const adminOrdersRouter = Router();

const idParam = z.object({ id: z.string().min(1).max(100) });

const listQuery = z.object({
  ...paginationShape,
  status: z.nativeEnum(OrderStatus).optional(),
});

adminOrdersRouter.get(
  '/',
  asyncHandler(async (req, res) => {
    const { page, limit, status } = listQuery.parse(req.query);
    const where: Prisma.OrderWhereInput = status ? { status } : {};

    const [rows, total] = await Promise.all([
      prisma.order.findMany({
        where,
        include: adminOrderInclude,
        orderBy: { createdAt: 'desc' },
        ...pageArgs(page, limit),
      }),
      prisma.order.count({ where }),
    ]);

    return ok(res, rows.map(toAdminOrderDto), { page, limit, total });
  }),
);

adminOrdersRouter.get(
  '/:id',
  asyncHandler(async (req, res) => {
    const { id } = idParam.parse(req.params);
    const order = await prisma.order.findUnique({ where: { id }, include: adminOrderInclude });
    if (!order) throw AppError.notFound();
    return ok(res, toAdminOrderDto(order));
  }),
);

/**
 * Holatni bir bosqich oldinga suradi. O'tish faqat joriy holat kutilgan holatda bo'lsa bajariladi
 * (ikki admin bir vaqtda bosganda ham holat buzilmaydi).
 */
async function advance(id: string, to: OrderStatus) {
  return prisma.$transaction(async (tx) => {
    const order = await tx.order.findUnique({ where: { id } });
    if (!order) throw AppError.notFound();

    const allowed = nextStatuses(order.status, order.fulfillment);
    if (!allowed.includes(to)) throw AppError.conflict('INVALID_TRANSITION');

    const data: Prisma.OrderUpdateManyMutationInput = { status: to };
    // Naqd to'lov: buyurtma topshirilganda "to'langan" deb belgilanadi.
    if (
      to === OrderStatus.DELIVERED &&
      order.paymentMethod === PaymentMethod.CASH &&
      order.paymentStatus === PaymentStatus.UNPAID
    ) {
      data.paymentStatus = PaymentStatus.PAID;
    }

    const claimed = await tx.order.updateMany({ where: { id, status: order.status }, data });
    if (claimed.count !== 1) throw AppError.conflict('INVALID_TRANSITION');

    return tx.order.findUniqueOrThrow({ where: { id }, include: adminOrderInclude });
  });
}

function nextStatuses(status: OrderStatus, fulfillment: FulfillmentType): OrderStatus[] {
  switch (status) {
    case OrderStatus.PENDING:
      return [OrderStatus.ACCEPTED];
    case OrderStatus.ACCEPTED:
      return [OrderStatus.READY];
    case OrderStatus.READY:
      return fulfillment === FulfillmentType.DELIVERY ? [OrderStatus.ON_THE_WAY] : [OrderStatus.DELIVERED];
    case OrderStatus.ON_THE_WAY:
      return [OrderStatus.DELIVERED];
    default:
      return [];
  }
}

const actions: Array<[string, OrderStatus]> = [
  ['accept', OrderStatus.ACCEPTED],
  ['ready', OrderStatus.READY],
  ['on-the-way', OrderStatus.ON_THE_WAY],
  ['delivered', OrderStatus.DELIVERED],
];

for (const [path, status] of actions) {
  adminOrdersRouter.post(
    `/:id/${path}`,
    asyncHandler(async (req, res) => {
      const { id } = idParam.parse(req.params);
      const order = await advance(id, status);
      void notifyOrderStatus(order.id);
      return ok(res, toAdminOrderDto(order));
    }),
  );
}

const cancelSchema = z.object({ reason: z.string().trim().min(1).max(300) });

adminOrdersRouter.post(
  '/:id/cancel',
  asyncHandler(async (req, res) => {
    const { id } = idParam.parse(req.params);
    const { reason } = cancelSchema.parse(req.body);

    const exists = await prisma.order.findUnique({ where: { id }, select: { id: true } });
    if (!exists) throw AppError.notFound();

    await prisma.$transaction((tx) => cancelOrderWithRestock(tx, id, reason));
    const order = await prisma.order.findUniqueOrThrow({ where: { id }, include: adminOrderInclude });
    void notifyOrderStatus(id);
    void notifyOrderRestock(id);
    return ok(res, toAdminOrderDto(order));
  }),
);

/** Onlayn to'langan buyurtma pulini mijozga qaytaradi (to'lov tizimi orqali). Faqat do'kon egasi. */
adminOrdersRouter.post(
  '/:id/refund',
  requireOwner,
  asyncHandler(async (req, res) => {
    const { id } = idParam.parse(req.params);
    await refundOrder(id);
    const order = await prisma.order.findUniqueOrThrow({ where: { id }, include: adminOrderInclude });
    return ok(res, toAdminOrderDto(order));
  }),
);
