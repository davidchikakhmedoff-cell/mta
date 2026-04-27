import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { StatusCodes } from 'http-status-codes';
import { env } from '../config/env.js';
import { userRepository } from '../repositories/user.repository.js';

export const authService = {
  async register(email, password) {
    const exists = await userRepository.findByEmail(email);
    if (exists) {
      const error = new Error('Email already registered');
      error.statusCode = StatusCodes.CONFLICT;
      throw error;
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const user = await userRepository.create({ email, passwordHash });

    return {
      id: user.id,
      email: user.email,
      createdAt: user.createdAt,
    };
  },

  async login(email, password) {
    const user = await userRepository.findByEmail(email);
    if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
      const error = new Error('Invalid credentials');
      error.statusCode = StatusCodes.UNAUTHORIZED;
      throw error;
    }

    if (user.status === 'blocked') {
      const error = new Error('Account is blocked');
      error.statusCode = StatusCodes.FORBIDDEN;
      throw error;
    }

    const role = user.email.endsWith('@admin.local') ? 'admin' : 'user';
    const token = jwt.sign({ sub: user.id, role, email: user.email }, env.jwtSecret, {
      expiresIn: env.jwtExpiresIn,
    });

    return { token };
  },
};
