import { Router } from 'express';
import { balanceController } from '../controllers/balance.controller.js';
import { authRequired } from '../middleware/auth.middleware.js';

const router = Router();

router.get('/', authRequired, balanceController.getBalance);

export default router;
