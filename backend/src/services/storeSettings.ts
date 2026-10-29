import { env } from '../config/env';
import { prisma } from '../lib/prisma';
import { AppError } from '../utils/errors';

const ID = 'main';

/** Do'kon vaqti bo'yicha bugungi kunning tugash lahzasi (UTC). */
export function endOfStoreDay(now = new Date()): Date {
  const offsetMs = env.STORE_UTC_OFFSET_MINUTES * 60_000;
  const local = new Date(now.getTime() + offsetMs);
  const nextMidnightLocal = Date.UTC(local.getUTCFullYear(), local.getUTCMonth(), local.getUTCDate() + 1);
  return new Date(nextMidnightLocal - offsetMs);
}

export async function getStoreStatus() {
  const row = await prisma.storeSettings.findUnique({ where: { id: ID } });
  const until = row?.ordersPausedUntil ?? null;
  const paused = until !== null && until.getTime() > Date.now();
  return { acceptingOrders: !paused, pausedUntil: paused ? until : null };
}

/** true — bugun buyurtma qabul qilinmaydi (kun oxirigacha), false — qaytadan qabul qilinadi. */
export async function setOrdersPaused(paused: boolean) {
  const ordersPausedUntil = paused ? endOfStoreDay() : null;
  await prisma.storeSettings.upsert({
    where: { id: ID },
    create: { id: ID, ordersPausedUntil },
    update: { ordersPausedUntil },
  });
  return getStoreStatus();
}

export async function assertAcceptingOrders() {
  if (!(await getStoreStatus()).acceptingOrders) throw AppError.conflict('ORDERS_PAUSED');
}
