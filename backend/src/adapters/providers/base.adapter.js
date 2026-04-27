import axios from 'axios';
import { env } from '../../config/env.js';

export class BaseProviderAdapter {
  constructor(provider) {
    this.provider = provider;
    this.client = axios.create({
      baseURL: provider.apiUrl,
      timeout: env.providerTimeoutMs,
      headers: { 'X-API-Key': provider.apiKey },
    });
  }

  async withRetry(fn, attempts = 3) {
    let lastErr;
    for (let i = 0; i < attempts; i += 1) {
      try {
        return await fn();
      } catch (error) {
        lastErr = error;
      }
    }
    throw lastErr;
  }

  async requestNumber() {
    throw new Error('requestNumber not implemented');
  }

  async checkSms() {
    throw new Error('checkSms not implemented');
  }

  async cancelActivation() {
    throw new Error('cancelActivation not implemented');
  }
}
