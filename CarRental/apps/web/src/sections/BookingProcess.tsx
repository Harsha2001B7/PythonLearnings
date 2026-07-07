import React, { useEffect, useRef } from 'react';
import { motion } from 'framer-motion';
import gsap from 'gsap';
import ScrollTrigger from 'gsap/ScrollTrigger';
import { MessageSquare, TrendingUp, FileText, Truck } from 'lucide-react';
import { ease } from '../lib/easing';

gsap.registerPlugin(ScrollTrigger);

const STEPS = [
  {
    number: '01',
    icon: MessageSquare,
    label: 'STEP 1',
    title: 'Choose',
    description: 'Pick a car and your dates here, or just describe what you need on WhatsApp.',
  },
  {
    number: '02',
    icon: TrendingUp,
    label: 'STEP 2',
    title: 'Get your rate',
    description: 'We reply in minutes with your best price — mileage, insurance and delivery all spelled out.',
  },
  {
    number: '03',
    icon: FileText,
    label: 'STEP 3',
    title: 'Send documents',
    description: 'Licence and ID photos over WhatsApp. Digital contract, no counters, no queues.',
  },
  {
    number: '04',
    icon: Truck,
    label: 'STEP 4',
    title: 'We deliver',
    description: 'Keys at your door, hotel or DXB arrivals. Quick walk-around together and you\'re off.',
  },
];

const BookingProcess: React.FC = () => {
  const sectionRef = useRef<HTMLElement>(null);

  useEffect(() => {
    const ctx = gsap.context(() => {
      STEPS.forEach((_, i) => {
        const card = sectionRef.current?.querySelectorAll('[data-step-card]')[i];
        if (!card) return;
        gsap.from(card, {
          opacity: 0,
          y: 30,
          duration: 0.6,
          delay: i * 0.1,
          ease: 'power2.out',
          scrollTrigger: {
            trigger: card,
            start: 'top 80%',
          },
        });
      });
    }, sectionRef);
    return () => ctx.revert();
  }, []);

  return (
    <section 
      ref={sectionRef} 
      id="how-it-works" 
      className="py-24 overflow-hidden rounded-[32px] sm:rounded-[48px] mx-4 sm:mx-6 lg:mx-12 my-20 shadow-2xl"
      style={{ 
        backgroundColor: '#0D0D0D',
        '--vanta-ink': '#FFFFFF',
        '--vanta-ink-muted': '#A0A0A0',
        '--vanta-panel': '#1A1A1A',
        '--vanta-border': '#2A2A2A',
      } as React.CSSProperties}
    >
      <div className="section-container">
        {/* Header */}
        <div className="mb-16">
          <motion.div
            className="eyebrow mb-3"
            initial={{ opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, ease: ease.elegant }}
          >
            How It Works
          </motion.div>
          <motion.h2
            className="font-grotesk font-extrabold text-vanta-ink"
            style={{ fontSize: 'clamp(2rem, 5vw, 3.5rem)', lineHeight: 1.1 }}
            initial={{ opacity: 0, y: 24 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, ease: ease.elegant, delay: 0.1 }}
          >
            Message to keys,{' '}
            <br />
            <span className="text-vanta-amber">in four steps.</span>
          </motion.h2>
        </div>

        {/* Steps Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {STEPS.map((step, i) => {
            const Icon = step.icon;
            return (
              <div
                key={step.number}
                data-step-card
                className="bg-vanta-panel border border-vanta-border rounded-2xl p-6 hover:border-vanta-amber/40 transition-all duration-300 group"
              >
                <div className="mb-4">
                  <span className="font-mono text-[11px] font-bold tracking-[0.18em] text-vanta-amber">
                    {step.label}
                  </span>
                </div>
                <div className="mb-4">
                  <div className="w-10 h-10 rounded-xl bg-vanta-amber/10 border border-vanta-amber/20 flex items-center justify-center group-hover:bg-vanta-amber/15 transition-colors">
                    <Icon size={18} className="text-vanta-amber" />
                  </div>
                </div>
                <h3 className="font-grotesk font-bold text-xl text-vanta-ink mb-3">
                  {step.title}
                </h3>
                <p className="text-vanta-ink-muted text-[14px] leading-relaxed">
                  {step.description}
                </p>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
};

export default BookingProcess;
