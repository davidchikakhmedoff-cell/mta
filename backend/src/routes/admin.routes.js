import { Router } from 'express';
import { adminController } from '../controllers/admin.controller.js';
import { adminOnly, authRequired } from '../middleware/auth.middleware.js';

const router = Router();

router.use(authRequired, adminOnly);
router.get('/users', adminController.listUsers);
router.patch('/users/:userId/block', adminController.blockUser);
router.patch('/users/:userId/balance', adminController.adjustBalance);
router.get('/orders', adminController.listOrders);
router.get('/providers', adminController.listProviders);
router.patch('/providers/:providerId', adminController.updateProvider);

export default router;
