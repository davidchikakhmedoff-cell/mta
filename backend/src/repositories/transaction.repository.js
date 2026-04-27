import { prisma } from '../config/db.js';

export const transactionRepository = {
  create: (data) => prisma.transaction.create({ data }),
  listByUser: (userId) => prisma.transaction.findMany({ where: { userId }, orderBy: { createdAt: 'desc' } }),
};
