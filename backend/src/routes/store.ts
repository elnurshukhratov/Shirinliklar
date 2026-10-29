import { Router } from 'express';
import { getStoreStatus } from '../services/storeSettings';
import { asyncHandler } from '../utils/asyncHandler';
import { ok } from '../utils/response';

export const storeRouter = Router();

/** Do'kon buyurtma qabul qilyaptimi (hamma uchun ochiq). */
storeRouter.get(
  '/status',
  asyncHandler(async (_req, res) => ok(res, await getStoreStatus())),
);
