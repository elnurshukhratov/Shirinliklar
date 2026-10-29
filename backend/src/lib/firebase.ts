import { App, cert, getApps, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { env } from '../config/env';
import { AppError } from '../utils/errors';

export function getFirebaseApp(): App {
  const existing = getApps()[0];
  if (existing) return existing;

  if (!env.FIREBASE_PROJECT_ID || !env.FIREBASE_CLIENT_EMAIL || !env.FIREBASE_PRIVATE_KEY) {
    throw new AppError(503, 'SERVICE_UNAVAILABLE', 'AUTH_NOT_CONFIGURED');
  }

  return initializeApp({
    credential: cert({
      projectId: env.FIREBASE_PROJECT_ID,
      clientEmail: env.FIREBASE_CLIENT_EMAIL,
      privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
    }),
  });
}

export function firebaseAuth() {
  return getAuth(getFirebaseApp());
}