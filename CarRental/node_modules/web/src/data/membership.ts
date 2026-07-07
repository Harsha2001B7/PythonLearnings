// ─────────────────────────────────────────────────────────────────
// VANTA Membership Tiers — Mock data
// Structured as if returned from GET /api/membership
// ─────────────────────────────────────────────────────────────────
import type { MembershipTier } from '../types/index';

export const MEMBERSHIP_TIERS: MembershipTier[] = [
  {
    id: 1,
    name: 'Scout',
    tagline: 'The perfect starting point',
    pricePerMonth: 0,
    features: [
      { text: 'Access to full fleet catalogue', included: true },
      { text: 'Standard booking confirmation', included: true },
      { text: '10% discount on weekly rentals', included: true },
      { text: 'Basic roadside support', included: true },
      { text: 'Priority fleet selection', included: false },
      { text: 'Airport concierge delivery', included: false },
      { text: 'Exclusive member events', included: false },
      { text: 'Personal account manager', included: false },
    ],
    highlighted: false,
    ctaLabel: 'Start for Free',
  },
  {
    id: 2,
    name: 'Vantage',
    tagline: 'The curated driving life',
    pricePerMonth: 299,
    pricePerYear: 2990,
    features: [
      { text: 'Access to full fleet catalogue', included: true },
      { text: 'Same-day booking confirmation', included: true },
      { text: '20% discount on all rentals', included: true },
      { text: '24/7 premium roadside support', included: true },
      { text: 'Priority fleet selection', included: true },
      { text: 'Airport concierge delivery', included: true },
      { text: 'Exclusive member events', included: false },
      { text: 'Personal account manager', included: false },
    ],
    highlighted: true,
    badge: 'Most Popular',
    ctaLabel: 'Join Vantage',
  },
  {
    id: 3,
    name: 'Apex',
    tagline: 'No limits. No waiting.',
    pricePerMonth: 799,
    pricePerYear: 7990,
    features: [
      { text: 'Unlimited fleet access — any model', included: true },
      { text: 'Instant booking, no approval wait', included: true },
      { text: '30% discount + loyalty credits', included: true },
      { text: 'Dedicated concierge line — 24/7', included: true },
      { text: 'Priority fleet selection + first access', included: true },
      { text: 'Anywhere-in-UAE delivery, any hour', included: true },
      { text: 'VIP member events & track days', included: true },
      { text: 'Named personal account manager', included: true },
    ],
    highlighted: false,
    badge: 'Apex Exclusive',
    ctaLabel: 'Apply for Apex',
  },
];
