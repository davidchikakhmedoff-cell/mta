import { z } from 'zod';

export const registerSchema = z.object({
  body: z.object({
    email: z.string().email(),
    password: z.string().min(8),
  }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

export const loginSchema = registerSchema;

export const orderCreateSchema = z.object({
  body: z.object({
    service: z.string().min(1),
    country: z.string().min(1),
  }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

export const orderStatusSchema = z.object({
  query: z.object({
    orderId: z.string().uuid(),
  }),
  body: z.object({}).optional(),
  params: z.object({}).optional(),
});

export const orderCancelSchema = z.object({
  body: z.object({
    orderId: z.string().uuid(),
  }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});

export const paymentWebhookSchema = z.object({
  body: z.object({
    userId: z.string().uuid(),
    amount: z.number().positive(),
    reference: z.string().min(2),
    signature: z.string().min(8),
  }),
  query: z.object({}).optional(),
  params: z.object({}).optional(),
});
