import { adminService } from '../services/admin.service.js';

export const adminController = {
  listUsers: async (req, res, next) => {
    try {
      return res.json(await adminService.listUsers());
    } catch (error) {
      return next(error);
    }
  },
  listOrders: async (req, res, next) => {
    try {
      return res.json(await adminService.listOrders());
    } catch (error) {
      return next(error);
    }
  },
  listProviders: async (req, res, next) => {
    try {
      return res.json(await adminService.listProviders());
    } catch (error) {
      return next(error);
    }
  },
  blockUser: async (req, res, next) => {
    try {
      return res.json(await adminService.blockUser(req.params.userId));
    } catch (error) {
      return next(error);
    }
  },
  adjustBalance: async (req, res, next) => {
    try {
      const { amount } = req.body;
      return res.json({ balance: await adminService.adjustBalance(req.params.userId, Number(amount)) });
    } catch (error) {
      return next(error);
    }
  },
  updateProvider: async (req, res, next) => {
    try {
      const { status, priority } = req.body;
      const updates = [];
      if (status) updates.push(await adminService.setProviderStatus(req.params.providerId, status));
      if (priority !== undefined) updates.push(await adminService.setProviderPriority(req.params.providerId, Number(priority)));
      return res.json({ updated: updates.length });
    } catch (error) {
      return next(error);
    }
  },
};
