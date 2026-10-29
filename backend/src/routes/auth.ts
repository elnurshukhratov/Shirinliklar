import bcrypt from 'bcryptjs';
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
 * Ro'yxatdan o'tish (tasdiqlash kodisiz). Javob: { token, user } — ilova darhol kirgan bo'ladi.
 * Bazada email allaqachon bo'lsa rad etiladi: email tasdiqlanmagani uchun birovning
 * hisobini yoki rolini egallab bo'lmasligi shart.
 */
authRouter.post(
  '/register',
  rateLimit(10, 60 * 60 * 1000),
  asyncHandler(async (req, res) => {
    const d = registerSchema.parse(req.body);

    if (RESERVED_USERNAMES.has(d.username)) throw AppError.conflict('USERNAME_TAKEN');

    const [byEmail, byUsername] = await Promise.all([
      prisma.user.findUnique({ where: { email: d.email } }),
      prisma.user.findUnique({ where: { username: d.username } }),
    ]);
    if (byEmail) throw AppError.conflict('EMAIL_TAKEN');
    if (byUsername) throw AppError.conflict('USERNAME_TAKEN');

    const user = await prisma.user.create({
      data: {
        email: d.email,
        username: d.username,
        passwordHash: await hashPassword(d.password),
        firstName: d.firstName,
        lastName: d.lastName,
        phone: d.phone,
        address: d.address,
        isProfileComplete: true,
      },
    });
    return created(res, { token: signToken(user.id), user: toUserDto(user) });
  }),
);

const loginSchema = z
  .object({
    login: z.string().trim().toLowerCase().min(1).max(254),
    password: z.string().min(1).max(128),
  })
  .strict();

/** Kirish: username yoki email + parol. Javob: { token, user }. */
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