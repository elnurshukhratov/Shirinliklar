import { PrismaClient, Role } from '@prisma/client';
import bcrypt from 'bcryptjs';
import 'dotenv/config';

const prisma = new PrismaClient();

const categories = [
  { nameUz: 'Tortlar', nameEn: 'Cakes', nameRu: 'Торты', sortOrder: 1 },
  { nameUz: 'Pirojniylar', nameEn: 'Pastries', nameRu: 'Пирожные', sortOrder: 2 },
  { nameUz: 'Konfetlar', nameEn: 'Candies', nameRu: 'Конфеты', sortOrder: 3 },
  { nameUz: 'Pechenyelar', nameEn: 'Cookies', nameRu: 'Печенье', sortOrder: 4 },
];

async function main() {
  const email = (process.env.SEED_ADMIN_EMAIL ?? 'admin@example.com').toLowerCase();
  const username = (process.env.SEED_ADMIN_USERNAME ?? 'admin').toLowerCase();
  const password = process.env.SEED_ADMIN_PASSWORD ?? 'admin';

  const existing = await prisma.user.findUnique({ where: { email } });
  if (!existing) {
    await prisma.user.create({
      data: {
        email,
        username,
        passwordHash: await bcrypt.hash(password, 10),
        firstName: process.env.SEED_ADMIN_FIRST_NAME ?? 'Admin',
        lastName: process.env.SEED_ADMIN_LAST_NAME ?? 'Shirinliklar',
        role: Role.ADMIN,
        isProfileComplete: true,
      },
    });
  } else {
    // Qayta seed qilinganda egasi o'zgartirgan username/parol bosilib ketmasligi uchun faqat bo'sh joylar to'ldiriladi.
    await prisma.user.update({
      where: { id: existing.id },
      data: {
        role: Role.ADMIN,
        ...(existing.passwordHash ? {} : { passwordHash: await bcrypt.hash(password, 10) }),
        ...(existing.username ? {} : { username }),
      },
    });
  }

  if ((await prisma.category.count()) === 0) {
    await prisma.category.createMany({ data: categories });
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());