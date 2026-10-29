import { Router } from 'express';
import { setOrdersPaused } from '../services/storeSettings';
import { asyncHandler } from '../utils/asyncHandler';
import { ok } from '../utils/response';

export const adminStoreRouter = Router();

/** «Bugun buyurtma qabul qilmaymiz». */
adminStoreRouter.post(
  '/pause',
  asyncHandler(async (_req, res) => ok(res, await setOrdersPaused(true))),
);

adminStoreRouter.post(
  '/resume',
  asyncHandler(async (_req, res) => ok(res, await setOrdersPaused(false))),
);
