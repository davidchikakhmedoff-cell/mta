import { prisma } from '../config/db.js';

export const providerRepository = {
  listEnabledByPriority: () =>
    prisma.provider.findMany({ where: { status: 'enabled' }, orderBy: { priority: 'asc' } }),
  listAll: () => prisma.provider.findMany({ orderBy: { priority: 'asc' } }),
  update: (id, data) => prisma.provider.update({ where: { id }, data }),
};
