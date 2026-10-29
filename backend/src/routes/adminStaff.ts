import { Role, User } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../utils/asyncHandler';
import { AppError } from '../utils/errors';
import { created, ok } from '../utils/response';

/** Xodimlarni boshqarish (faqat do'kon egasi uchun; admin.ts da himoyalangan). */
export const adminStaffRouter = Router();

const idParam = z.object({ id: z.string().min(1).max(100) });

const addSchema = z
  .object({
    email: z.string().trim().toLowerCase().email('INVALID_EMAIL').max(254),
  })
  .strict();

function toStaffDto(u: User) {
  return {
    id: u.id,
    email: u.email,
    firstName: u.firstName,
    lastName: u.lastName,
    phone: u.phone,
    role: u.role,
    // false — xodim hali Google orqali birinchi marta kirmagan.
    hasSignedIn: u.firebaseUid != null,
    createdAt: u.createdAt,
  };
}

/** Egasi va xodimlar ro'yxati: avval egasi, keyin xodimlar qo'shilgan tartibda. */
adminStaffRouter.get(
  '/',
  asyncHandler(async (_req, res) => {
    const rows = await prisma.user.findMany({
      where: { role: { in: [Role.ADMIN, Role.STAFF] } },
      orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
    });
    const sorted = [...rows.filter((u) => u.role === Role.ADMIN), ...rows.filter((u) => u.role === Role.STAFF)];
    return ok(res, sorted.map(toStaffDto));
  }),
);

/**
 * Xodim qo'shish: email bo'yicha. Foydalanuvchi allaqachon bor bo'lsa, roli xodimga o'zgaradi;
 * yo'q bo'lsa, birinchi Google kirishida avtomatik bog'lanadigan yozuv yaratiladi.
 */
adminStaffRouter.post(
  '/',
  asyncHandler(async (req, res) => {
    const { email } = addSchema.parse(req.body);

    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      if (existing.role === Role.ADMIN) throw AppError.conflict('STAFF_IS_OWNER');
      if (existing.role === Role.STAFF) throw AppError.conflict('STAFF_EXISTS');
      // O'chirilgan hisob (firebaseUid yo'q, email o'rnida belgi) xodim bo'lib qolmasligi uchun.
      if (existing.email.endsWith('@deleted.invalid')) throw AppError.badRequest('INVALID_EMAIL');

      const updated = await prisma.user.update({ where: { id: existing.id }, data: { role: Role.STAFF } });
      return created(res, toStaffDto(updated));
    }

    const user = await prisma.user.create({ data: { email, role: Role.STAFF } });
    return created(res, toStaffDto(user));
  }),
);

/**
 * Xodimni olib tashlash: u oddiy mijozga aylanadi. Hali kirmagan va buyurtmasi yo'q yozuv
 * butunlay o'chiriladi. Do'kon egasini bu yo'l bilan olib tashlab bo'lmaydi.
 */
adminStaffRouter.delete(
  '/:id',
  asyncHandler(async (req, res) => {
    const { id } = idParam.parse(req.params);

    const target = await prisma.user.findUnique({ where: { id } });
    if (!target) throw AppError.notFound();
    if (target.role === Role.ADMIN) throw AppError.conflict('STAFF_IS_OWNER');
    if (target.role !== Role.STAFF) throw AppError.notFound();

    const orders = await prisma.order.count({ where: { userId: id } });
    if (target.firebaseUid == null && orders === 0) {
      await prisma.user.delete({ where: { id } });
    } else {
      await prisma.user.update({ where: { id }, data: { role: Role.CUSTOMER } });
    }
    return ok(res, { removed: true });
  }),
);
