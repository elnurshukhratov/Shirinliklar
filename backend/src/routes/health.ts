import { Router } from 'express';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../utils/asyncHandler';
import { fail, ok } from '../utils/response';

export const healthRouter = Router();

healthRouter.get(
  '/',
  asyncHandler(async (_req, res) => {
    try {
      await prisma.$queryRaw`SELECT 1`;
      return ok(res, { status: 'ok', db: 'up', time: new Date().toISOString() });
    } catch {
      return fail(res, 503, 'SERVICE_UNAVAILABLE', 'DB_DOWN');
    }
  }),
);
