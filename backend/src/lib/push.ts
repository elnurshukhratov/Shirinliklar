import { Language } from '@prisma/client';
import { getMessaging } from 'firebase-admin/messaging';
import { getFirebaseApp } from './firebase';
import { prisma } from './prisma';

export interface PushMessage {
  title: string;
  body: string;
  /** FCM data qiymatlari faqat matn bo'lishi mumkin. */
  data?: Record<string, string>;
}

const DEAD_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
]);

/**
 * Foydalanuvchilarning barcha qurilmalariga (har birining tilida) bildirishnoma yuboradi.
 * Hech qachon xato tashlamaydi: bildirishnoma ketmasa ham asosiy amal buzilmasligi kerak.
 */
export async function sendPush(userIds: string[], build: (lang: Language) => PushMessage): Promise<void> {
  try {
    if (userIds.length === 0) return;
    const tokens = await prisma.deviceToken.findMany({
      where: { userId: { in: userIds } },
      select: { token: true, language: true },
    });
    if (tokens.length === 0) return;

    const messaging = getMessaging(getFirebaseApp());
    const byLang = new Map<Language, string[]>();
    for (const t of tokens) byLang.set(t.language, [...(byLang.get(t.language) ?? []), t.token]);

    const dead: string[] = [];
    for (const [lang, list] of byLang) {
      const msg = build(lang);
      for (let i = 0; i < list.length; i += 500) {
        const chunk = list.slice(i, i + 500);
        const res = await messaging.sendEachForMulticast({
          tokens: chunk,
          notification: { title: msg.title, body: msg.body },
          data: msg.data,
          android: { priority: 'high' },
        });
        res.responses.forEach((r, idx) => {
          if (!r.success && r.error && DEAD_TOKEN_CODES.has(r.error.code)) dead.push(chunk[idx]);
        });
      }
    }

    if (dead.length > 0) await prisma.deviceToken.deleteMany({ where: { token: { in: dead } } });
  } catch (e) {
    console.error('Bildirishnoma yuborishda xato:', e);
  }
}
