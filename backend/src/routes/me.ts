import { OrderStatus, Role } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { firebaseAuth } from '../lib/firebase';
import { prisma } from '../lib/prisma';
import { requireUser } from '../middleware/auth';
import { asyncHandler } from '../utils/asyncHandler';
import { AppError } from '../utils/errors';
import { ok } from '../utils/response';
import { toUserDto } from '../utils/userDto';

export const meRouter = Router();
meRouter.use(requireUser);

function normalizePhone(raw: string): string {
  const cleaned = raw.replace(/[\s\-()]/g, '');
  const digits = cleaned.replace(/\D/g, '');
  if (cleaned.startsWith('+')) return `+${digits}`;
  if (digits.length === 9) return `+998${digits}`;
  return `+${digits}`;
}

const text = (max: number) => z.string().trim().min(1).max(max);

const updateSchema = z
  .object({
    firstName: text(60).optional(),
    lastName: text(60).optional(),
    phone: z
      .string()
      .trim()
      .transform(normalizePhone)
      .refine((v) => /^\+\d{9,15}$/.test(v), 'INVALID_PHONE')
      .optional(),
    address: text(255).optional(),
    landmark: z
      .string()
      .trim()
      .max(255)
      .nullable()
      .optional()
      .transform((v) => (v === '' ? null : v)),
  })
  .strict();

meRouter.get(
  '/',
  asyncHandler(async (req, res) => ok(res, toUserDto(req.user!))),
);

meRouter.patch(
  '/',
  asyncHandler(async (req, res) => {
    const data = updateSchema.parse(req.body);
    const u = req.user!;

    const merged = {
      firstName: data.firstName ?? u.firstName,
      lastName: data.lastName ?? u.lastName,
      phone: data.phone ?? u.phone,
      address: data.address ?? u.address,
    };
    const isProfileComplete = Boolean(merged.firstName && merged.lastName && merged.phone && merged.address);

    const updated = await prisma.user.update({
      where: { id: u.id },
      data: { ...data, isProfileComplete },
    });
    return ok(res, toUserDto(updated));
  }),
);

const ACTIVE_STATUSES: OrderStatus[] = [
  OrderStatus.PENDING,
  OrderStatus.ACCEPTED,
  OrderStatus.READY,
  OrderStatus.ON_THE_WAY,
];

/**
 * Hisobni o'chirish. Buyurtmalari bor bo'lsa, do'kon hisobi saqlanishi uchun qator qoladi,
 * lekin barcha shaxsiy ma'lumotlar tozalanadi va qayta kirib bo'lmaydi.
 */
meRouter.delete(
  '/',
  asyncHandler(async (req, res) => {
    const u = req.user!;

    if (u.role === Role.ADMIN) {
      const admins = await prisma.user.count({ where: { role: Role.ADMIN } });
      if (admins <= 1) throw AppError.conflict('LAST_ADMIN');
    }

    const active = await prisma.order.count({ where: { userId: u.id, status: { in: ACTIVE_STATUSES } } });
    if (active > 0) throw AppError.conflict('ACTIVE_ORDERS');

    const ordersCount = await prisma.order.count({ where: { userId: u.id } });

    await prisma.$transaction(async (tx) => {
      await tx.deviceToken.deleteMany({ where: { userId: u.id } });
      await tx.review.deleteMany({ where: { userId: u.id } });
      await tx.favorite.deleteMany({ where: { userId: u.id } });
      await tx.stockSubscription.deleteMany({ where: { userId: u.id } });

      if (ordersCount === 0) {
        await tx.user.delete({ where: { id: u.id } });
        return;
      }

      await tx.order.updateMany({
        where: { userId: u.id },
        data: { address: null, phone: null, customerNote: null },
      });
      await tx.user.update({
        where: { id: u.id },
        data: {
          firebaseUid: null,
          email: `deleted-${u.id}@deleted.invalid`,
          firstName: null,
          lastName: null,
          phone: null,
          address: null,
          landmark: null,
          role: Role.CUSTOMER,
          isProfileComplete: false,
        },
      });
    });

    if (u.firebaseUid) {
      try {
        await firebaseAuth().deleteUser(u.firebaseUid);
      } catch (e) {
        console.error('Firebase akkauntini o\'chirishda xato:', e);
      }
    }

    return ok(res, { deleted: true });
  }),
);