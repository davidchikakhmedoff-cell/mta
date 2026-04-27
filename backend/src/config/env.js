import dotenv from 'dotenv';

dotenv.config();

export const env = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: Number(process.env.PORT || 4000),
  jwtSecret: process.env.JWT_SECRET || 'dev-secret',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '1d',
  databaseUrl: process.env.DATABASE_URL,
  paymentWebhookSecret: process.env.PAYMENT_WEBHOOK_SECRET || 'payment-secret',
  pollIntervalMs: Number(process.env.POLL_INTERVAL_MS || 10000),
  providerTimeoutMs: Number(process.env.PROVIDER_TIMEOUT_MS || 10000),
};
