import { orderRepository } from '../repositories/order.repository.js';
import { userRepository } from '../repositories/user.repository.js';
import { balanceService } from './balance.service.js';
import { providerRouterService } from './provider-router.service.js';
import { createProviderAdapter } from '../adapters/providers/index.js';
import { smsRepository } from '../repositories/sms.repository.js';

export const orderService = {
  async createOrder(userId, service, country) {
    const user = await userRepository.findById(userId);
    if (user.status === 'blocked') {
      throw new Error('User blocked');
    }

    const { provider, allocation } = await providerRouterService.requestNumberWithFailover(service, country);

    if (Number(user.balance) < allocation.price) {
      throw new Error('Insufficient balance');
    }

    await balanceService.subtractFunds(userId, allocation.price, 'purchase');

    return orderRepository.create({
      userId,
      providerId: provider.id,
      service,
      country,
      number: allocation.number,
      partnerRef: allocation.partnerRef,
      price: allocation.price,
      status: 'active',
    });
  },

  async getOrderStatus(orderId, userId) {
    const order = await orderRepository.findById(orderId);
    if (!order || order.userId !== userId) {
      throw new Error('Order not found');
    }
    return order;
  },

  async pollForSms(order) {
    const adapter = createProviderAdapter(order.provider);
    const result = await adapter.checkSms(order.partnerRef);

    if (result.status === 'received' && result.message) {
      await smsRepository.create({ orderId: order.id, message: result.message });
      await orderRepository.update(order.id, { status: 'received' });
    }

    return result;
  },

  async cancelOrder(orderId, userId) {
    const order = await orderRepository.findById(orderId);
    if (!order || order.userId !== userId) {
      throw new Error('Order not found');
    }
    if (!['active', 'pending'].includes(order.status)) {
      throw new Error('Order cannot be cancelled');
    }

    const adapter = createProviderAdapter(order.provider);
    await adapter.cancelActivation(order.partnerRef);
    await orderRepository.update(order.id, { status: 'cancelled' });
    await balanceService.addFunds(order.userId, Number(order.price), 'refund');

    return { success: true };
  },
};
