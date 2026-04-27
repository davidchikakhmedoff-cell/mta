import { paymentService } from '../services/payment.service.js';

export const paymentController = {
  async webhook(req, res, next) {
    try {
      const payload = req.validated.body;
      if (!paymentService.verifySignature(payload)) {
        return res.status(401).json({ message: 'Invalid signature' });
      }
      const balance = await paymentService.applyDeposit(payload.userId, payload.amount);
      return res.json({ success: true, balance });
    } catch (error) {
      return next(error);
    }
  },
};
