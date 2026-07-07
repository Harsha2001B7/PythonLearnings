import React from 'react';
import { motion } from 'framer-motion';
import { Shield, Clock, MapPin, Zap, Star, Headphones } from 'lucide-react';
import { ease, duration } from '../lib/easing';

const DIFFERENTIATORS = [
  {
    icon: Clock,
    headline: '90-Second Booking',
    sub: 'Confirmed',
    body: 'Message us on WhatsApp, choose your car, and we reply with a quote in minutes. Simple pricing — no hidden extras, no membership needed.',
    stat: '99.8%',
    statLabel: 'On-time delivery rate',
  },
  {
    icon: MapPin,
    headline: 'Anywhere in UAE',
    sub: 'Delivered to You',
    body: 'We deliver to any address across Dubai — hotels, homes, offices, DXB T1 and T3. Return anywhere in the UAE. Our own team handles every delivery, not a courier.',
    stat: '12',
    statLabel: 'Delivery hubs UAE-wide',
  },
  {
    icon: Shield,
    headline: 'Zero-Hassle',
    sub: 'Insurance & Support',
    body: 'Comprehensive coverage included in every rental. Our 24/7 concierge coordinates claims, towing, and replacement vehicles so you never deal with paperwork on the roadside.',
    stat: '24/7',
    statLabel: 'Concierge availability',
  },
  {
    icon: Zap,
    headline: 'EV-Ready',
    sub: 'Fleet & Infrastructure',
    body: 'Our growing electric fleet arrives fully charged. We partner with UAE charging networks to provide members with a complimentary charging access card — range anxiety, solved.',
    stat: '40%',
    statLabel: 'Fleet is electric or hybrid',
  },
];

const WhyVanta: React.FC = () => {
  return (
    <section id="experience" className="py-32 bg-surface-secondary overflow-hidden">
      <div className="section-container">
        {/* Header */}
        <div className="max-w-2xl mb-16">
          <motion.div
            className="eyebrow mb-6 text-accent-orange"
            initial={{ opacity: 0, x: -16 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: duration.slow, ease: ease.elegant }}
          >
            Why Falcon View
          </motion.div>
          <motion.h2
            className="font-display text-display-lg text-text-primary mb-6"
            initial={{ opacity: 0, y: 24 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.1 }}
          >
            Built for people who{' '}
            <span className="italic font-light text-accent-orange">notice the difference.</span>
          </motion.h2>
          <motion.p
            className="text-text-secondary text-body-lg"
            initial={{ opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.2 }}
          >
            We built Falcon View because we knew there was a better way — transparent pricing, free delivery, and real humans to call 24/7.
          </motion.p>
        </div>

        {/* Differentiator Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {DIFFERENTIATORS.map((item, i) => {
            const Icon = item.icon;
            return (
              <motion.div
                key={item.headline}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: '-60px' }}
                transition={{ duration: duration.slow, ease: ease.elegant, delay: i * 0.1 }}
                className="shimmer-card bg-surface-primary rounded-2xl p-10 flex flex-col gap-6"
              >
                <div className="flex items-start gap-5">
                  <div className="w-12 h-12 rounded-xl bg-accent-orange/10 border border-accent-orange/20 flex items-center justify-center shrink-0">
                    <Icon size={22} className="text-accent-orange" />
                  </div>
                  <div>
                    <h3 className="font-grotesk font-bold text-heading-2 text-text-primary leading-tight">{item.headline}</h3>
                    <p className="font-mono text-[10px] uppercase tracking-[0.15em] text-accent-orange mt-1">{item.sub}</p>
                  </div>
                </div>
                <p className="text-text-secondary text-body-md">{item.body}</p>

                {/* Stat callout */}
                <div className="flex items-end gap-3 pt-4 mt-auto border-t border-subtle">
                  <span className="font-grotesk font-bold text-heading-1 text-text-primary">{item.stat}</span>
                  <span className="font-mono text-[10px] uppercase tracking-[0.12em] text-text-subtle pb-1.5">{item.statLabel}</span>
                </div>
              </motion.div>
            );
          })}
        </div>

        {/* Trust strip */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.4 }}
          className="mt-16 flex flex-wrap gap-8 items-center justify-center py-8 px-10 rounded-2xl bg-surface-primary border border-subtle shadow-card-sm"
        >
          {[
            { icon: Star, text: '4.9/5 average rating · 18,000+ reviews' },
            { icon: Headphones, text: '24/7 UAE concierge line' },
            { icon: Shield, text: 'Zero hidden fees — ever' },
          ].map(({ icon: Icon, text }) => (
            <div key={text} className="flex items-center gap-3 text-text-secondary">
              <Icon size={18} className="text-accent-orange shrink-0" />
              <span className="font-grotesk text-body-sm font-medium text-text-primary">{text}</span>
            </div>
          ))}
        </motion.div>
      </div>
    </section>
  );
};

export default WhyVanta;
