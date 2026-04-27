import { prisma } from '../config/db.js';

export const orderRepository = {
  create: (data) => prisma.order.create({ data }),
  findById: (id) => prisma.order.findUnique({ where: { id }, include: { sms: true } }),
  findByPartnerRef: (partnerRef) => prisma.order.findFirst({ where: { partnerRef }, include: { provider: true } }),
  update: (id, data) => prisma.order.update({ where: { id }, data }),
  list: () => prisma.order.findMany({ include: { user: true, provider: true }, orderBy: { createdAt: 'desc' } }),
};
