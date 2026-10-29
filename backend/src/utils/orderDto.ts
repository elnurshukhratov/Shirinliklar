import { Order, OrderItem } from '@prisma/client';

export type OrderWithItems = Order & { items: OrderItem[] };

export function toOrderDto(o: OrderWithItems) {
  return {
    id: o.id,
    number: o.number,
    status: o.status,
    paymentMethod: o.paymentMethod,
    paymentStatus: o.paymentStatus,
    fulfillment: o.fulfillment,
    scheduledAt: o.scheduledAt,
    customerNote: o.customerNote,
    address: o.address,
    phone: o.phone,
    subtotal: Number(o.subtotal),
    deliveryFee: Number(o.deliveryFee),
    discount: Number(o.discount),
    total: Number(o.total),
    cancelReason: o.cancelReason,
    items: o.items.map((i) => ({
      id: i.id,
      productId: i.productId,
      productName: i.productName,
      options: i.options,
      unitPrice: Number(i.unitPrice),
      quantity: i.quantity,
      lineTotal: Number(i.lineTotal),
    })),
    createdAt: o.createdAt,
    updatedAt: o.updatedAt,
  };
}
