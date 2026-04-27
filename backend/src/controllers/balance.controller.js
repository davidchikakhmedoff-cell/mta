import { balanceService } from '../services/balance.service.js';

export const balanceController = {
  async getBalance(req, res, next) {
    try {
      const userId = req.user.sub;
      const result = await balanceService.getBalance(userId);
      return res.json(result);
    } catch (error) {
      return next(error);
    }
  },
};
