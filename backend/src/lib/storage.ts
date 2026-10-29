import { randomUUID } from 'crypto';
import { getStorage } from 'firebase-admin/storage';
import { env } from '../config/env';
import { AppError } from '../utils/errors';
import { getFirebaseApp } from './firebase';

export type ImageType = { ext: 'jpg' | 'png' | 'webp'; mime: string };

function bucket() {
  if (!env.STORAGE_BUCKET || !env.STORAGE_PUBLIC_URL) {
    throw new AppError(503, 'SERVICE_UNAVAILABLE', 'STORAGE_NOT_CONFIGURED');
  }
  return getStorage(getFirebaseApp()).bucket(env.STORAGE_BUCKET);
}

function publicBase(): string {
  return (env.STORAGE_PUBLIC_URL ?? '').replace(/\/+$/, '');
}

/** Faylning haqiqiy turini birinchi baytlar bo'yicha aniqlaydi (mijoz yuborgan turga ishonilmaydi). */
export function detectImageType(buf: Buffer): ImageType | null {
  if (buf.length >= 3 && buf[0] === 0xff && buf[1] === 0xd8 && buf[2] === 0xff) {
    return { ext: 'jpg', mime: 'image/jpeg' };
  }
  if (
    buf.length >= 8 &&
    buf[0] === 0x89 &&
    buf[1] === 0x50 &&
    buf[2] === 0x4e &&
    buf[3] === 0x47
  ) {
    return { ext: 'png', mime: 'image/png' };
  }
  if (
    buf.length >= 12 &&
    buf.toString('ascii', 0, 4) === 'RIFF' &&
    buf.toString('ascii', 8, 12) === 'WEBP'
  ) {
    return { ext: 'webp', mime: 'image/webp' };
  }
  return null;
}

export async function uploadProductImage(buf: Buffer, type: ImageType): Promise<string> {
  const path = `products/${randomUUID()}.${type.ext}`;
  await bucket().file(path).save(buf, {
    contentType: type.mime,
    resumable: false,
    metadata: { cacheControl: 'public, max-age=31536000, immutable' },
  });
  return `${publicBase()}/${path}`;
}

/** Manzil bizning saqlash joyimizdagi mahsulot rasmiga tegishlimi. */
export function isOwnImageUrl(url: string): boolean {
  if (!env.STORAGE_PUBLIC_URL) return false;
  return url.startsWith(`${publicBase()}/products/`);
}

/** Rasmlarni o'chiradi; xato bo'lsa so'rovni buzmaydi. */
export async function deleteImagesByUrl(urls: string[]): Promise<void> {
  const own = urls.filter(isOwnImageUrl);
  if (own.length === 0) return;
  try {
    const b = bucket();
    await Promise.all(
      own.map((url) => b.file(url.slice(publicBase().length + 1)).delete({ ignoreNotFound: true })),
    );
  } catch (e) {
    console.error("Rasmlarni o'chirishda xato:", e);
  }
}