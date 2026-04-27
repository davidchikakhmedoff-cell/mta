import { prisma } from '../config/db.js';

export const userRepository = {
  create: (data) => prisma.user.create({ data }),
  findByEmail: (email) => prisma.user.findUnique({ where: { email } }),
  findById: (id) => prisma.user.findUnique({ where: { id } }),
  updateBalance: (id, balance) => prisma.user.update({ where: { id }, data: { balance } }),
  updateStatus: (id, status) => prisma.user.update({ where: { id }, data: { status } }),
  list: () => prisma.user.findMany({ orderBy: { createdAt: 'desc' } }),
};
