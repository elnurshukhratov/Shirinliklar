import { FulfillmentType, Language, OrderStatus, Role } from '@prisma/client';
import { prisma } from '../lib/prisma';
import { PushMessage, sendPush } from '../lib/push';
import { pack } from '../utils/i18n';

type Lang = 'uz' | 'en' | 'ru';
const key = (l: Language): Lang => l.toLowerCase() as Lang;

function sum(value: number, lang: Lang): string {
  const n = new Intl.NumberFormat('ru-RU').format(Math.round(value)).replace(/\s/g, ' ');
  return lang === 'en' ? `${n} UZS` : lang === 'ru' ? `${n} сум` : `${n} so'm`;
}

const orderTexts: Partial<
  Record<OrderStatus, Record<Lang, (n: number, o: { reason: string | null; delivery: boolean }) => [string, string]>>
> = {
  [OrderStatus.ACCEPTED]: {
    uz: (n) => [`Buyurtma №${n} qabul qilindi`, 'Shirinliklaringiz tayyorlanmoqda.'],
    en: (n) => [`Order #${n} accepted`, 'Your treats are being prepared.'],
    ru: (n) => [`Заказ №${n} принят`, 'Ваши сладости готовятся.'],
  },
  [OrderStatus.CANCELLED]: {
    uz: (n, o) => [`Buyurtma №${n} bekor qilindi`, o.reason ?? "Batafsil ma'lumot ilovada."],
    en: (n, o) => [`Order #${n} cancelled`, o.reason ?? 'See the app for details.'],
    ru: (n, o) => [`Заказ №${n} отменён`, o.reason ?? 'Подробности в приложении.'],
  },
  [OrderStatus.READY]: {
    uz: (n, o) => [`Buyurtma №${n} tayyor`, o.delivery ? "Tez orada yo'lga chiqadi." : 'Olib ketishingiz mumkin.'],
    en: (n, o) => [`Order #${n} is ready`, o.delivery ? 'It will be on its way soon.' : 'You can pick it up.'],
    ru: (n, o) => [`Заказ №${n} готов`, o.delivery ? 'Скоро отправится к вам.' : 'Можно забирать.'],
  },
  [OrderStatus.ON_THE_WAY]: {
    uz: (n) => [`Buyurtma №${n} yo'lda`, 'Buyurtmangiz yetkazilmoqda.'],
    en: (n) => [`Order #${n} is on the way`, 'Your order is being delivered.'],
    ru: (n) => [`Заказ №${n} в пути`, 'Ваш заказ доставляется.'],
  },
};

/** Mijozga: buyurtma qabul qilindi, bekor qilindi, tayyor yoki yo'lda. Boshqa holatlarda hech narsa yubormaydi. */
export async function notifyOrderStatus(orderId: string): Promise<void> {
  try {
    const order = await prisma.order.findUnique({ where: { id: orderId } });
    const texts = order && orderTexts[order.status];
    if (!order || !texts) return;

    const opts = { reason: order.cancelReason, delivery: order.fulfillment === FulfillmentType.DELIVERY };
    await sendPush([order.userId], (lang): PushMessage => {
      const [title, body] = texts[key(lang)](order.number, opts);
      return { title, body, data: { type: 'ORDER_STATUS', orderId: order.id } };
    });
  } catch (e) {
    console.error('Buyurtma holati bildirishnomasi:', e);
  }
}

/** Adminlarga: yangi buyurtma keldi. */
export async function notifyNewOrder(orderId: string): Promise<void> {
  try {
    const order = await prisma.order.findUnique({ where: { id: orderId } });
    if (!order) return;
    const admins = await prisma.user.findMany({ where: { role: { in: [Role.ADMIN, Role.STAFF] } }, select: { id: true } });

    await sendPush(admins.map((a) => a.id), (lang): PushMessage => {
      const l = key(lang);
      const title =
        l === 'en' ? `New order #${order.number}` : l === 'ru' ? `Новый заказ №${order.number}` : `Yangi buyurtma №${order.number}`;
      const total = sum(Number(order.total), l);
      const body = l === 'en' ? `Total: ${total}` : l === 'ru' ? `Итого: ${total}` : `Jami: ${total}`;
      return { title, body, data: { type: 'NEW_ORDER', orderId: order.id } };
    });
  } catch (e) {
    console.error('Yangi buyurtma bildirishnomasi:', e);
  }
}

/**
 * Miqdori qaytgan (ombor > 0, ko'rinadigan) mahsulotlarga obuna bo'lgan mijozlarga xabar beradi.
 * Obuna avval o'chiriladi (shartli), shuning uchun bir vaqtda chaqirilsa ham xabar ikki marta ketmaydi.
 */
export async function notifyRestocked(productIds: string[]): Promise<void> {
  try {
    const ids = [...new Set(productIds)];
    if (ids.length === 0) return;

    const subs = await prisma.stockSubscription.findMany({
      where: {
        productId: { in: ids },
        product: { stock: { gt: 0 }, isActive: true, OR: [{ categoryId: null }, { category: { isActive: true } }] },
      },
      include: { product: true },
    });

    const perProduct = new Map<string, { product: (typeof subs)[number]['product']; userIds: string[] }>();
    for (const sub of subs) {
      const claimed = await prisma.stockSubscription.deleteMany({
        where: { userId: sub.userId, productId: sub.productId },
      });
      if (claimed.count !== 1) continue;
      const entry = perProduct.get(sub.productId) ?? { product: sub.product, userIds: [] };
      entry.userIds.push(sub.userId);
      perProduct.set(sub.productId, entry);
    }

    for (const { product, userIds } of perProduct.values()) {
      const name = pack(product, 'name');
      await sendPush(userIds, (lang): PushMessage => {
        const l = key(lang);
        const n = name[l] || name.uz;
        return {
          title: l === 'en' ? `${n} is back in stock` : l === 'ru' ? `${n} снова в наличии` : `${n} yana mavjud`,
          body:
            l === 'en'
              ? 'Open the app to order it.'
              : l === 'ru'
                ? 'Откройте приложение, чтобы заказать.'
                : 'Buyurtma berish uchun ilovani oching.',
          data: { type: 'BACK_IN_STOCK', productId: product.id },
        };
      });
    }
  } catch (e) {
    console.error('Mavjud bo\'lganda xabar:', e);
  }
}

/** Buyurtma bekor bo'lib ombor miqdori qaytgach, shu buyurtmadagi mahsulotlar uchun obunachilarga xabar beradi. */
export async function notifyOrderRestock(orderId: string): Promise<void> {
  try {
    const items = await prisma.orderItem.findMany({
      where: { orderId, productId: { not: null } },
      select: { productId: true },
    });
    await notifyRestocked(items.map((i) => i.productId!));
  } catch (e) {
    console.error('Qayta mavjud bildirishnomasi:', e);
  }
}
