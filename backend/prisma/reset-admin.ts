import { PrismaClient, Role } from '@prisma/client';
import bcrypt from 'bcryptjs';
import 'dotenv/config';

const prisma = new PrismaClient();

async function main() {
  const email = (process.env.SEED_ADMIN_EMAIL ?? '').toLowerCase();
  const username = (process.env.ADMIN_USERNAME ?? 'admin').toLowerCase();
  const password = process.env.ADMIN_NEW_PASSWORD;
  if (!email || !password) throw new Error('SEED_ADMIN_EMAIL va ADMIN_NEW_PASSWORD kerak');

  const user = await prisma.user.findUnique({ where: { email } });
  console.log('Hozirgi holat:', user && {
    username: user.username, role: user.role, parolBor: !!user.passwordHash,
  });

  const taken = await prisma.user.findUnique({ where: { username } });
  if (taken && taken.email !== email) throw new Error(`"${username}" username boshqa hisobda band`);

  const data = {
    username,
    passwordHash: await bcrypt.hash(password, 10),
    role: Role.ADMIN,
    isProfileComplete: true,
  };
  if (user) {
    await prisma.user.update({ where: { id: user.id }, data });
  } else {
    await prisma.user.create({ data: { email, firstName: 'Elnur', lastName: 'Shuhratov', ...data } });
  }
  console.log('Tayyor. Login:', username, 'yoki', email);
}

main().catch((e) => { console.error(e); process.exit(1); }).finally(() => prisma.$disconnect());