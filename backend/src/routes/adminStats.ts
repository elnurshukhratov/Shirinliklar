import { Prisma } from '@prisma/client';
import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../utils/asyncHandler';
import { pageArgs, paginationShape } from '../utils/pagination';
import { ok } from '../utils/response';

export const adminStatsRouter = Router();

/** Do'kon vaqti: O'zbekiston (UTC+5, yozgi vaqtga o'tmaydi). */
const TZ = 'Asia/Tashkent';
const TZ_OFFSET_MS = 5 * 60 * 60 * 1000;

const DAILY_DAYS = 14;
const MONTHLY_MONTHS = 6;
const TOP_LIMIT = 10;

/** Savdoga faqat bekor qilinmagan va puli qaytarilmagan buyurtmalar kiradi. */
const COUNTED = Prisma.sql`o."status" <> 'CANCELLED' AND o."paymentStatus" <> 'REFUNDED'`;

type SeriesRow = { key: string; orders: number; revenue: number };
type Point = { key: string; orders: number; revenue: number };

const pad = (n: number) => String(n).padStart(2, '0');

/** Do'kon vaqtidagi "hozir" (UTC getter'lari do'kon vaqtini beradi). */
function shopNow() {
  return new Date(Date.now() + TZ_OFFSET_MS);
}

function dayKey(d: Date) {
  return `${d.getUTCFullYear()}-${pad(d.getUTCMonth() + 1)}-${pad(d.getUTCDate())}`;
}

function monthKey(d: Date) {
  return `${d.getUTCFullYear()}-${pad(d.getUTCMonth() + 1)}`;
}

/** Do'kon vaqtidagi sana boshini haqiqiy (UTC) vaqtga o'giradi. */
function shopStartToUtc(y: number, m: number, d: number) {
  return new Date(Date.UTC(y, m, d) - TZ_OFFSET_MS);
}

function fill(keys: string[], rows: SeriesRow[]): Point[] {
  const map = new Map(rows.map((r) => [r.key, r]));
  return keys.map((key) => {
    const r = map.get(key);
    return { key, orders: r?.orders ?? 0, revenue: r?.revenue ?? 0 };
  });
}

async function series(unit: 'day' | 'month', from: Date): Promise<SeriesRow[]> {
  const fmt = unit === 'day' ? 'YYYY-MM-DD' : 'YYYY-MM';
  return prisma.$queryRaw<SeriesRow[]>`
    SELECT to_char(date_trunc(${unit}, o."createdAt" AT TIME ZONE ${TZ}), ${fmt}) AS "key",
           COUNT(*)::int AS "orders",
           COALESCE(SUM(o."total"), 0)::float8 AS "revenue"
    FROM "Order" o
    WHERE ${COUNTED} AND o."createdAt" >= ${from}
    GROUP BY 1
    ORDER BY 1`;
}

adminStatsRouter.get(
  '/overview',
  asyncHandler(async (_req, res) => {
    const now = shopNow();
    const y = now.getUTCFullYear();
    const m = now.getUTCMonth();
    const d = now.getUTCDate();

    const dayKeys: string[] = [];
    for (let i = DAILY_DAYS - 1; i >= 0; i--) dayKeys.push(dayKey(new Date(Date.UTC(y, m, d - i))));
    const monthKeys: string[] = [];
    for (let i = MONTHLY_MONTHS - 1; i >= 0; i--) monthKeys.push(monthKey(new Date(Date.UTC(y, m - i, 1))));

    const dailyFrom = shopStartToUtc(y, m, d - (DAILY_DAYS - 1));
    const monthlyFrom = shopStartToUtc(y, m - (MONTHLY_MONTHS - 1), 1);

    const [dailyRows, monthlyRows, top] = await Promise.all([
      series('day', dailyFrom),
      series('month', monthlyFrom),
      prisma.$queryRaw<{ name: string; quantity: number; revenue: number }[]>`
        SELECT i."productName" AS "name",
               SUM(i."quantity")::int AS "quantity",
               COALESCE(SUM(i."lineTotal"), 0)::float8 AS "revenue"
        FROM "OrderItem" i
        JOIN "Order" o ON o."id" = i."orderId"
        WHERE ${COUNTED}
        GROUP BY i."productName"
        ORDER BY "quantity" DESC, "revenue" DESC
        LIMIT ${TOP_LIMIT}`,
    ]);

    const daily = fill(dayKeys, dailyRows);
    const monthly = fill(monthKeys, monthlyRows);

    return ok(res, {
      today: daily[daily.length - 1],
      month: monthly[monthly.length - 1],
      daily,
      monthly,
      topProducts: top,
    });
  }),
);

const customersQuery = z.object(paginationShape);

adminStatsRouter.get(
  '/customers',
  asyncHandler(async (req, res) => {
    const q = customersQuery.parse(req.query);
    const { skip, take } = pageArgs(q.page, q.limit);

    const [rows, total] = await Promise.all([
      prisma.$queryRaw<
        {
          id: string;
          firstName: string | null;
          lastName: string | null;
          email: string;
          phone: string | null;
          createdAt: Date;
          orders: number;
          spent: number;
          lastOrderAt: Date | null;
        }[]
      >`
        SELECT u."id", u."firstName", u."lastName", u."email", u."phone", u."createdAt",
               (COUNT(o."id") FILTER (WHERE ${COUNTED}))::int AS "orders",
               COALESCE(SUM(o."total") FILTER (WHERE ${COUNTED}), 0)::float8 AS "spent",
               MAX(o."createdAt") AS "lastOrderAt"
        FROM "User" u
        LEFT JOIN "Order" o ON o."userId" = u."id"
        WHERE u."role" = 'CUSTOMER'
        GROUP BY u."id"
        ORDER BY "spent" DESC, u."createdAt" DESC, u."id" ASC
        LIMIT ${take} OFFSET ${skip}`,
      prisma.user.count({ where: { role: 'CUSTOMER' } }),
    ]);

    return ok(res, rows, { page: q.page, limit: q.limit, total });
  }),
);
