import api from './axios';
import type { MembershipTier } from '../../types/index';

export const membershipService = {
  getMemberships: async (): Promise<MembershipTier[]> => {
    const response = await api.get('/memberships');
    // Map snake_case to camelCase
    return response.data.map((m: any) => ({
      id: m.id,
      name: m.name,
      tagline: m.tagline,
      pricePerMonth: m.price_per_month,
      pricePerYear: m.price_per_year,
      highlighted: m.highlighted,
      badge: m.badge,
      ctaLabel: m.cta_label,
      features: m.features?.map((f: any) => ({
        text: f.text,
        included: f.included,
      })) || [],
    }));
  },
};
