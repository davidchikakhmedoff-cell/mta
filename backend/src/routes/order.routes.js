import { Router } from 'express';
import { orderController } from '../controllers/order.controller.js';
import { authRequired } from '../middleware/auth.middleware.js';
import { validate } from '../middleware/validate.middleware.js';
import { orderCancelSchema, orderCreateSchema, orderStatusSchema } from '../models/schemas.js';

const router = Router();

router.post('/create', authRequired, validate(orderCreateSchema), orderController.create);
router.get('/status', authRequired, validate(orderStatusSchema), orderController.status);
router.post('/cancel', authRequired, validate(orderCancelSchema), orderController.cancel);

export default router;
