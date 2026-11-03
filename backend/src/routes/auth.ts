import bcrypt from 'bcryptjs';
import { Prisma } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { signToken } from '../lib/jwt';
import { prisma } from '../lib/prisma';
import { rateLimit } from '../middleware/rateLimit';
import { asyncHandler } from '../utils/asyncHandler';
import { RESERVED_USERNAMES, USERNAME_RE, hashPassword, verifyPassword } from '../utils/credentials';
import { AppError } from '../utils/errors';
import { isValidPhone, normalizePhone } from '../utils/phone';
import { created, ok } from '../utils/response';
import { toUserDto } from '../utils/userDto';

export const authRouter = Router();

// Foydalanuvchi topilmaganda ham parol tekshiruvi bir xil vaqt olishi uchun.
const DUMMY_HASH = bcrypt.hashSync('dummy-password-for-timing', 10);

/** Email so'ralmaydi; bazada email ustuni majburiy bo'lgani uchun ichki belgi yoziladi. */
export const PLACEHOLDER_EMAIL_DOMAIN = '@users.shirinliklar.invalid';

const registerSchema = z
  .object({
    firstName: z.string().trim().min(1).max(60),
    lastName: z.string().trim().min(1).max(60),
    phone: z.string().trim().transform(normalizePhone).refine(isValidPhone, 'INVALID_PHONE'),
    username: z.string().trim().toLowerCase().regex(USERNAME_RE, 'INVALID_USERNAME'),
    password: z.string().min(8).max(128),
    passwordConfirm: z.string(),
  })
  .strict()
  .refine((v) => v.password === v.passwordConfirm, {
    path: ['passwordConfirm'],
    message: 'PASSWORD_MISMATCH',
  });

/** Username bo'shmi — ro'yxatdan o'tishning 2-qadamida tekshiriladi. */
authRouter.get(
  '/username-available',
  rateLimit(60, 60 * 1000),
  asyncHandler(async (req, res) => {
    const username = String(req.query.username ?? '').trim().toLowerCase();
    if (!USERNAME_RE.test(username) || RESERVED_USERNAMES.has(username)) {
      return ok(res, { available: false });
    }
    const existing = await prisma.user.findUnique({ where: { username }, select: { id: true } });
    return ok(res, { available: !existing });
  }),
);

/**
 * Ro'yxatdan o'tish (tasdiqlash kodisiz). Javob: { token, user } — ilova darhol kirgan bo'ladi.
 */
authRouter.post(
  '/register',
  rateLimit(10, 60 * 60 * 1000),
  asyncHandler(async (req, res) => {
    const d = registerSchema.parse(req.body);

    if (RESERVED_USERNAMES.has(d.username)) throw AppError.conflict('USERNAME_TAKEN');

    const existing = await prisma.user.findUnique({ where: { username: d.username } });
    if (existing) throw AppError.conflict('USERNAME_TAKEN');

    const passwordHash = await hashPassword(d.password);

    let user;
    try {
      user = await prisma.user.create({
        data: {
          email: `${d.username}${PLACEHOLDER_EMAIL_DOMAIN}`,
          username: d.username,
          passwordHash,
          firstName: d.firstName,
          lastName: d.lastName,
          phone: d.phone,
          isProfileComplete: true,
        },
      });
    } catch (err) {
      // Bir vaqtda ikki so'rov bir xil username bilan kelsa, bazadagi UNIQUE cheklovi ushlaydi.
      if (err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002') {
        throw AppError.conflict('USERNAME_TAKEN');
      }
      throw err;
    }
    // Foydalanuvchi bazaga yozildi; token shundan keyin beriladi, login ham xuddi shu yozuvdan o'qiydi.
    return created(res, { token: signToken(user.id), user: toUserDto(user) });
  }),
);

const loginSchema = z
  .object({
    login: z.string().trim().toLowerCase().min(1).max(254),
    password: z.string().min(1).max(128),
  })
  .strict();

/** Kirish: username (yoki email) + parol. Javob: { token, user }. */
authRouter.post(
  '/login',
  rateLimit(20, 15 * 60 * 1000),
  asyncHandler(async (req, res) => {
    const { login, password } = loginSchema.parse(req.body);

    const user = await prisma.user.findUnique({
      where: login.includes('@') ? { email: login } : { username: login },
    });

    const passwordOk = await verifyPassword(password, user?.passwordHash ?? DUMMY_HASH);
    if (!user || !user.passwordHash || !passwordOk || user.email.endsWith('@deleted.invalid')) {
      throw AppError.badRequest('INVALID_CREDENTIALS');
    }
    return ok(res, { token: signToken(user.id), user: toUserDto(user) });
  }),
);