import { createApp } from './app';
import { env } from './config/env';
import { prisma } from './lib/prisma';

const app = createApp();
const server = app.listen(env.PORT, () => {
  console.log(`Server ${env.PORT}-portda ishga tushdi`);
});

// Yuklama balanslagich (proxy) ulanishni serverdan oldin uzmasligi uchun.
server.keepAliveTimeout = 65_000;
server.headersTimeout = 66_000;

let shuttingDown = false;

async function shutdown(code = 0) {
  if (shuttingDown) return;
  shuttingDown = true;
  // Osilib qolgan ulanishlar tufayli to'xtash cheksiz cho'zilmasin.
  setTimeout(() => process.exit(code || 1), 10_000).unref();
  server.close(async () => {
    await prisma.$disconnect().catch(() => undefined);
    process.exit(code);
  });
}

process.on('SIGINT', () => void shutdown());
process.on('SIGTERM', () => void shutdown());
process.on('unhandledRejection', (reason) => {
  console.error('unhandledRejection:', reason);
});
process.on('uncaughtException', (err) => {
  console.error('uncaughtException:', err);
  void shutdown(1);
});
