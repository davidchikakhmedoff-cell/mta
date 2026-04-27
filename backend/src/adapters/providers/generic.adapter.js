import { BaseProviderAdapter } from './base.adapter.js';

export class GenericProviderAdapter extends BaseProviderAdapter {
  async requestNumber(service, country) {
    return this.withRetry(async () => {
      const { data } = await this.client.post('/activation/request', { service, country });
      return {
        number: data.number,
        price: Number(data.price),
        partnerRef: data.activationId,
      };
    });
  }

  async checkSms(partnerRef) {
    return this.withRetry(async () => {
      const { data } = await this.client.get(`/activation/${partnerRef}/sms`);
      return {
        status: data.status,
        message: data.message,
      };
    });
  }

  async cancelActivation(partnerRef) {
    return this.withRetry(async () => {
      await this.client.post(`/activation/${partnerRef}/cancel`);
      return true;
    });
  }
}
