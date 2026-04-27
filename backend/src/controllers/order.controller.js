import { orderService } from '../services/order.service.js';

export const orderController = {
  async create(req, res, next) {
    try {
      const { service, country } = req.validated.body;
      const order = await orderService.createOrder(req.user.sub, service, country);
      return res.status(201).json(order);
    } catch (error) {
      return next(error);
    }
  },

  async status(req, res, next) {
    try {
      const { orderId } = req.validated.query;
      const order = await orderService.getOrderStatus(orderId, req.user.sub);
      return res.json(order);
    } catch (error) {
      return next(error);
    }
  },

  async cancel(req, res, next) {
    try {
      const { orderId } = req.validated.body;
      const result = await orderService.cancelOrder(orderId, req.user.sub);
      return res.json(result);
    } catch (error) {
      return next(error);
    }
  },
};
