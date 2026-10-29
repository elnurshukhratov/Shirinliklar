import jwt from 'jsonwebtoken';
import { env, isProd } from '../config/env';

const DEV_SECRET = 'dev-only-secret-do-not-use-in-production-0000';

function secret(): string {
  if (env.JWT_SECRET) return env.JWT_SECRET;
  if (isProd) throw new Error('JWT_SECRET sozlanmagan');
  return DEV_SECRET;
}

export function signToken(userId: string): string {
  return jwt.sign({}, secret(), {
    algorithm: 'HS256',
    subject: userId,
    expiresIn: env.JWT_EXPIRES_DAYS * 24 * 60 * 60,
  });
}

/** Token to'g'ri bo'lsa foydalanuvchi id'sini qaytaradi, aks holda xato tashlaydi. */
export function verifyToken(token: string): string {
  const payload = jwt.verify(token, secret(), { algorithms: ['HS256'] });
  if (typeof payload === 'string' || !payload.sub) throw new Error('INVALID_TOKEN');
  return payload.sub;
}