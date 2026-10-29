import bcrypt from 'bcryptjs';

export const USERNAME_RE = /^[a-z0-9_.]{3,24}$/;

/** Oddiy foydalanuvchi ro'yxatdan o'tishda ololmaydigan nomlar. */
export const RESERVED_USERNAMES = new Set(['admin', 'administrator', 'root', 'support', 'shirinliklar']);

export const hashPassword = (password: string) => bcrypt.hash(password, 10);
export const verifyPassword = (password: string, hash: string) => bcrypt.compare(password, hash);