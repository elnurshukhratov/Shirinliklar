import { RequestHandler } from 'express';
import { AppError } from '../utils/errors';

/** Oddiy xotiradagi cheklov: bitta IP dan berilgan oynada ruxsat etilgan so'rovlar soni. */
export function rateLimit(max: number, windowMs: number): RequestHandler {
  const hits = new Map<string, { count: number; resetAt: number }>();

  setInterval(() => {
    const now = Date.now();
    hits.forEach((v, k) => {
      if (v.resetAt <= now) hits.delete(k);
    });
  }, windowMs).unref();

  return (req, _res, next) => {
    const key = req.ip ?? 'unknown';
    const now = Date.now();
    const entry = hits.get(key);

    if (!entry || entry.resetAt <= now) {
      hits.set(key, { count: 1, resetAt: now + windowMs });
      return next();
    }

    entry.count += 1;
    if (entry.count > max) return next(new AppError(429, 'TOO_MANY_REQUESTS', 'TOO_MANY_REQUESTS'));
    next();
  };
}