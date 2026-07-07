// SAFRA FAQ Data — used by FaqSection + chatbot keyword engine
import type { FAQItem } from '../types/index';

export const FAQ_DATA: FAQItem[] = [
  // ── Booking ────────────────────────────────────────────────────
  {
    id: 1,
    category: 'booking',
    question: 'How quickly can I confirm a booking?',
    answer: 'Scout members receive confirmation within 2 hours. Vantage members get same-day confirmation within 4 hours. Apex members receive instant confirmation — bookings are approved automatically the moment you submit.',
  },
  {
    id: 2,
    category: 'booking',
    question: 'What documents do I need to rent a vehicle?',
    answer: 'You\'ll need a valid UAE driving licence (or an international licence with a notarised Arabic translation), a passport copy, and a credit card for the security deposit. GCC nationals may use their national ID. All verification is done digitally through the SAFRA app.',
  },
  {
    id: 3,
    category: 'booking',
    question: 'Can I modify or cancel my booking?',
    answer: 'Yes. Modifications are free up to 48 hours before pick-up. Cancellations made more than 48 hours before are fully refunded. Late cancellations (within 48 hours) incur a 1-day rental fee. Apex members enjoy flexible cancellation at any time without penalty.',
  },
  {
    id: 4,
    category: 'booking',
    question: 'Is there a minimum rental period?',
    answer: 'Our minimum rental is 24 hours. We also offer weekly and monthly rates with significant discounts — 15% off for 7+ days, 25% off for 30+ days, plus any membership discount stacked on top.',
  },
  // ── Insurance ──────────────────────────────────────────────────
  {
    id: 5,
    category: 'insurance',
    question: 'What insurance coverage is included?',
    answer: 'Every SAFRA rental includes comprehensive insurance covering third-party liability, collision damage waiver (CDW), and theft protection. Our standard excess is AED 3,000. Apex members enjoy zero-excess coverage at no additional cost.',
  },
  {
    id: 6,
    category: 'insurance',
    question: 'Can I reduce or eliminate the excess?',
    answer: 'Yes. You can add Super Coverage at checkout (AED 120–280/day depending on vehicle class), reducing your excess to zero. Alternatively, Apex membership includes zero-excess as a standard perk.',
  },
  {
    id: 7,
    category: 'insurance',
    question: 'What happens if there is an accident?',
    answer: 'Contact our 24/7 concierge line immediately. We\'ll coordinate police reports, towing, and a replacement vehicle for Vantage and Apex members. Our team handles all insurance paperwork — you focus on getting safely to your destination.',
  },
  // ── Delivery ───────────────────────────────────────────────────
  {
    id: 8,
    category: 'delivery',
    question: 'Do you offer vehicle delivery and collection?',
    answer: 'Yes. We deliver to any address in the UAE — hotels, residences, offices, and all major airports. Vantage members receive free delivery within Dubai. Apex members receive free delivery anywhere in the UAE, at any hour.',
  },
  {
    id: 9,
    category: 'delivery',
    question: 'How far in advance should I book for airport delivery?',
    answer: 'We recommend booking at least 6 hours ahead for airport deliveries to guarantee your preferred vehicle. During peak periods (UAE National Day, Dubai Shopping Festival) we suggest 24–48 hours advance booking. Apex members are always prioritised.',
  },
  // ── Pricing ────────────────────────────────────────────────────
  {
    id: 10,
    category: 'pricing',
    question: 'What payment methods do you accept?',
    answer: 'We accept all major credit cards (Visa, Mastercard, Amex), Apple Pay, Google Pay, and UAE bank transfers for corporate accounts. A security deposit (equal to 2 days\' rental) is pre-authorised on your card and released within 5 business days of return.',
  },
  {
    id: 11,
    category: 'pricing',
    question: 'Are there any hidden fees?',
    answer: 'No. Your booking total includes insurance, basic roadside support, and all standard taxes. Extras — like additional drivers, child seats, GPS, or fuel pre-purchase — are listed clearly at checkout. What you see is what you pay.',
  },
  // ── Membership ─────────────────────────────────────────────────
  {
    id: 12,
    category: 'membership',
    question: 'Can I upgrade or downgrade my membership?',
    answer: 'Yes, at any time. Upgrades take effect immediately. Downgrades take effect at the start of your next billing cycle. If you upgrade mid-cycle, you\'ll only pay the prorated difference for the remaining days.',
  },
];

// Helper: get FAQs by category (used by chatbot keyword matching)
export const getFAQsByCategory = (category: FAQItem['category']) =>
  FAQ_DATA.filter(f => f.category === category);

// Helper: keyword match for chatbot
export const findFAQByKeyword = (keyword: string): FAQItem | undefined => {
  const lower = keyword.toLowerCase();
  return FAQ_DATA.find(
    f =>
      f.question.toLowerCase().includes(lower) ||
      f.answer.toLowerCase().includes(lower)
  );
};
