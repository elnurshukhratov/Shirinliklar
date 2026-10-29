import { Router } from 'express';
import { z } from 'zod';
import { firebaseAuth } from '../lib/firebase';
import { prisma } from '../lib/prisma';
import { authenticate } from '../middleware/auth';
import { rateLimit } from '../middleware/rateLimit';
import { asyncHandler } from '../utils/asyncHandler';
import { AppError } from '../utils/errors';
import { isValidPhone, normalizePhone } from '../utils/phone';
import { created, ok } from '../utils/response';
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

const USERNAME_RE = /^[a-z0-9_.]{3,24}$/;

const registerSchema = z
  .object({
    firstName: z.string().trim().min(1).max(60),
    lastName: z.string().trim().min(1).max(60),
    username: z.string().trim().toLowerCase().regex(USERNAME_RE, 'INVALID_USERNAME'),
    email: z.string().trim().toLowerCase().email().max(254),
    phone: z.string().trim().transform(normalizePhone).refine(isValidPhone, 'INVALID_PHONE'),
    address: z.string().trim().min(1).max(255),
    password: z.string().min(8).max(128),
    passwordConfirm: z.string(),
  })
  .strict()
  .refine((v) => v.password === v.passwordConfirm, {
    path: ['passwordConfirm'],
    message: 'PASSWORD_MISMATCH',
  });

/**
 * Email + parol bilan ro'yxatdan o'tish (tasdiqlash kodisiz).
 * Firebase akkaunti serverda yaratiladi, keyin ilova signInWithEmailAndPassword bilan kiradi.
 * Bazada email allaqachon bor bo'lsa (masalan, admin/xodim sifatida oldindan qo'shilgan) — rad etiladi:
 * email tasdiqlanmagani uchun parol orqali birovning rolini egallab bo'lmasligi shart.
 */
authRouter.post(
  '/register',
  rateLimit(10, 60 * 60 * 1000),
  asyncHandler(async (req, res) => {
    const d = registerSchema.parse(req.body);

    const [byEmail, byUsername] = await Promise.all([
      prisma.user.findUnique({ where: { email: d.email } }),
      prisma.user.findUnique({ where: { username: d.username } }),
    ]);
    if (byEmail) throw AppError.conflict('EMAIL_TAKEN');
    if (byUsername) throw AppError.conflict('USERNAME_TAKEN');

    let uid: string;
    try {
      const fb = await firebaseAuth().createUser({
        email: d.email,
        password: d.password,
        displayName: `${d.firstName} ${d.lastName}`,
        emailVerified: false,
      });
      uid = fb.uid;
    } catch (e) {
      const code = (e as { code?: string }).code;
      if (code === 'auth/email-already-exists') throw AppError.conflict('EMAIL_TAKEN');
      if (code === 'auth/invalid-password') throw AppError.badRequest('WEAK_PASSWORD');
      if (code === 'auth/invalid-email') throw AppError.badRequest('INVALID_EMAIL');
      throw e;
    }

    try {
      const user = await prisma.user.create({
        data: {
          firebaseUid: uid,
          email: d.email,
          username: d.username,
          firstName: d.firstName,
          lastName: d.lastName,
          phone: d.phone,
          address: d.address,
          isProfileComplete: true,
        },
      });
      return created(res, toUserDto(user));
    } catch (e) {
      await firebaseAuth()
        .deleteUser(uid)
        .catch(() => undefined);
      throw e;
    }
  }),
);

const lookupSchema = z
  .object({ username: z.string().trim().toLowerCase().min(1).max(40) })
  .strict();

/** Username bo'yicha kirish uchun: username -> email (keyin ilova Firebase'ga email + parol bilan kiradi). */
authRouter.post(
  '/lookup',
  rateLimit(30, 15 * 60 * 1000),
  asyncHandler(async (req, res) => {
    const { username } = lookupSchema.parse(req.body);
    const user = await prisma.user.findUnique({
      where: { username },
      select: { email: true, firebaseUid: true },
    });
    // Username yo'q yoki noto'g'ri parol — mijozga bir xil xato ko'rinadi.
    if (!user || !user.firebaseUid) throw AppError.badRequest('INVALID_CREDENTIALS');
    return ok(res, { email: user.email });
  }),
);