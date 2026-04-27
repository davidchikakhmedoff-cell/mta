import { balanceService } from './balance.service.js';
import { userRepository } from '../repositories/user.repository.js';
import { orderRepository } from '../repositories/order.repository.js';
import { providerRepository } from '../repositories/provider.repository.js';

export const adminService = {
  listUsers: () => userRepository.list(),
  listOrders: () => orderRepository.list(),
  listProviders: () => providerRepository.listAll(),
  blockUser: (userId) => userRepository.updateStatus(userId, 'blocked'),
  setProviderStatus: (providerId, status) => providerRepository.update(providerId, { status }),
  setProviderPriority: (providerId, priority) => providerRepository.update(providerId, { priority }),
  adjustBalance: async (userId, amount) => {
    if (amount >= 0) return balanceService.addFunds(userId, amount, 'deposit');
    return balanceService.subtractFunds(userId, Math.abs(amount), 'withdraw');
  },
};
