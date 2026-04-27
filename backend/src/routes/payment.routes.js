import { Router } from 'express';
import { paymentController } from '../controllers/payment.controller.js';
import { validate } from '../middleware/validate.middleware.js';
import { paymentWebhookSchema } from '../models/schemas.js';

const router = Router();

router.post('/payment', validate(paymentWebhookSchema), paymentController.webhook);

export default router;
