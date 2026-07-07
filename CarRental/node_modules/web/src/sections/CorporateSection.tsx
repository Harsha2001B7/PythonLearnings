import React from 'react';
import { motion } from 'framer-motion';
import { Building2, TrendingDown, Clock, ArrowRight } from 'lucide-react';
import { ease, duration } from '../lib/easing';
import { useToastStore } from '../store';

const STATS = [
  { value: '34%', label: 'Average fleet cost reduction vs. leasing' },
  { value: '1,200+', label: 'Corporate accounts in UAE' },
  { value: '4h', label: 'Fleet provisioning turnaround time' },
];

const FEATURES = [
  { icon: Building2, title: 'Centralized Billing', desc: 'One monthly invoice, one account manager, zero per-driver admin overhead.' },
  { icon: TrendingDown, title: 'Volume Pricing', desc: 'Tiered discounts starting at 5 vehicles — the larger your fleet, the sharper your rate.' },
  { icon: Clock, title: 'Priority Provisioning', desc: 'Corporate clients get same-day vehicle allocation, even during peak demand periods.' },
];

const CorporateSection: React.FC = () => {
  const { addToast } = useToastStore();

  return (
    <section id="corporate" className="py-32 bg-surface-secondary overflow-hidden">
      <div className="section-container">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-20 items-center">
          {/* Left: Content */}
          <div>
            <motion.div
              className="eyebrow mb-6 text-accent-orange"
              initial={{ opacity: 0, x: -16 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ duration: duration.slow, ease: ease.elegant }}
            >
              For Business
            </motion.div>
            <motion.h2
              className="font-display text-display-lg text-text-primary mb-6"
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.1 }}
            >
              Fleet management,{' '}
              <span className="italic font-light text-accent-orange">effortless at scale.</span>
            </motion.h2>
            <motion.p
              className="text-text-secondary text-body-lg mb-10"
              initial={{ opacity: 0, y: 16 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.15 }}
            >
              Falcon View Corporate provides UAE businesses with a flexible, fully managed vehicle fleet — without the overhead of ownership or long-term lease commitments. From law firms to logistics companies, 1,200+ businesses trust Falcon View.
            </motion.p>

            <div className="flex flex-col gap-8 mb-12">
              {FEATURES.map((feat, i) => {
                const Icon = feat.icon;
                return (
                  <motion.div
                    key={feat.title}
                    initial={{ opacity: 0, x: -20 }}
                    whileInView={{ opacity: 1, x: 0 }}
                    viewport={{ once: true }}
                    transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.2 + i * 0.1 }}
                    className="flex items-start gap-5"
                  >
                    <div className="w-12 h-12 rounded-xl bg-accent-orange/10 border border-accent-orange/20 flex items-center justify-center shrink-0">
                      <Icon size={20} className="text-accent-orange" />
                    </div>
                    <div>
                      <h3 className="font-grotesk font-semibold text-heading-2 text-text-primary">{feat.title}</h3>
                      <p className="text-text-secondary text-body-md mt-1.5">{feat.desc}</p>
                    </div>
                  </motion.div>
                );
              })}
            </div>

            <motion.button
              initial={{ opacity: 0, y: 10 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              whileHover={{ scale: 1.02, y: -1 }}
              whileTap={{ scale: 0.98 }}
              transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.5 }}
              onClick={() => addToast('Corporate team will contact you within 1 business day')}
              className="btn-amber flex items-center gap-2"
            >
              Request a Fleet Demo <ArrowRight size={14} />
            </motion.button>
          </div>

          {/* Right: Stats */}
          <motion.div
            initial={{ opacity: 0, x: 30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: duration.cinematic, ease: ease.elegant, delay: 0.25 }}
            className="flex flex-col gap-4"
          >
            {STATS.map((stat, i) => (
              <motion.div
                key={stat.label}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: 0.3 + i * 0.1 }}
                className="shimmer-card bg-surface-primary rounded-3xl p-10 flex flex-col gap-3 shadow-card-sm"
              >
                <span className="font-grotesk font-bold text-5xl md:text-6xl text-text-primary">{stat.value}</span>
                <span className="font-mono text-[11px] uppercase tracking-[0.18em] text-text-subtle">{stat.label}</span>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default CorporateSection;
