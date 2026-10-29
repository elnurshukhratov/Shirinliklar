import { z } from 'zod';

export const paginationShape = {
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(50).default(20),
};

export function pageArgs(page: number, limit: number) {
  return { skip: (page - 1) * limit, take: limit };
}