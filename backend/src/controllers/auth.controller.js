import { authService } from '../services/auth.service.js';

export const authController = {
  async register(req, res, next) {
    try {
      const { email, password } = req.validated.body;
      const user = await authService.register(email, password);
      return res.status(201).json(user);
    } catch (error) {
      return next(error);
    }
  },

  async login(req, res, next) {
    try {
      const { email, password } = req.validated.body;
      const token = await authService.login(email, password);
      return res.json(token);
    } catch (error) {
      return next(error);
    }
  },
};
