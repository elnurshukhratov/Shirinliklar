import { z } from 'zod';

export type I18n = { uz: string; en: string; ru: string };
type Keys<K extends string> = `${K}Uz` | `${K}En` | `${K}Ru`;

/** Uch tilli maydon sxemasi: { uz, en, ru }. */
export const langs = <T extends z.ZodTypeAny>(schema: T) =>
  z.object({ uz: schema, en: schema, ru: schema });

/** { uz, en, ru } -> nameUz, nameEn, nameRu */
export function flatAll<K extends string>(base: K, v: I18n): Record<Keys<K>, string> {
  return {
    [`${base}Uz`]: v.uz,
    [`${base}En`]: v.en,
    [`${base}Ru`]: v.ru,
  } as Record<Keys<K>, string>;
}

/** Faqat berilgan tillarni qaytaradi (tahrirlash uchun). */
export function flatPartial<K extends string>(base: K, v?: Partial<I18n>): Partial<Record<Keys<K>, string>> {
  const out: Record<string, string> = {};
  if (v?.uz !== undefined) out[`${base}Uz`] = v.uz;
  if (v?.en !== undefined) out[`${base}En`] = v.en;
  if (v?.ru !== undefined) out[`${base}Ru`] = v.ru;
  return out as Partial<Record<Keys<K>, string>>;
}

/** nameUz, nameEn, nameRu -> { uz, en, ru } */
export function pack(row: Record<string, unknown>, base: string): I18n {
  return {
    uz: String(row[`${base}Uz`] ?? ''),
    en: String(row[`${base}En`] ?? ''),
    ru: String(row[`${base}Ru`] ?? ''),
  };
}