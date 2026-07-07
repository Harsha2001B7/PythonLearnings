import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronDown, Search } from 'lucide-react';
import { FAQ_DATA } from '../data/faq';
import type { FAQCategory } from '../types/index';
import { ease, duration } from '../lib/easing';
import { cn } from '../lib/cn';

const CATEGORIES: { value: string; label: string }[] = [
  { value: 'all', label: 'All Topics' },
  { value: 'booking', label: 'Booking' },
  { value: 'insurance', label: 'Insurance' },
  { value: 'delivery', label: 'Delivery' },
  { value: 'pricing', label: 'Pricing' },
  { value: 'membership', label: 'Membership' },
];

const FaqSection: React.FC = () => {
  const [activeCategory, setActiveCategory] = useState('all');
  const [openId, setOpenId] = useState<number | null>(null);
  const [search, setSearch] = useState('');

  const filtered = FAQ_DATA.filter((faq) => {
    const matchCat = activeCategory === 'all' || faq.category === activeCategory;
    const matchSearch =
      search === '' ||
      faq.question.toLowerCase().includes(search.toLowerCase()) ||
      faq.answer.toLowerCase().includes(search.toLowerCase());
    return matchCat && matchSearch;
  });

  const toggle = (id: number) => setOpenId((prev) => (prev === id ? null : id));

  return (
    <section id="faq" className="py-24 bg-vanta-paper">
      <div className="section-container">
        {/* Header */}
        <div className="max-w-2xl mb-12">
          <motion.div
            className="eyebrow mb-3"
            initial={{ opacity: 0, x: -16 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: duration.slow, ease: ease.elegant }}
          >
            Frequently Asked
          </motion.div>
          <motion.h2
            className="font-display text-display-lg text-vanta-ink"
            initial={{ opacity: 0, y: 24 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.1 }}
          >
            Questions, answered{' '}
            <span className="italic font-light text-vanta-amber">honestly.</span>
          </motion.h2>
        </div>

        {/* Search */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.15 }}
          className="relative mb-6 max-w-md"
        >
          <Search size={14} className="absolute left-4 top-1/2 -translate-y-1/2 text-vanta-ink-muted" />
          <input
            type="search"
            placeholder="Search questions..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-3 bg-vanta-panel border border-vanta-border rounded-xl text-[14px] font-grotesk text-vanta-ink placeholder:text-vanta-ink-subtle focus:border-vanta-amber focus:outline-none transition-colors"
            aria-label="Search FAQ"
          />
        </motion.div>

        {/* Category filters */}
        <motion.div
          initial={{ opacity: 0, y: 12 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.2 }}
          className="flex flex-wrap gap-2 mb-8"
          role="tablist"
        >
          {CATEGORIES.map((cat) => (
            <button
              key={cat.value}
              onClick={() => setActiveCategory(cat.value)}
              role="tab"
              aria-selected={activeCategory === cat.value}
              className={cn(
                'px-4 py-2 rounded-full font-mono text-[10px] uppercase tracking-[0.12em] border transition-all duration-200',
                activeCategory === cat.value
                  ? 'bg-vanta-amber border-vanta-amber text-white shadow-amber-sm'
                  : 'border-vanta-border text-vanta-ink-muted hover:border-vanta-amber/50 hover:text-vanta-ink'
              )}
            >
              {cat.label}
            </button>
          ))}
        </motion.div>

        {/* Accordion */}
        <motion.div
          layout
          className="flex flex-col gap-3 max-w-3xl"
        >
          <AnimatePresence>
            {filtered.length === 0 ? (
              <motion.p
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="text-vanta-ink-muted py-8 text-center"
              >
                No questions match your search.
              </motion.p>
            ) : (
              filtered.map((faq, i) => (
                <motion.div
                  layout
                  key={faq.id}
                  initial={{ opacity: 0, y: 16 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -8 }}
                  transition={{ duration: 0.3, ease: ease.elegant, delay: i < 6 ? i * 0.04 : 0 }}
                  className={cn(
                    'bg-vanta-panel border rounded-xl overflow-hidden transition-colors duration-200',
                    openId === faq.id ? 'border-vanta-amber/40' : 'border-vanta-border hover:border-vanta-amber/30'
                  )}
                >
                  <button
                    onClick={() => toggle(faq.id)}
                    aria-expanded={openId === faq.id}
                    className="w-full flex items-center justify-between gap-4 px-6 py-5 text-left"
                  >
                    <h3 className="font-grotesk font-semibold text-[15px] text-vanta-ink leading-snug">{faq.question}</h3>
                    <motion.span
                      animate={{ rotate: openId === faq.id ? 180 : 0 }}
                      transition={{ duration: 0.25, ease: ease.elegant }}
                      className="text-vanta-ink-muted shrink-0"
                    >
                      <ChevronDown size={18} />
                    </motion.span>
                  </button>

                  <AnimatePresence>
                    {openId === faq.id && (
                      <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        transition={{ duration: 0.35, ease: ease.elegant }}
                        className="overflow-hidden"
                      >
                        <div className="px-6 pb-5 border-t border-vanta-border/60">
                          <p className="text-vanta-ink-muted text-[14px] leading-relaxed pt-4">{faq.answer}</p>
                        </div>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </motion.div>
              ))
            )}
          </AnimatePresence>
        </motion.div>
      </div>
    </section>
  );
};

export default FaqSection;
