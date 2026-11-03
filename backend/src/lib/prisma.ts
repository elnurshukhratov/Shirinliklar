import { PrismaClient } from '@prisma/client';

export const prisma = new PrismaClient();

const sleep = (ms: number) => new Promise<void>((resolve) => setTimeout(resolve, ms));

/**
 * Server ishga tushganda baza hali tayyor bo'lmasligi mumkin (masalan, server qayta yoqilganda
 * PostgreSQL biroz kechroq ko'tariladi). Shu uchun ulanish bir necha marta qayta uriniladi.
 * Ulanib bo'lmasa ham server to'xtamaydi: so'rovlar bazaga qayta ulanishga harakat qiladi.
 */
export async function connectDatabase(attempts = 30, delayMs = 2000): Promise<boolean> {
  for (let i = 1; i <= attempts; i += 1) {
    try {
      await prisma.$connect();
      await prisma.$queryRaw`SELECT 1`;
      console.log('Ma\'lumotlar bazasiga ulandi');
      return true;
    } catch (err) {
      console.error(`Bazaga ulanib bo'lmadi (${i}/${attempts}):`, (err as Error).message.split('\n').pop());
      if (i < attempts) await sleep(delayMs);
    }
  }
  return false;
}