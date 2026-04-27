import { providerRepository } from '../repositories/provider.repository.js';
import { createProviderAdapter } from '../adapters/providers/index.js';

export const providerRouterService = {
  async requestNumberWithFailover(service, country) {
    const providers = await providerRepository.listEnabledByPriority();
    let lastError;

    for (const provider of providers) {
      try {
        const adapter = createProviderAdapter(provider);
        const allocation = await adapter.requestNumber(service, country);
        return { provider, allocation, adapter };
      } catch (error) {
        lastError = error;
      }
    }

    throw lastError || new Error('No provider available');
  },
};
