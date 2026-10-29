import { PrismaClient, Role } from '@prisma/client';
import 'dotenv/config';

const prisma = new PrismaClient();

const categories = [
  { nameUz: 'Tortlar', nameEn: 'Cakes', nameRu: 'Торты', sortOrder: 1 },
  { nameUz: 'Pirojniylar', nameEn: 'Pastries', nameRu: 'Пирожные', sortOrder: 2 },
  { nameUz: 'Konfetlar', nameEn: 'Candies', nameRu: 'Конфеты', sortOrder: 3 },
  { nameUz: 'Pechenyelar', nameEn: 'Cookies', nameRu: 'Печенье', sortOrder: 4 },
];

async function main() {
  const email = process.env.SEED_ADMIN_EMAIL ?? 'admin@example.com';
  await prisma.user.upsert({
    where: { email },
    update: { role: Role.ADMIN },
    create: {
      email,
      firstName: process.env.SEED_ADMIN_FIRST_NAME ?? 'Admin',
      lastName: process.env.SEED_ADMIN_LAST_NAME ?? 'Shirinliklar',
      role: Role.ADMIN,
      isProfileComplete: true,
    },
  });

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
