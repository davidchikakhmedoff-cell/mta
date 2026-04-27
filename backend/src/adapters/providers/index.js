import { GenericProviderAdapter } from './generic.adapter.js';

export function createProviderAdapter(provider) {
  return new GenericProviderAdapter(provider);
}
