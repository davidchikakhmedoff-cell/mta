import { Router } from 'express';
import { providerController } from '../controllers/provider.controller.js';

const router = Router();

router.get('/', providerController.list);

export default router;
