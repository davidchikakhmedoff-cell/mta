import crypto from 'crypto';
import { env } from '../config/env.js';
import { balanceService } from './balance.service.js';

export const paymentService = {
  verifySignature(payload) {
    const expected = crypto
      .createHmac('sha256', env.paymentWebhookSecret)
      .update(`${payload.userId}:${payload.amount}:${payload.reference}`)
      .digest('hex');

    return expected === payload.signature;
  },

  async applyDeposit(userId, amount) {
    return balanceService.addFunds(userId, amount, 'deposit');
  },
};
