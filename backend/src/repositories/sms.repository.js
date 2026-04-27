import { prisma } from '../config/db.js';

export const smsRepository = {
  create: (data) => prisma.sms.create({ data }),
};
