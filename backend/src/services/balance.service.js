import { Prisma } from '@prisma/client';
import { prisma } from '../config/db.js';
import { transactionRepository } from '../repositories/transaction.repository.js';
import { userRepository } from '../repositories/user.repository.js';

function toDecimal(amount) {
  return new Prisma.Decimal(amount);
}

export const balanceService = {
  async getBalance(userId) {
    const user = await userRepository.findById(userId);
    const transactions = await transactionRepository.listByUser(userId);
    return {
      balance: Number(user.balance),
      transactions,
    };
  },

  async addFunds(userId, amount, type = 'deposit') {
    return prisma.$transaction(async (tx) => {
      const user = await tx.user.findUnique({ where: { id: userId } });
      const newBalance = user.balance.plus(toDecimal(amount));
      await tx.user.update({ where: { id: userId }, data: { balance: newBalance } });
      await tx.transaction.create({ data: { userId, amount: toDecimal(amount), type, status: 'completed' } });
      return Number(newBalance);
    });
  },

  async subtractFunds(userId, amount, type = 'withdraw') {
    return prisma.$transaction(async (tx) => {
      const user = await tx.user.findUnique({ where: { id: userId } });
      const decimalAmount = toDecimal(amount);
      if (user.balance.lessThan(decimalAmount)) {
        throw new Error('Insufficient balance');
      }
      const newBalance = user.balance.minus(decimalAmount);
      await tx.user.update({ where: { id: userId }, data: { balance: newBalance } });
      await tx.transaction.create({ data: { userId, amount: decimalAmount, type, status: 'completed' } });
      return Number(newBalance);
    });
  },
};
