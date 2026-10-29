/** +998 90 123 45 67, 901234567 va shu kabi ko'rinishlarni +998901234567 ga keltiradi. */
export function normalizePhone(raw: string): string {
  const cleaned = raw.replace(/[\s\-()]/g, '');
  const digits = cleaned.replace(/\D/g, '');
  if (cleaned.startsWith('+')) return `+${digits}`;
  if (digits.length === 9) return `+998${digits}`;
  return `+${digits}`;
}

export const isValidPhone = (v: string) => /^\+\d{9,15}$/.test(v);
