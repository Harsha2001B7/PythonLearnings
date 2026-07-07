import React, { useState, useRef } from 'react';
import { motion, useScroll, useTransform } from 'framer-motion';
import { MessageCircle } from 'lucide-react';
import { useCountUp } from '../hooks/useCountUp';
import { ease, duration } from '../lib/easing';
import { falconLogo } from '../components/layout/Navbar';
import { cn } from '../lib/cn';

// ─── Animated Stat ────────────────────────────────────────────────
const AnimatedStat: React.FC<{ value: number; suffix?: string; label: string; decimals?: number }> = ({
  value, suffix = '', label, decimals = 0,
}) => {
  const { ref, display } = useCountUp({ target: value, suffix, decimals, duration: 2000 });
  return (
    <div className="flex flex-col gap-0.5">
      <span ref={ref} className="font-grotesk font-bold text-3xl sm:text-4xl text-white tracking-tight leading-none">
        {display}
      </span>
      <span className="font-sans text-[12px] text-white/50">{label}</span>
    </div>
  );
};

// ─── Floating Logo Card ───────────────────────────────────────────
const FloatingLogoCard: React.FC = () => (
  <motion.div
    className="relative flex flex-col items-center justify-center"
    animate={{ y: [-8, 8, -8] }}
    transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut' }}
  >
    {/* Circular Glow behind logo */}
    <motion.div
      className="absolute w-72 h-72 pointer-events-none rounded-full"
      animate={{ opacity: [0.3, 0.7, 0.3], scale: [0.95, 1.05, 0.95] }}
      transition={{ duration: 3, repeat: Infinity, ease: 'easeInOut' }}
      style={{
        background: 'radial-gradient(circle, rgba(255,107,0,0.15) 0%, transparent 65%)',
        top: '50%',
        left: '50%',
        transform: 'translate(-50%, -50%)',
      }}
    />
    {/* Logo content (Transparent, no card box) */}
    <div className="relative flex items-center justify-center z-10">
      <img
        src={falconLogo}
        alt="Falcon View Wings"
        className="w-[540px] max-w-[88vw] h-auto object-contain drop-shadow-[0_8px_32px_rgba(255,107,0,0.45)]"
      />
    </div>
    {/* Orbit ring */}
    <motion.div
      className="absolute pointer-events-none"
      animate={{ rotate: 360 }}
      transition={{ duration: 22, repeat: Infinity, ease: 'linear' }}
      style={{
        border: '1px dashed rgba(255,107,0,0.14)',
        borderRadius: '50%',
        width: '320px',
        height: '320px',
        top: '50%',
        left: '50%',
        transform: 'translate(-50%, -50%)',
      }}
    />
    <motion.div
      className="absolute w-2.5 h-2.5 bg-orange-500 rounded-full"
      style={{ top: '15%', right: '20px' }}
      animate={{ scale: [1, 1.3, 1], opacity: [0.6, 1, 0.6] }}
      transition={{ duration: 2, repeat: Infinity }}
    />
    <motion.div
      className="absolute w-2 h-2 bg-white/40 rounded-full"
      style={{ bottom: '20%', left: '15px' }}
      animate={{ scale: [1, 1.4, 1], opacity: [0.3, 0.8, 0.3] }}
      transition={{ duration: 2.5, repeat: Infinity, delay: 0.8 }}
    />
  </motion.div>
);

// ─── Booking Tabs + Form ──────────────────────────────────────────
type RentalTab = 'Daily' | 'Weekly' | 'Monthly' | 'With driver';

const BookingCard: React.FC = () => {
  const [tab, setTab] = useState<RentalTab>('Daily');
  const [chips, setChips] = useState<string[]>([]);
  const [delivery, setDelivery] = useState('');
  const [carType, setCarType] = useState('');
  const [driverAge, setDriverAge] = useState('25+');
  const [licence, setLicence] = useState('UAE licence');
  const [promo, setPromo] = useState('');

  const toggleChip = (c: string) =>
    setChips((prev) => prev.includes(c) ? prev.filter((x) => x !== c) : [...prev, c]);

  const handleGetRate = () => {
    const msg = encodeURIComponent(
      `Hi Falcon View! Rental type: ${tab}. Delivery: ${delivery || 'TBD'}. Car type: ${carType || 'Any'}. Driver age: ${driverAge}. Licence: ${licence}.${chips.length ? ' Extras: ' + chips.join(', ') + '.' : ''} Please send availability and pricing.`
    );
    window.open(`https://wa.me/971500999733?text=${msg}`, '_blank');
  };

  const CHIPS = ['Baby seat', 'Additional driver', 'Full insurance', 'Zero deposit', 'Airport pick-up', 'Unlimited km', 'Oman border pass'];

  return (
    <div className="bg-white rounded-2xl shadow-[0_8px_60px_rgba(0,0,0,0.25)] overflow-hidden border border-gray-100">
      {/* ── Tabs ── */}
      <div className="flex items-center gap-1 p-3 pb-2">
        <div className="inline-flex items-center gap-1 p-1 bg-gray-100/80 rounded-full border border-gray-200/60">
          {(['Daily', 'Weekly', 'Monthly', 'With driver'] as RentalTab[]).map((t) => (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={cn(
                'px-5 py-2 rounded-full text-[13px] font-grotesk font-semibold transition-all duration-300',
                tab === t
                  ? 'bg-gray-900 text-white shadow-md'
                  : 'text-gray-500 hover:text-gray-900 hover:bg-gray-200/50'
              )}
            >
              {t}
            </button>
          ))}
        </div>
      </div>

      {/* ── Fields ── */}
      <div className="p-4 pb-3">
        {/* Row 1: Location + Dates */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-2 mb-2">
          {/* Delivery Location */}
          <div className="bg-gray-50 border border-gray-200 rounded-xl p-3 hover:border-orange-400 transition-colors">
            <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">Delivery Location</label>
            <select
              className="w-full bg-transparent text-gray-900 text-[14px] font-medium border-none focus:outline-none cursor-pointer"
              value={delivery}
              onChange={(e) => setDelivery(e.target.value)}
            >
              <option value="">Marina, Karama, DXB T3…</option>
              <option value="Dubai Airport T1">Dubai Airport — DXB T1</option>
              <option value="Dubai Airport T3">Dubai Airport — DXB T3</option>
              <option value="Al Karama">Al Karama, Dubai</option>
              <option value="Downtown Dubai">Downtown Dubai</option>
              <option value="JBR Marina">JBR, Dubai Marina</option>
            </select>
          </div>

          {/* Return Location */}
          <div className="bg-gray-50 border border-gray-200 rounded-xl p-3 hover:border-orange-400 transition-colors">
            <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">Return Location</label>
            <select className="w-full bg-transparent text-gray-900 text-[14px] font-medium border-none focus:outline-none cursor-pointer">
              <option>Same as delivery</option>
              <option>Dubai Airport — DXB T1</option>
              <option>Dubai Airport — DXB T3</option>
              <option>Al Karama, Dubai</option>
            </select>
          </div>

          {/* Pick-up */}
          <div className="bg-gray-50 border border-gray-200 rounded-xl p-3 hover:border-orange-400 transition-colors">
            <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">Pick-up</label>
            <input
              type="datetime-local"
              className="w-full bg-transparent text-gray-900 text-[14px] font-medium border-none focus:outline-none"
              aria-label="Pick-up date and time"
            />
          </div>

          {/* Return */}
          <div className="bg-gray-50 border border-gray-200 rounded-xl p-3 hover:border-orange-400 transition-colors">
            <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">Return</label>
            <input
              type="datetime-local"
              className="w-full bg-transparent text-gray-900 text-[14px] font-medium border-none focus:outline-none"
              aria-label="Return date and time"
            />
          </div>
        </div>

        {/* Row 2: Car details */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-2 mb-3">
          {/* Car Type */}
          <div className={cn(
            'bg-gray-50 border rounded-xl p-3 hover:border-orange-400 transition-colors',
            carType ? 'border-orange-400 bg-orange-50/30' : 'border-gray-200'
          )}>
            <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">Car Type</label>
            <select
              className="w-full bg-transparent text-gray-900 text-[14px] font-medium border-none focus:outline-none cursor-pointer"
              value={carType}
              onChange={(e) => setCarType(e.target.value)}
            >
              <option value="">Any — advise me</option>
              <option value="Sedan">Sedan</option>
              <option value="Hatchback">Hatchback</option>
              <option value="SUV">SUV</option>
              <option value="7 Seater">7 Seater</option>
              <option value="Coupe">Coupe / Muscle</option>
            </select>
          </div>

          {/* Driver Age */}
          <div className="bg-gray-50 border border-gray-200 rounded-xl p-3 hover:border-orange-400 transition-colors">
            <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">Driver Age</label>
            <select
              className="w-full bg-transparent text-gray-900 text-[14px] font-medium border-none focus:outline-none cursor-pointer"
              value={driverAge}
              onChange={(e) => setDriverAge(e.target.value)}
            >
              <option>21+</option>
              <option>25+</option>
              <option>30+</option>
            </select>
          </div>

          {/* Licence */}
          <div className="bg-gray-50 border border-gray-200 rounded-xl p-3 hover:border-orange-400 transition-colors">
            <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">Licence</label>
            <select
              className="w-full bg-transparent text-gray-900 text-[14px] font-medium border-none focus:outline-none cursor-pointer"
              value={licence}
              onChange={(e) => setLicence(e.target.value)}
            >
              <option>UAE licence</option>
              <option>International licence</option>
              <option>GCC licence</option>
            </select>
          </div>

          {/* Promo Code */}
          <div className="bg-gray-50 border border-gray-200 rounded-xl p-3 hover:border-orange-400 transition-colors">
            <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">Promo Code</label>
            <input
              type="text"
              placeholder="Optional"
              value={promo}
              onChange={(e) => setPromo(e.target.value)}
              className="w-full bg-transparent text-gray-900 text-[14px] font-medium border-none focus:outline-none placeholder:text-gray-300"
            />
          </div>
        </div>

        {/* Chips */}
        <div className="flex flex-wrap gap-2 mb-3">
          {CHIPS.map((chip) => (
            <button
              key={chip}
              type="button"
              onClick={() => toggleChip(chip)}
              className={cn(
                'text-[12px] font-sans border rounded-full px-3.5 py-1.5 transition-all duration-200',
                chips.includes(chip)
                  ? 'bg-gray-900 text-white border-gray-900'
                  : 'text-gray-500 border-gray-200 hover:border-gray-400 hover:text-gray-700'
              )}
            >
              {chip}
            </button>
          ))}
        </div>

        {/* Bottom CTA */}
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 pt-2 border-t border-gray-100">
          <span className="flex items-center gap-2 text-[12px] text-gray-400">
            <span className="w-2 h-2 rounded-full bg-green-400 animate-pulse shrink-0" />
            Your request opens in WhatsApp — quote in minutes, no signup.
          </span>
          <motion.button
            whileHover={{ scale: 1.03, y: -1 }}
            whileTap={{ scale: 0.97 }}
            onClick={handleGetRate}
            className="bg-gray-900 hover:bg-gray-800 text-white font-grotesk font-semibold text-[14px] px-7 py-3 rounded-full transition-colors whitespace-nowrap"
          >
            Get my best rate →
          </motion.button>
        </div>
      </div>
    </div>
  );
};

// ─── Hero ─────────────────────────────────────────────────────────
const Hero: React.FC = () => {
  const heroRef = useRef<HTMLElement>(null);
  const { scrollY } = useScroll();
  const textY = useTransform(scrollY, [0, 500], [0, -50]);

  const handleWhatsApp = () => {
    window.open('https://wa.me/971500999733?text=Hi%20Falcon%20View%2C%20I%27d%20like%20to%20book%20a%20car', '_blank');
  };

  return (
    <section
      id="top"
      ref={heroRef}
      className="relative"
      style={{ background: '#0D0D0D' }}
      aria-label="Falcon View — Drive Dubai, delivered to you"
    >
      {/* Ambient glow */}
      <div className="absolute inset-0 pointer-events-none" aria-hidden>
        <div style={{ background: 'radial-gradient(ellipse at 65% 50%, rgba(255,107,0,0.07) 0%, transparent 60%)' }} className="absolute inset-0" />
        <div style={{ background: 'radial-gradient(ellipse at 20% 85%, rgba(255,107,0,0.04) 0%, transparent 50%)' }} className="absolute inset-0" />
      </div>

      {/* ── Top section: Headline + Logo card ── */}
      <motion.div
        style={{ y: textY }}
        className="relative z-10 section-container pt-32 pb-12 flex flex-col lg:flex-row items-center gap-12"
      >
        {/* LEFT */}
        <div className="flex-1 flex flex-col gap-7 lg:pr-8">
          {/* Badge */}
          <motion.div
            initial={{ opacity: 0, y: 14 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, ease: ease.elegant, delay: 0.1 }}
            className="inline-flex items-center gap-2 self-start"
          >
            <span className="w-2 h-2 rounded-full bg-green-400 animate-pulse" />
            <span className="font-sans text-[13px] text-white/60 border border-white/10 bg-white/5 px-4 py-1.5 rounded-full">
              Available today · Free delivery across Dubai
            </span>
          </motion.div>

          {/* Headline */}
          <div>
            <motion.h1
              className="font-grotesk font-extrabold tracking-tight"
              style={{ fontSize: 'clamp(3rem,7vw,5.5rem)', lineHeight: 1.05 }}
            >
              {['Drive', 'Dubai.'].map((w, i) => (
                <motion.span key={w} className="text-white inline-block mr-[0.2em]"
                  initial={{ opacity: 0, y: 40 }} animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.7, ease: ease.elegant, delay: 0.2 + i * 0.1 }}>
                  {w}
                </motion.span>
              ))}
              <br />
              <motion.span className="text-orange-500 inline-block"
                initial={{ opacity: 0, y: 40 }} animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.7, ease: ease.elegant, delay: 0.4 }}>
                Delivered
              </motion.span>
              <motion.span className="text-white inline-block ml-[0.2em]"
                initial={{ opacity: 0, y: 40 }} animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.7, ease: ease.elegant, delay: 0.5 }}>
                to you.
              </motion.span>
            </motion.h1>
          </div>

          {/* Subtext */}
          <motion.p
            className="text-white/55 text-[16px] leading-relaxed max-w-lg"
            initial={{ opacity: 0, y: 18 }} animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, ease: ease.elegant, delay: 0.65 }}>
            Sedans, SUVs and 7-seaters on daily, weekly or monthly plans. Pick your car, drop a pin — we bring the keys anywhere in Dubai.
          </motion.p>

          {/* CTAs */}
          <motion.div className="flex flex-wrap gap-3"
            initial={{ opacity: 0, y: 18 }} animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, ease: ease.elegant, delay: 0.75 }}>
            <motion.button
              whileHover={{ scale: 1.03, y: -2 }} whileTap={{ scale: 0.97 }}
              onClick={() => document.getElementById('fleet')?.scrollIntoView({ behavior: 'smooth' })}
              className="bg-orange-500 hover:bg-orange-400 text-white font-grotesk font-semibold text-[15px] px-8 py-4 rounded-full transition-colors shadow-[0_4px_20px_rgba(255,107,0,0.4)]"
            >
              Check availability
            </motion.button>
            <motion.button
              whileHover={{ scale: 1.03, y: -2 }} whileTap={{ scale: 0.97 }}
              onClick={handleWhatsApp}
              className="flex items-center gap-2.5 bg-white/8 border border-white/15 text-white font-grotesk font-semibold text-[15px] px-8 py-4 rounded-full hover:bg-white/15 hover:border-green-400/60 transition-all"
            >
              <MessageCircle size={18} />
              WhatsApp us
            </motion.button>
          </motion.div>

          {/* Stats */}
          <motion.div className="flex flex-wrap gap-10 pt-4 border-t border-white/10"
            initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 1.0 }}>
            <AnimatedStat value={18} suffix="+" label="cars ready now" />
            <AnimatedStat value={60} suffix=" min" label="average delivery" />
            <AnimatedStat value={24} suffix="/7" label="human support" />
            <AnimatedStat value={0} label="hidden fees" />
          </motion.div>
        </div>

        {/* RIGHT: floating logo */}
        <motion.div className="flex-1 flex items-center justify-center"
          initial={{ opacity: 0, x: 40 }} animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.9, ease: ease.elegant, delay: 0.4 }}>
          <FloatingLogoCard />
        </motion.div>
      </motion.div>

      {/* ── Booking Form Card — white, at bottom of dark hero ── */}
      <motion.div
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.7, ease: ease.elegant, delay: 1.1 }}
        className="relative z-10 section-container pb-16"
      >
        <BookingCard />
      </motion.div>

      {/* Scroll indicator */}
      <motion.div
        className="absolute bottom-16 left-1/2 -translate-x-1/2 z-10 flex flex-col items-center gap-1"
        initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 2 }} aria-hidden>
        <motion.div
          className="w-[1px] h-8 bg-gradient-to-b from-orange-500/60 to-transparent"
          animate={{ scaleY: [0.3, 1, 0.3], opacity: [0.4, 1, 0.4] }}
          transition={{ duration: 2, repeat: Infinity }}
        />
      </motion.div>
    </section>
  );
};

export default Hero;
