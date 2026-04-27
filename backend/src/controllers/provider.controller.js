import { providerRepository } from '../repositories/provider.repository.js';

export const providerController = {
  async list(req, res, next) {
    try {
      const providers = await providerRepository.listAll();
      return res.json(providers);
    } catch (error) {
      return next(error);
    }
  },
};
