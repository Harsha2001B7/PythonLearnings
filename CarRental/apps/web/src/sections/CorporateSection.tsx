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
    <section id="corporate" className="py-24 bg-vanta-paper overflow-hidden">
      <div className="section-container">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
          {/* Left: Content */}
          <div>
            <motion.div
              className="eyebrow mb-3"
              initial={{ opacity: 0, x: -16 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ duration: duration.slow, ease: ease.elegant }}
            >
              For Business
            </motion.div>
            <motion.h2
              className="font-display text-display-lg text-vanta-ink mb-5"
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.1 }}
            >
              Fleet management,{' '}
              <span className="italic font-light text-vanta-amber">effortless at scale.</span>
            </motion.h2>
            <motion.p
              className="text-vanta-ink-muted text-[15px] leading-relaxed mb-8"
              initial={{ opacity: 0, y: 16 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.15 }}
            >
              VANTA Corporate provides UAE businesses with a flexible, fully managed vehicle fleet — without the overhead of ownership or long-term lease commitments. From law firms to logistics companies, 1,200+ businesses trust VANTA.
            </motion.p>

            <div className="flex flex-col gap-5 mb-10">
              {FEATURES.map((feat, i) => {
                const Icon = feat.icon;
                return (
                  <motion.div
                    key={feat.title}
                    initial={{ opacity: 0, x: -20 }}
                    whileInView={{ opacity: 1, x: 0 }}
                    viewport={{ once: true }}
                    transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.2 + i * 0.1 }}
                    className="flex items-start gap-4"
                  >
                    <div className="w-10 h-10 rounded-xl bg-vanta-amber-pale border border-vanta-amber/20 flex items-center justify-center shrink-0">
                      <Icon size={18} className="text-vanta-amber" />
                    </div>
                    <div>
                      <h3 className="font-grotesk font-semibold text-[15px] text-vanta-ink">{feat.title}</h3>
                      <p className="text-vanta-ink-muted text-[13px] mt-0.5 leading-relaxed">{feat.desc}</p>
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
                className="shimmer-card bg-vanta-panel rounded-2xl p-8 flex flex-col gap-2"
              >
                <span className="font-grotesk font-bold text-5xl text-vanta-ink">{stat.value}</span>
                <span className="font-mono text-[10px] uppercase tracking-[0.15em] text-vanta-ink-muted">{stat.label}</span>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default CorporateSection;
