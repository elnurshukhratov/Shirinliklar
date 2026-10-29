import { Router } from 'express';
import multer from 'multer';
import { detectImageType, uploadProductImage } from '../lib/storage';
import { asyncHandler } from '../utils/asyncHandler';
import { AppError } from '../utils/errors';
import { created } from '../utils/response';

export const adminUploadsRouter = Router();

const MAX_FILE_SIZE = 5 * 1024 * 1024;
const MAX_FILES = 8;
const ALLOWED_MIME = new Set(['image/jpeg', 'image/png', 'image/webp']);

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: MAX_FILE_SIZE, files: MAX_FILES },
  fileFilter: (_req, file, cb) => {
    if (ALLOWED_MIME.has(file.mimetype)) return cb(null, true);
    cb(new AppError(415, 'UNSUPPORTED_MEDIA_TYPE', 'INVALID_IMAGE_TYPE'));
  },
});

/** multipart/form-data, maydon nomi: "images" (bir nechta fayl). */
adminUploadsRouter.post(
  '/images',
  upload.array('images', MAX_FILES),
  asyncHandler(async (req, res) => {
    const files = (req.files ?? []) as Express.Multer.File[];
    if (files.length === 0) throw AppError.badRequest('NO_FILES');

    const typed = files.map((f) => {
      const type = detectImageType(f.buffer);
      if (!type) throw new AppError(415, 'UNSUPPORTED_MEDIA_TYPE', 'INVALID_IMAGE_TYPE');
      return { buffer: f.buffer, type };
    });

    const urls: string[] = [];
    for (const f of typed) urls.push(await uploadProductImage(f.buffer, f.type));

    return created(res, { urls });
  }),
);