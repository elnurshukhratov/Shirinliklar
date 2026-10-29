import { NextFunction, Request, Response } from 'express';
import { Prisma } from '@prisma/client';
import multer from 'multer';
import { ZodError } from 'zod';
import { AppError } from '../utils/errors';
import { fail } from '../utils/response';
import { isProd } from '../config/env';

export function notFoundHandler(_req: Request, res: Response) {
  return fail(res, 404, 'NOT_FOUND', 'ROUTE_NOT_FOUND');
}

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export function errorHandler(err: unknown, _req: Request, res: Response, _next: NextFunction) {
  if (err instanceof AppError) {
    return fail(res, err.status, err.code, err.message, err.details);
  }
  if (err instanceof ZodError) {
    return fail(res, 400, 'VALIDATION_ERROR', 'VALIDATION_ERROR', err.flatten().fieldErrors);
  }
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') return fail(res, 413, 'PAYLOAD_TOO_LARGE', 'FILE_TOO_LARGE');
    return fail(res, 400, 'BAD_REQUEST', 'INVALID_UPLOAD');
  }
  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    if (err.code === 'P2002') return fail(res, 409, 'CONFLICT', 'ALREADY_EXISTS');
    if (err.code === 'P2025') return fail(res, 404, 'NOT_FOUND', 'NOT_FOUND');
    if (err.code === 'P2003') return fail(res, 400, 'BAD_REQUEST', 'INVALID_REFERENCE');
  }
  // Baza bilan aloqa uzilgan yoki band bo'lsa, mijoz tushunarli 503 oladi (ilova qayta urinish ko'rsatadi).
  if (
    err instanceof Prisma.PrismaClientInitializationError ||
    (err instanceof Prisma.PrismaClientKnownRequestError && ['P1001', 'P1002', 'P1008', 'P1017', 'P2024'].includes(err.code))
  ) {
    console.error(err);
    return fail(res, 503, 'SERVICE_UNAVAILABLE', 'DB_DOWN');
  }
  if (typeof err === 'object' && err !== null && (err as { type?: string }).type === 'entity.parse.failed') {
    return fail(res, 400, 'BAD_REQUEST', 'INVALID_JSON');
  }
  console.error(err);
  return fail(res, 500, 'INTERNAL_ERROR', 'INTERNAL_ERROR', isProd ? undefined : String(err));
}