import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../utils/asyncHandler';
import { AppError } from '../utils/errors';
import { ok } from '../utils/response';
import { toUserDto } from '../utils/userDto';

export const authRouter = Router();

/**
 * Google orqali kirgandan keyin chaqiriladi.
 * Foydalanuvchi bo'lmasa yaratadi; seed admin bo'lsa email bo'yicha Firebase akkauntiga bog'laydi.
 */
authRouter.post(
  '/google',
  authenticate,
  asyncHandler(async (req, res) => {
    const t = req.firebaseToken!;
    if (t.firebase?.sign_in_provider !== 'google.com') throw AppError.badRequest('PROVIDER_NOT_ALLOWED');

    const email = t.email?.toLowerCase();
    if (!email || t.email_verified === false) throw AppError.badRequest('EMAIL_REQUIRED');

    let user = await prisma.user.findUnique({ where: { firebaseUid: t.uid } });

    if (!user) {
      const byEmail = await prisma.user.findUnique({ where: { email } });
      if (byEmail) {
        if (byEmail.firebaseUid && byEmail.firebaseUid !== t.uid) throw AppError.conflict('EMAIL_TAKEN');
        user = await prisma.user.update({ where: { id: byEmail.id }, data: { firebaseUid: t.uid } });
      } else {
        const parts = (t.name ?? '').trim().split(/\s+/).filter(Boolean);
        user = await prisma.user.create({
          data: {
            firebaseUid: t.uid,
            email,
            firstName: parts[0] ?? null,
            lastName: parts.length > 1 ? parts.slice(1).join(' ') : null,
          },
        });
      }
    }

    return ok(res, toUserDto(user));
  }),
);