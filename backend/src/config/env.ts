import 'dotenv/config';
import { z } from 'zod';

const schema = z
  .object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().int().positive().default(4000),
  DATABASE_URL: z.string().min(1),
  CORS_ORIGINS: z.string().default('*'),
  FIREBASE_PROJECT_ID: z.string().optional(),
  FIREBASE_CLIENT_EMAIL: z.string().optional(),
  FIREBASE_PRIVATE_KEY: z.string().optional(),
  STORAGE_BUCKET: z.string().optional(),
  STORAGE_PUBLIC_URL: z.string().optional(),
  DELIVERY_FEE: z.coerce.number().min(0).default(0),
  ORDER_MIN_LEAD_MINUTES: z.coerce.number().int().min(0).default(60),
  ORDER_MAX_DAYS_AHEAD: z.coerce.number().int().min(1).default(60),
  STORE_UTC_OFFSET_MINUTES: z.coerce.number().int().min(-720).max(840).default(300),
  PUBLIC_BASE_URL: z.string().optional(),
  PAYMENT_PROVIDER: z.enum(['click']).default('click'),
  CLICK_SERVICE_ID: z.string().optional(),
  CLICK_MERCHANT_ID: z.string().optional(),
  CLICK_MERCHANT_USER_ID: z.string().optional(),
  CLICK_SECRET_KEY: z.string().optional(),
  })
  .superRefine((v, ctx) => {
    if (v.NODE_ENV !== 'production') return;
    const problem = (key: string, message: string) => ctx.addIssue({ code: 'custom', path: [key], message });

    // Production'da majburiy sozlamalar bo'sh qolsa, server ishga tushmaydi.
    const required = [
      'FIREBASE_PROJECT_ID',
      'FIREBASE_CLIENT_EMAIL',
      'FIREBASE_PRIVATE_KEY',
      'STORAGE_BUCKET',
      'STORAGE_PUBLIC_URL',
      'PUBLIC_BASE_URL',
    ] as const;
    for (const key of required) {
      if (!v[key]) problem(key, 'Production uchun majburiy');
    }
    if (v.PAYMENT_PROVIDER === 'click') {
      for (const key of ['CLICK_SERVICE_ID', 'CLICK_MERCHANT_ID', 'CLICK_MERCHANT_USER_ID', 'CLICK_SECRET_KEY'] as const) {
        if (!v[key]) problem(key, "Onlayn to'lov (click) uchun majburiy");
      }
    }
    for (const key of ['PUBLIC_BASE_URL', 'STORAGE_PUBLIC_URL'] as const) {
      const value = v[key];
      if (value && !value.startsWith('https://')) problem(key, 'Production uchun https:// bilan boshlanishi shart');
    }
    if (v.CORS_ORIGINS.split(',').some((o) => o.trim() === '*')) {
      problem('CORS_ORIGINS', "Production'da \"*\" bo'lmaydi, aniq manzillarni yozing");
    }
  });

const parsed = schema.safeParse(process.env);
if (!parsed.success) {
  console.error("Env sozlamalari noto'g'ri:", parsed.error.flatten().fieldErrors);
  process.exit(1);
}

export const env = parsed.data;
export const isProd = env.NODE_ENV === 'production';
