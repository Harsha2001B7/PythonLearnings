import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Check, X } from 'lucide-react';
import { useQuery } from '@tanstack/react-query';
import { membershipService } from '../services/api/memberships';
import { useBookingStore } from '../store';
import { formatAED } from '../lib/formatters';
import { ease, duration } from '../lib/easing';
import { cn } from '../lib/cn';

const MembershipSection: React.FC = () => {
  const [billing, setBilling] = useState<'monthly' | 'yearly'>('monthly');
  const { setSelectedVehicle } = useBookingStore();
  const { data: tiers = [], isLoading } = useQuery({
    queryKey: ['memberships'],
    queryFn: () => membershipService.getMemberships(),
  });

  return (
    <section id="membership" className="py-24 bg-vanta-paper">
      <div className="section-container">
        {/* Header */}
        <div className="text-center mb-12 max-w-2xl mx-auto">
          <motion.div
            className="eyebrow justify-center mb-3"
            initial={{ opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: duration.slow, ease: ease.elegant }}
          >
            Membership
          </motion.div>
          <motion.h2
            className="font-display text-display-lg text-vanta-ink"
            initial={{ opacity: 0, y: 24 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.1 }}
          >
            Your level.{' '}
            <span className="italic font-light text-vanta-amber">Your privileges.</span>
          </motion.h2>

          {/* Billing Toggle */}
          <motion.div
            initial={{ opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.2 }}
            className="inline-flex items-center gap-1 mt-8 bg-vanta-paper-soft border border-vanta-border rounded-full p-1"
          >
            {(['monthly', 'yearly'] as const).map((b) => (
              <button
                key={b}
                onClick={() => setBilling(b)}
                className={cn(
                  'relative px-5 py-2 rounded-full font-mono text-[11px] uppercase tracking-[0.12em] transition-all duration-300',
                  billing === b ? 'text-white' : 'text-vanta-ink-muted hover:text-vanta-ink'
                )}
              >
                {billing === b && (
                  <motion.span
                    layoutId="billing-indicator"
                    className="absolute inset-0 bg-vanta-amber rounded-full"
                    transition={{ type: 'spring', stiffness: 380, damping: 30 }}
                  />
                )}
                <span className="relative z-10">{b === 'yearly' ? 'Annual (save 17%)' : 'Monthly'}</span>
              </button>
            ))}
          </motion.div>
        </div>

        {/* Tiers Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {tiers.map((tier, i) => {
            const isAnnual = billing === 'yearly' && tier.pricePerYear;
            const price = isAnnual ? tier.pricePerYear! / 12 : tier.pricePerMonth;

            return (
              <motion.div
                key={tier.id}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: duration.slow, ease: ease.elegant, delay: i * 0.1 }}
                className={cn(
                  'relative flex flex-col rounded-2xl overflow-hidden transition-all duration-300',
                  tier.highlighted
                    ? 'shadow-amber-glow border-2 border-vanta-amber bg-vanta-panel'
                    : 'shimmer-card bg-vanta-panel'
                )}
              >
                {/* Badge */}
                {tier.badge && (
                  <div className={cn(
                    'absolute top-0 right-6 px-4 py-1.5 rounded-b-xl font-mono text-[9px] uppercase tracking-[0.15em]',
                    tier.highlighted ? 'bg-vanta-amber text-white' : 'bg-vanta-paper-soft text-vanta-ink-muted border border-vanta-border border-t-0'
                  )}>
                    {tier.badge}
                  </div>
                )}

                <div className="p-8 flex flex-col gap-6 flex-1">
                  {/* Tier name */}
                  <div>
                    <h3 className={cn(
                      'font-grotesk font-bold text-2xl',
                      tier.highlighted ? 'text-vanta-amber' : 'text-vanta-ink'
                    )}>
                      {tier.name}
                    </h3>
                    <p className="text-vanta-ink-muted text-[13px] mt-1">{tier.tagline}</p>
                  </div>

                  {/* Price */}
                  <div className="flex items-end gap-1.5">
                    <AnimatePresence mode="wait">
                      <motion.span
                        key={`${tier.id}-${billing}`}
                        initial={{ opacity: 0, y: 8 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -8 }}
                        transition={{ duration: 0.25 }}
                        className="font-grotesk font-bold text-4xl text-vanta-ink"
                      >
                        {price === 0 ? 'Free' : formatAED(price)}
                      </motion.span>
                    </AnimatePresence>
                    {price > 0 && (
                      <span className="text-vanta-ink-muted text-[13px] pb-1.5">/month</span>
                    )}
                  </div>

                  {/* Divider */}
                  <div className={cn('h-px', tier.highlighted ? 'bg-vanta-amber/20' : 'bg-vanta-border')} />

                  {/* Features */}
                  <ul className="flex flex-col gap-3 flex-1">
                    {tier.features.map((feat: { text: string; included: boolean }) => (
                      <li key={feat.text} className="flex items-start gap-3">
                        <span className={cn(
                          'w-5 h-5 rounded-full flex items-center justify-center shrink-0 mt-0.5',
                          feat.included
                            ? tier.highlighted ? 'bg-vanta-amber text-white' : 'bg-vanta-amber-pale text-vanta-amber'
                            : 'bg-vanta-paper-soft text-vanta-ink-subtle'
                        )}>
                          {feat.included ? <Check size={10} strokeWidth={3} /> : <X size={10} strokeWidth={2.5} />}
                        </span>
                        <span className={cn(
                          'text-[13px] leading-relaxed',
                          feat.included ? 'text-vanta-ink' : 'text-vanta-ink-subtle line-through-none opacity-50'
                        )}>
                          {feat.text}
                        </span>
                      </li>
                    ))}
                  </ul>

                  {/* CTA */}
                  <motion.button
                    whileHover={{ scale: 1.02, y: -1 }}
                    whileTap={{ scale: 0.98 }}
                    onClick={() => setSelectedVehicle(tier.name)}
                    className={cn(
                      'w-full py-3.5 rounded-xl font-grotesk font-semibold text-[14px] transition-all duration-300',
                      tier.highlighted
                        ? 'bg-vanta-amber text-white shadow-amber-sm hover:bg-vanta-amber-light'
                        : 'border border-vanta-border text-vanta-ink hover:border-vanta-amber hover:text-vanta-amber'
                    )}
                  >
                    {tier.ctaLabel}
                  </motion.button>
                </div>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
};

export default MembershipSection;
