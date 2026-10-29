import { Response } from 'express';

export interface Meta {
  page?: number;
  limit?: number;
  total?: number;
}

export function ok<T>(res: Response, data: T, meta?: Meta, status = 200) {
  return res.status(status).json({ success: true, data, ...(meta ? { meta } : {}) });
}

export function created<T>(res: Response, data: T) {
  return ok(res, data, undefined, 201);
}

export function fail(res: Response, status: number, code: string, message: string, details?: unknown) {
  return res.status(status).json({
    success: false,
    error: { code, message, ...(details !== undefined ? { details } : {}) },
  });
}
