import { prisma } from '../config/db.js';
import { env } from '../config/env.js';
import { orderService } from '../services/order.service.js';
import { logger } from '../utils/logger.js';

export function startSmsPoller() {
  setInterval(async () => {
    const activeOrders = await prisma.order.findMany({
      where: { status: 'active' },
      include: { provider: true },
    });

    for (const order of activeOrders) {
      try {
        await orderService.pollForSms(order);
      } catch (error) {
        logger.warn({ orderId: order.id, error: error.message }, 'SMS poll failed');
      }
    }
  }, env.pollIntervalMs);
}
