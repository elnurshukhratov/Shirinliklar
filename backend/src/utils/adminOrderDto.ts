import { Prisma } from '@prisma/client';
import { toOrderDto } from './orderDto';

/** Admin buyurtma ko'rinishi uchun kerakli bog'lanishlar. */
export const adminOrderInclude = { items: true, user: true } as const;

export type AdminOrderRow = Prisma.OrderGetPayload<{ include: typeof adminOrderInclude }>;

export function toAdminOrderDto(o: AdminOrderRow) {
  return {
    ...toOrderDto(o),
    customer: {
      id: o.user.id,
      firstName: o.user.firstName,
      lastName: o.user.lastName,
      phone: o.user.phone,
      email: o.user.email,
    },
  };
}
