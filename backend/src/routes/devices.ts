import { Language } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { requireUser } from '../middleware/auth';
import { asyncHandler } from '../utils/asyncHandler';
import { ok } from '../utils/response';

export const devicesRouter = Router();
devicesRouter.use(requireUser);

const token = z.string().trim().min(20).max(4096);

const registerSchema = z.object({
  token,
  platform: z.enum(['android', 'ios']),
  language: z.enum(['uz', 'en', 'ru']).default('uz'),
});

const languageOf = { uz: Language.UZ, en: Language.EN, ru: Language.RU } as const;

/** Qurilma tokenini saqlaydi yoki yangilaydi (token boshqa foydalanuvchiga o'tgan bo'lsa, shunga o'tkaziladi). */
devicesRouter.post(
  '/',
  asyncHandler(async (req, res) => {
    const d = registerSchema.parse(req.body);
    const data = { userId: req.user!.id, platform: d.platform, language: languageOf[d.language] };
    await prisma.deviceToken.upsert({
      where: { token: d.token },
      create: { token: d.token, ...data },
      update: data,
    });
    return ok(res, { registered: true });
  }),
);

/** Chiqishda: shu qurilmaga endi bildirishnoma yuborilmaydi. */
devicesRouter.post(
  '/unregister',
  asyncHandler(async (req, res) => {
    const d = z.object({ token }).parse(req.body);
    await prisma.deviceToken.deleteMany({ where: { token: d.token, userId: req.user!.id } });
    return ok(res, { unregistered: true });
  }),
);
