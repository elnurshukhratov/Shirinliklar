import { NextFunction, Request, RequestHandler, Response } from 'express';
import { Role, User } from '@prisma/client';
import { verifyToken } from '../lib/jwt';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../utils/asyncHandler';
import { AppError } from '../utils/errors';

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      userId?: string;
      user?: User;
    }
  }
}

function readBearer(req: Request): string {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) throw AppError.unauthorized();
  const token = header.slice(7).trim();
  if (!token) throw AppError.unauthorized();
  return token;
}

/** Ilova tokenini (JWT) tekshiradi. */
export const authenticate: RequestHandler = asyncHandler(async (req, _res, next) => {
  const token = readBearer(req);
  try {
    req.userId = verifyToken(token);
  } catch {
    throw AppError.unauthorized('INVALID_TOKEN');
  }
  next();
});

const loadUser: RequestHandler = asyncHandler(async (req, _res, next) => {
  const user = await prisma.user.findUnique({ where: { id: req.userId! } });
  // O'chirilgan hisob (email o'rnida belgi) eski token bilan ham kira olmaydi.
  if (!user || user.email.endsWith('@deleted.invalid')) throw AppError.unauthorized('USER_NOT_FOUND');
  req.user = user;
  next();
});

/** Token to'g'ri va foydalanuvchi bazada bor bo'lishi shart. */
export const requireUser: RequestHandler[] = [authenticate, loadUser];

export function requireRole(...roles: Role[]): RequestHandler {
  return (req: Request, _res: Response, next: NextFunction) => {
    if (!req.user || !roles.includes(req.user.role)) return next(AppError.forbidden());
    next();
  };
}

/** Admin paneldan foydalanishi mumkin bo'lgan rollar: do'kon egasi va xodim. */
export const PANEL_ROLES: Role[] = [Role.ADMIN, Role.STAFF];

/** Faqat do'kon egasi (promokod, xodimlar, qaytarish va h.k.). */
export const requireOwner: RequestHandler = requireRole(Role.ADMIN);

/**
 * Berilgan HTTP metodlari faqat do'kon egasiga ruxsat etiladi, qolganlari xodimga ham.
 * Masalan, toifalarni xodim ko'ra oladi, lekin o'zgartira olmaydi.
 */
export function ownerForMethods(...methods: string[]): RequestHandler {
  const blocked = new Set(methods.map((m) => m.toUpperCase()));
  return (req: Request, _res: Response, next: NextFunction) => {
    if (!blocked.has(req.method.toUpperCase())) return next();
    if (!req.user || req.user.role !== Role.ADMIN) return next(AppError.forbidden('OWNER_ONLY'));
    next();
  };
}