import { Router } from 'express';
import { ownerForMethods, PANEL_ROLES, requireOwner, requireRole, requireUser } from '../middleware/auth';
import { ok } from '../utils/response';
import { adminCategoriesRouter } from './adminCategories';
import { adminOrdersRouter } from './adminOrders';
import { adminProductsRouter } from './adminProducts';
import { adminPromosRouter } from './adminPromos';
import { adminReviewsRouter } from './adminReviews';
import { adminStaffRouter } from './adminStaff';
import { adminStatsRouter } from './adminStats';
import { adminStoreRouter } from './adminStore';
import { adminUploadsRouter } from './adminUploads';

export const adminRouter = Router();

// Panelga do'kon egasi ham, xodim ham kira oladi; nozik bo'limlar quyida faqat egasiga ochiladi.
adminRouter.use(requireUser, requireRole(...PANEL_ROLES));

adminRouter.get('/ping', (req, res) => ok(res, { role: req.user!.role }));

// Xodim: buyurtmalar, mahsulotlar (o'chirishsiz), izohlar, yuklash va "bugun qabul qilmaymiz".
adminRouter.use('/orders', adminOrdersRouter);
adminRouter.use('/products', ownerForMethods('DELETE'), adminProductsRouter);
adminRouter.use('/uploads', adminUploadsRouter);
adminRouter.use('/reviews', adminReviewsRouter);
adminRouter.use('/store', adminStoreRouter);

// Toifalarni xodim faqat ko'ra oladi.
adminRouter.use('/categories', ownerForMethods('POST', 'PUT', 'PATCH', 'DELETE'), adminCategoriesRouter);

// Faqat do'kon egasi: statistika, promokodlar va xodimlarni boshqarish.
adminRouter.use('/stats', requireOwner, adminStatsRouter);
adminRouter.use('/promos', requireOwner, adminPromosRouter);
adminRouter.use('/staff', requireOwner, adminStaffRouter);
