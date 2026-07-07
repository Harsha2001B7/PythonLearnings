import React, { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Star, ChevronLeft, ChevronRight, Quote } from 'lucide-react';
import { TESTIMONIALS } from '../data/testimonials';
import { ease, duration } from '../lib/easing';

// ── Initials Avatar ────────────────────────────────────────────
const InitialsAvatar: React.FC<{
  initials: string;
  color: string;
  size?: number;
}> = ({ initials, color, size = 44 }) => (
  <svg
    width={size}
    height={size}
    viewBox="0 0 44 44"
    aria-hidden="true"
    className="rounded-full shrink-0"
    style={{ borderRadius: '50%' }}
  >
    <circle cx="22" cy="22" r="22" fill={color} />
    <text
      x="22"
      y="22"
      dominantBaseline="central"
      textAnchor="middle"
      fill="white"
      fontFamily="Space Grotesk, sans-serif"
      fontWeight="600"
      fontSize="14"
      letterSpacing="0.5"
    >
      {initials}
    </text>
  </svg>
);

// ── Star Rating ────────────────────────────────────────────────
const StarRating: React.FC<{ rating: number }> = ({ rating }) => (
  <div className="flex gap-0.5" aria-label={`${rating} out of 5 stars`}>
    {Array.from({ length: 5 }, (_, i) => (
      <Star
        key={i}
        size={12}
        fill={i < rating ? '#C8873A' : 'none'}
        stroke={i < rating ? '#C8873A' : '#9C9589'}
        strokeWidth={1.5}
      />
    ))}
  </div>
);

const Testimonials: React.FC = () => {
  const [activeIndex, setActiveIndex] = useState(0);
  const [isPaused, setIsPaused] = useState(false);
  const [direction, setDirection] = useState(1); // 1 = forward, -1 = backward
  const intervalRef = React.useRef<ReturnType<typeof setTimeout> | null>(null);

  const goTo = useCallback((index: number, dir: number) => {
    setDirection(dir);
    setActiveIndex(index);
  }, []);

  const goNext = useCallback(() => {
    goTo((activeIndex + 1) % TESTIMONIALS.length, 1);
  }, [activeIndex, goTo]);

  const goPrev = useCallback(() => {
    goTo((activeIndex - 1 + TESTIMONIALS.length) % TESTIMONIALS.length, -1);
  }, [activeIndex, goTo]);

  // Auto-advance every 5s
  useEffect(() => {
    if (isPaused) return;
    intervalRef.current = setTimeout(goNext, 5000);
    return () => { if (intervalRef.current) clearTimeout(intervalRef.current); };
  }, [activeIndex, isPaused, goNext]);

  const variants = {
    enter: (d: number) => ({ opacity: 0, x: d * 40, scale: 0.98 }),
    center: { opacity: 1, x: 0, scale: 1 },
    exit: (d: number) => ({ opacity: 0, x: d * -40, scale: 0.98 }),
  };

  const active = TESTIMONIALS[activeIndex];

  return (
    <section id="testimonials" className="py-24 bg-vanta-paper-soft overflow-hidden">
      <div className="section-container">
        {/* Header */}
        <div className="text-center mb-14">
          <motion.div
            className="eyebrow justify-center mb-3"
            initial={{ opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
          >
            Client Stories
          </motion.div>
          <motion.h2
            className="font-display text-display-lg text-vanta-ink"
            initial={{ opacity: 0, y: 24 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
          >
            What our members{' '}
            <span className="italic font-light text-vanta-amber">actually say.</span>
          </motion.h2>
        </div>

        {/* Carousel */}
        <div
          className="relative max-w-3xl mx-auto"
          onMouseEnter={() => setIsPaused(true)}
          onMouseLeave={() => setIsPaused(false)}
        >
          {/* Quote icon */}
          <Quote
            size={48}
            className="absolute -top-3 -left-3 text-vanta-amber/15 z-0"
            fill="currentColor"
          />

          {/* Card */}
          <div className="relative z-10 bg-vanta-panel border border-vanta-border rounded-2xl p-8 sm:p-12 shadow-card-md min-h-[280px] flex flex-col justify-between">
            <AnimatePresence mode="wait" custom={direction}>
              <motion.div
                key={activeIndex}
                custom={direction}
                variants={variants}
                initial="enter"
                animate="center"
                exit="exit"
                transition={{ duration: 0.4, ease: ease.elegant }}
                className="flex flex-col gap-6"
              >
                {/* Stars */}
                <StarRating rating={active.rating} />

                {/* Quote text */}
                <blockquote className="font-display text-xl sm:text-2xl text-vanta-ink font-light leading-snug italic">
                  "{active.text}"
                </blockquote>

                {/* Author */}
                <div className="flex items-center gap-3">
                  <InitialsAvatar initials={active.authorInitials} color={active.avatarColor} />
                  <div>
                    <p className="font-grotesk font-semibold text-[14px] text-vanta-ink">{active.authorName}</p>
                    <p className="font-mono text-[10px] text-vanta-ink-muted uppercase tracking-[0.1em]">
                      {active.role}{active.company ? ` · ${active.company}` : ''}
                      {active.membershipTier && (
                        <span className="ml-2 text-vanta-amber">{active.membershipTier} Member</span>
                      )}
                    </p>
                  </div>
                </div>
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Controls */}
          <div className="flex items-center justify-between mt-6">
            {/* Prev/Next */}
            <div className="flex gap-2">
              <button
                onClick={goPrev}
                className="w-10 h-10 rounded-full border border-vanta-border flex items-center justify-center text-vanta-ink-muted hover:border-vanta-amber hover:text-vanta-amber transition-all"
                aria-label="Previous testimonial"
              >
                <ChevronLeft size={16} />
              </button>
              <button
                onClick={goNext}
                className="w-10 h-10 rounded-full border border-vanta-border flex items-center justify-center text-vanta-ink-muted hover:border-vanta-amber hover:text-vanta-amber transition-all"
                aria-label="Next testimonial"
              >
                <ChevronRight size={16} />
              </button>
            </div>

            {/* Dots */}
            <div className="flex gap-1.5" role="tablist" aria-label="Testimonial navigation">
              {TESTIMONIALS.map((_, i) => (
                <button
                  key={i}
                  onClick={() => goTo(i, i > activeIndex ? 1 : -1)}
                  role="tab"
                  aria-selected={i === activeIndex}
                  aria-label={`Go to testimonial ${i + 1}`}
                  className="relative h-1.5 rounded-full overflow-hidden transition-all duration-300"
                  style={{ width: i === activeIndex ? 24 : 6, background: i === activeIndex ? '#C8873A' : '#E4DED4' }}
                />
              ))}
            </div>

            {/* Progress bar */}
            {!isPaused && (
              <div className="w-16 h-0.5 bg-vanta-border rounded-full overflow-hidden">
                <motion.div
                  key={activeIndex}
                  className="h-full bg-vanta-amber rounded-full origin-left"
                  initial={{ scaleX: 0 }}
                  animate={{ scaleX: 1 }}
                  transition={{ duration: 5, ease: 'linear' }}
                />
              </div>
            )}
          </div>
        </div>
      </div>
    </section>
  );
};

export default Testimonials;
