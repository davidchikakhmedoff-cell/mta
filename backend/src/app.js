import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import pinoHttp from 'pino-http';
import authRoutes from './routes/auth.routes.js';
import balanceRoutes from './routes/balance.routes.js';
import orderRoutes from './routes/order.routes.js';
import providerRoutes from './routes/provider.routes.js';
import paymentRoutes from './routes/payment.routes.js';
import adminRoutes from './routes/admin.routes.js';
import { apiRateLimit } from './middleware/rate-limit.middleware.js';
import { errorHandler } from './middleware/error.middleware.js';
import { logger } from './utils/logger.js';

export const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan('combined'));
app.use(pinoHttp({ logger }));
app.use(apiRateLimit);

app.get('/health', (req, res) => res.json({ status: 'ok' }));
app.use('/auth', authRoutes);
app.use('/balance', balanceRoutes);
app.use('/order', orderRoutes);
app.use('/providers', providerRoutes);
app.use('/webhook', paymentRoutes);
app.use('/admin', adminRoutes);

app.use(errorHandler);
