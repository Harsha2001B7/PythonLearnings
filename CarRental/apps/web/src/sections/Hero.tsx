import React, { useState, useRef } from 'react';
import { openWhatsApp, getWhatsAppUrl } from '../utils/whatsapp';
import { motion, useScroll, useTransform, AnimatePresence } from 'framer-motion';
import {
  MessageCircle,
  X,
  CheckCircle2,
  AlertCircle,
  Info,
  Star,
} from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useCountUp } from '../hooks/useCountUp';
import { ease } from '../lib/easing';
import { falconLogo } from '../components/layout/Navbar';
import { cn } from '../lib/cn';
import { formatAED } from '../lib/formatters';

// ─── Animated Stat ────────────────────────────────────────────────────────────
const AnimatedStat: React.FC<{
  value: number;
  suffix?: string;
  label: string;
  decimals?: number;
}> = ({ value, suffix = '', label, decimals = 0 }) => {
  const { ref, display } = useCountUp({ target: value, suffix, decimals, duration: 2000 });
  return (
    <div className="flex flex-col gap-0.5">
      <span
        ref={ref}
        className="font-grotesk font-bold text-3xl sm:text-4xl text-white tracking-tight leading-none"
      >
        {display}
      </span>
      <span className="font-sans text-[12px] text-white/50">{label}</span>
    </div>
  );
};

// ─── Floating Logo Card ───────────────────────────────────────────────────────
const FloatingLogoCard: React.FC = () => (
  <motion.div
    className="relative flex flex-col items-center justify-center"
    animate={{ y: [-8, 8, -8] }}
    transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut' }}
  >
    {/* Circular glow behind logo */}
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

    {/* Logo */}
    <div className="relative flex items-center justify-center z-10">
      <img
        src={falconLogo}
        alt="Falcon View Wings"
        className="w-[380px] max-w-[80vw] h-auto object-contain drop-shadow-[0_8px_32px_rgba(255,107,0,0.35)]"
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
        width: '240px',
        height: '240px',
        top: '50%',
        left: '50%',
        transform: 'translate(-50%, -50%)',
      }}
    />

    {/* Floating dots */}
    <motion.div
      className="absolute w-2 h-2 bg-orange-500 rounded-full"
      style={{ top: '20%', right: '40px' }}
      animate={{ scale: [1, 1.3, 1], opacity: [0.6, 1, 0.6] }}
      transition={{ duration: 2, repeat: Infinity }}
    />
    <motion.div
      className="absolute w-1.5 h-1.5 bg-white/40 rounded-full"
      style={{ bottom: '25%', left: '35px' }}
      animate={{ scale: [1, 1.4, 1], opacity: [0.3, 0.8, 0.3] }}
      transition={{ duration: 2.5, repeat: Infinity, delay: 0.8 }}
    />
  </motion.div>
);

// ─── Booking Card Types & Constants ──────────────────────────────────────────
type RentalTab = 'Daily' | 'Weekly' | 'Monthly' | 'With driver';

const DELIVERY_LOCATIONS = [
  'Marina, Dubai Marina',
  'Business Bay',
  'Downtown Dubai',
  'Palm Jumeirah',
  'Jumeirah Village Circle (JVC)',
  'Jumeirah Lake Towers (JLT)',
  'Dubai Hills Estate',
  'DXB Airport — Terminal 1',
  'DXB Airport — Terminal 2',
  'DXB Airport — Terminal 3',
  'Al Barsha',
  'Al Karama',
  'Deira',
  'Bur Dubai',
  'Dubai Silicon Oasis',
  'DIFC',
  'Jumeirah Beach Residence (JBR)',
  'Mirdif',
];

const DRIVER_AGES = ['18–20', '21–24', '25+', '30+', '40+'];
const LICENCES = ['UAE', 'GCC', 'International', 'UK', 'EU', 'US', 'India', 'Pakistan', 'Other'];
const CAR_TYPES = ['Any', 'Economy', 'Sedan', 'Hatchback', 'SUV', '7 Seater', 'Coupe / Muscle'];
const VALID_PROMOS: Record<string, string> = {
  FALCON10: '10% Off',
  WELCOME5: '5% Off',
  DUBAI2026: 'AED 50 Off',
};
const EXTRAS = [
  'Baby seat',
  'Additional driver',
  'Zero deposit',
  'Airport pick-up',
  'Unlimited km',
  'Oman border pass',
];

// ─── Rate Calculation ─────────────────────────────────────────────────────────
function calcBestRate(tab: RentalTab, pickupDate: string, returnDate: string) {
  if (!pickupDate || !returnDate) return null;
  const days = Math.max(
    1,
    Math.ceil(
      (new Date(returnDate).getTime() - new Date(pickupDate).getTime()) / 86400000
    )
  );
  const isWeekly = days >= 7 && days < 30;
  const isMonthly = days >= 30;
  const rateType = isMonthly ? 'Monthly' : isWeekly ? 'Weekly' : 'Daily';
  const tabMultiplier =
    tab === 'Daily' ? 1 : tab === 'Weekly' ? 0.87 : tab === 'Monthly' ? 0.65 : 1.15;
  const baseDaily = 150 * tabMultiplier;
  const estimatedTotal = isMonthly ? baseDaily * 30 : baseDaily * days;
  return {
    days,
    rateType,
    baseDaily: Math.round(baseDaily),
    estimatedTotal: Math.round(estimatedTotal),
    vat: Math.round(estimatedTotal * 0.05),
    deposit: 2000,
  };
}

// ─── SelectField ──────────────────────────────────────────────────────────────
const SelectField: React.FC<{
  label: string;
  value: string;
  onChange: (v: string) => void;
  options: string[];
  placeholder?: string;
  icon?: React.ReactNode;
}> = ({ label, value, onChange, options, placeholder, icon }) => (
  <div className="bg-gray-50 border border-gray-200 rounded-xl p-3 hover:border-orange-400 focus-within:border-orange-400 transition-colors">
    <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">
      {icon && <span className="inline-flex mr-1 opacity-60">{icon}</span>}
      {label}
    </label>
    <select
      className="w-full bg-transparent text-gray-900 text-[13px] font-medium border-none focus:outline-none cursor-pointer"
      value={value}
      onChange={(e) => onChange(e.target.value)}
    >
      {placeholder && <option value="">{placeholder}</option>}
      {options.map((o) => (
        <option key={o} value={o}>
          {o}
        </option>
      ))}
    </select>
  </div>
);

// ─── Summary Modal ────────────────────────────────────────────────────────────
const SummaryModal: React.FC<{
  open: boolean;
  onClose: () => void;
  onConfirm: () => void;
  data: {
    tab: RentalTab;
    delivery: string;
    carType: string;
    pickupDate: string;
    returnDate: string;
    driverAge: string;
    licence: string;
    promo: string;
    extras: string[];
  };
}> = ({ open, onClose, onConfirm, data }) => {
  const calc = calcBestRate(data.tab, data.pickupDate, data.returnDate);
  const promoDiscount = VALID_PROMOS[data.promo.toUpperCase()];

  return (
    <AnimatePresence>
      {open && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 z-[999] bg-black/70 backdrop-blur-sm flex items-center justify-center p-4"
          onClick={onClose}
          role="dialog"
          aria-modal="true"
          aria-label="Booking summary"
        >
          <motion.div
            initial={{ scale: 0.93, y: 20 }}
            animate={{ scale: 1, y: 0 }}
            exit={{ scale: 0.93, y: 20 }}
            transition={{ type: 'spring', stiffness: 300, damping: 28 }}
            onClick={(e) => e.stopPropagation()}
            className="bg-white rounded-2xl w-full max-w-lg shadow-2xl overflow-hidden"
          >
            {/* Header */}
            <div className="bg-gray-900 px-6 py-5 flex items-start justify-between">
              <div>
                <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-orange-400 mb-1">
                  Booking Summary
                </p>
                <h2 className="font-grotesk font-bold text-xl text-white">Your Best Rate</h2>
              </div>
              <button
                onClick={onClose}
                className="w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center text-white/60 hover:text-white transition-colors"
                aria-label="Close"
              >
                <X size={15} />
              </button>
            </div>

            <div className="p-6 flex flex-col gap-5">
              {/* Details grid */}
              <div className="grid grid-cols-2 gap-3">
                {[
                  ['Rental Type', data.tab],
                  ['Delivery To', data.delivery || 'Not selected'],
                  ['Pick-up', data.pickupDate || '—'],
                  ['Return', data.returnDate || '—'],
                  ['Car Type', data.carType || 'Any'],
                  ['Driver Age', data.driverAge],
                  ['Licence', data.licence],
                ].map(([k, v]) => (
                  <div key={k}>
                    <p className="font-mono text-[10px] uppercase tracking-wider text-gray-400">
                      {k}
                    </p>
                    <p className="font-grotesk font-semibold text-[14px] text-gray-900 mt-0.5">
                      {v}
                    </p>
                  </div>
                ))}
              </div>

              {/* Price estimate */}
              {calc && (
                <div className="bg-orange-50 border border-orange-100 rounded-xl p-4">
                  <p className="font-mono text-[10px] uppercase tracking-wider text-orange-600 mb-3">
                    Estimated Price ({calc.days} day{calc.days > 1 ? 's' : ''})
                  </p>
                  <div className="space-y-2">
                    {[
                      [`Est. rental (${calc.rateType} rate)`, `~${formatAED(calc.estimatedTotal)}`],
                      ['VAT (5%)', `~${formatAED(calc.vat)}`],
                      ['Deposit (refundable)', formatAED(calc.deposit)],
                    ].map(([k, v]) => (
                      <div key={k} className="flex justify-between text-[13px]">
                        <span className="text-gray-600">{k}</span>
                        <span className="font-grotesk font-semibold text-gray-900">{v}</span>
                      </div>
                    ))}
                    <div className="border-t border-orange-200 pt-2 flex justify-between text-[14px]">
                      <span className="font-grotesk font-bold text-gray-900">Estimated Total</span>
                      <span className="font-grotesk font-bold text-orange-500">
                        ~{formatAED(calc.estimatedTotal + calc.vat + calc.deposit)}
                      </span>
                    </div>
                  </div>
                  {promoDiscount && (
                    <div className="mt-3 flex items-center gap-2 text-[12px] text-emerald-600 font-medium">
                      <CheckCircle2 size={13} />
                      Promo &quot;{data.promo.toUpperCase()}&quot; applied: {promoDiscount}
                    </div>
                  )}
                  <p className="text-[11px] text-gray-400 mt-2 flex items-center gap-1">
                    <Info size={11} />
                    Estimates only. Final pricing varies by vehicle. Prices exclude VAT.
                  </p>
                </div>
              )}

              {/* Extras */}
              {data.extras.length > 0 && (
                <div>
                  <p className="font-mono text-[10px] uppercase tracking-wider text-gray-400 mb-2">
                    Extras Requested
                  </p>
                  <div className="flex flex-wrap gap-1.5">
                    {data.extras.map((e) => (
                      <span
                        key={e}
                        className="text-[11px] bg-gray-100 text-gray-700 px-2.5 py-1 rounded-full"
                      >
                        {e}
                      </span>
                    ))}
                  </div>
                </div>
              )}

              {/* CTAs */}
              <div className="flex flex-col gap-2">
                <button
                  onClick={onConfirm}
                  className="flex items-center justify-center gap-2 bg-gray-900 hover:bg-gray-800 text-white font-grotesk font-bold text-[14px] py-4 rounded-xl transition-colors"
                >
                  Browse Matching Fleet →
                </button>
                <a
                  href={getWhatsAppUrl(
                    `Hi Falcon View! Rental: ${data.tab}, ${calc?.days || '?'} days. Delivery to: ${
                      data.delivery || 'TBD'
                    }. Car type: ${data.carType || 'Any'}. Driver age: ${data.driverAge}. Licence: ${
                      data.licence
                    }.${data.extras.length ? ' Extras: ' + data.extras.join(', ') : ''}${
                      data.promo ? '. Promo: ' + data.promo : ''
                    }`
                  )}
                  target="_blank"
                  rel="noopener noreferrer"
                  onClick={onClose}
                  className="flex items-center justify-center gap-2 bg-green-500 hover:bg-green-600 text-white font-grotesk font-semibold text-[14px] py-3.5 rounded-xl transition-colors shadow-lg shadow-green-500/20"
                >
                  <MessageCircle size={15} /> Confirm via WhatsApp
                </a>
              </div>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};

// ─── Booking Card ─────────────────────────────────────────────────────────────
const BookingCard: React.FC = () => {
  const navigate = useNavigate();
  const [tab, setTab] = useState<RentalTab>('Daily');
  const [extras, setExtras] = useState<string[]>([]);
  const [delivery, setDelivery] = useState('');
  const [returnSame, setReturnSame] = useState(true);
  const [returnLoc, setReturnLoc] = useState('');
  const [pickupDate, setPickupDate] = useState('');
  const [returnDate, setReturnDate] = useState('');
  const [carType, setCarType] = useState('');
  const [driverAge, setDriverAge] = useState('25+');
  const [licence, setLicence] = useState('UAE');
  const [promo, setPromo] = useState('');
  const [promoStatus, setPromoStatus] = useState<'idle' | 'valid' | 'invalid'>('idle');
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [modalOpen, setModalOpen] = useState(false);

  const toggleExtra = (c: string) =>
    setExtras((prev) => (prev.includes(c) ? prev.filter((x) => x !== c) : [...prev, c]));

  const validatePromo = () => {
    if (!promo) { setPromoStatus('idle'); return; }
    setPromoStatus(VALID_PROMOS[promo.toUpperCase()] ? 'valid' : 'invalid');
  };

  const validate = () => {
    const e: Record<string, string> = {};
    if (!delivery) e.delivery = 'Please select a delivery location';
    if (!pickupDate) e.pickupDate = 'Pick-up date required';
    if (!returnDate) e.returnDate = 'Return date required';
    if (pickupDate && returnDate && new Date(returnDate) <= new Date(pickupDate))
      e.returnDate = 'Return must be after pick-up';
    setErrors(e);
    return Object.keys(e).length === 0;
  };

  const handleGetRate = () => {
    if (!validate()) return;
    setModalOpen(true);
  };

  const handleConfirmBrowse = () => {
    setModalOpen(false);
    const params = new URLSearchParams();
    if (carType && carType !== 'Any') {
      const catMap: Record<string, string> = {
        Economy: 'sedan',
        Sedan: 'sedan',
        Hatchback: 'hatchback',
        SUV: 'suv',
        '7 Seater': '7seater',
        'Coupe / Muscle': 'coupe',
      };
      const cat = catMap[carType];
      if (cat) params.set('category', cat);
    }
    navigate(`/fleet?${params.toString()}`);
  };

  const today = new Date().toISOString().split('T')[0];

  return (
    <>
      <SummaryModal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        onConfirm={handleConfirmBrowse}
        data={{ tab, delivery, carType, pickupDate, returnDate, driverAge, licence, promo, extras }}
      />

      <div className="bg-white rounded-2xl shadow-[0_8px_60px_rgba(0,0,0,0.25)] overflow-hidden border border-gray-100">
        {/* Tabs */}
        <div className="flex items-center gap-1 p-3 pb-2">
          <div className="inline-flex items-center gap-1 p-1 bg-gray-100/80 rounded-full border border-gray-200/60">
            {(['Daily', 'Weekly', 'Monthly', 'With driver'] as RentalTab[]).map((t) => (
              <button
                key={t}
                onClick={() => setTab(t)}
                className={cn(
                  'px-4 py-2 rounded-full text-[12px] sm:text-[13px] font-grotesk font-semibold transition-all duration-300',
                  tab === t
                    ? 'bg-gray-900 text-white shadow-md'
                    : 'text-gray-500 hover:text-gray-900 hover:bg-gray-200/50'
                )}
                aria-pressed={tab === t}
              >
                {t}
              </button>
            ))}
          </div>
        </div>

        {/* Fields */}
        <div className="p-4 pb-3">
          {/* Row 1: Locations + Dates */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-2 mb-2">
            {/* Delivery Location */}
            <div
              className={cn(
                'bg-gray-50 border rounded-xl p-3 transition-colors',
                errors.delivery
                  ? 'border-red-400'
                  : 'border-gray-200 hover:border-orange-400 focus-within:border-orange-400'
              )}
            >
              <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">
                Delivery Location
              </label>
              <select
                className="w-full bg-transparent text-gray-900 text-[13px] font-medium border-none focus:outline-none cursor-pointer"
                value={delivery}
                onChange={(e) => {
                  setDelivery(e.target.value);
                  setErrors((prev) => ({ ...prev, delivery: '' }));
                }}
                aria-invalid={!!errors.delivery}
              >
                <option value="">Select area…</option>
                {DELIVERY_LOCATIONS.map((l) => (
                  <option key={l} value={l}>
                    {l}
                  </option>
                ))}
              </select>
              {errors.delivery && (
                <p className="text-red-500 text-[10px] mt-0.5 flex items-center gap-1">
                  <AlertCircle size={9} />
                  {errors.delivery}
                </p>
              )}
            </div>

            {/* Return Location */}
            <div className="bg-gray-50 border border-gray-200 rounded-xl p-3 hover:border-orange-400 transition-colors">
              <div className="flex items-center justify-between mb-1">
                <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400">
                  Return Location
                </label>
                <button
                  onClick={() => setReturnSame((v) => !v)}
                  className={cn(
                    'text-[9px] font-mono uppercase tracking-wider px-1.5 py-0.5 rounded transition-colors',
                    returnSame ? 'bg-orange-100 text-orange-600' : 'bg-gray-200 text-gray-500'
                  )}
                  aria-pressed={returnSame}
                >
                  {returnSame ? 'Same' : 'Custom'}
                </button>
              </div>
              {returnSame ? (
                <p className="text-[13px] font-medium text-gray-500 italic">Same as delivery</p>
              ) : (
                <select
                  className="w-full bg-transparent text-gray-900 text-[13px] font-medium border-none focus:outline-none cursor-pointer"
                  value={returnLoc}
                  onChange={(e) => setReturnLoc(e.target.value)}
                >
                  <option value="">Select area…</option>
                  {DELIVERY_LOCATIONS.map((l) => (
                    <option key={l} value={l}>
                      {l}
                    </option>
                  ))}
                </select>
              )}
            </div>

            {/* Pick-up Date */}
            <div
              className={cn(
                'bg-gray-50 border rounded-xl p-3 transition-colors',
                errors.pickupDate
                  ? 'border-red-400'
                  : 'border-gray-200 hover:border-orange-400 focus-within:border-orange-400'
              )}
            >
              <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">
                Pick-up Date
              </label>
              <input
                type="date"
                value={pickupDate}
                min={today}
                onChange={(e) => {
                  setPickupDate(e.target.value);
                  setErrors((prev) => ({ ...prev, pickupDate: '' }));
                }}
                className="w-full bg-transparent text-gray-900 text-[13px] font-medium border-none focus:outline-none"
                aria-label="Pick-up date"
                aria-invalid={!!errors.pickupDate}
              />
              {errors.pickupDate && (
                <p className="text-red-500 text-[10px] mt-0.5 flex items-center gap-1">
                  <AlertCircle size={9} />
                  {errors.pickupDate}
                </p>
              )}
            </div>

            {/* Return Date */}
            <div
              className={cn(
                'bg-gray-50 border rounded-xl p-3 transition-colors',
                errors.returnDate
                  ? 'border-red-400'
                  : 'border-gray-200 hover:border-orange-400 focus-within:border-orange-400'
              )}
            >
              <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">
                Return Date
              </label>
              <input
                type="date"
                value={returnDate}
                min={pickupDate || today}
                onChange={(e) => {
                  setReturnDate(e.target.value);
                  setErrors((prev) => ({ ...prev, returnDate: '' }));
                }}
                className="w-full bg-transparent text-gray-900 text-[13px] font-medium border-none focus:outline-none"
                aria-label="Return date"
                aria-invalid={!!errors.returnDate}
              />
              {errors.returnDate && (
                <p className="text-red-500 text-[10px] mt-0.5 flex items-center gap-1">
                  <AlertCircle size={9} />
                  {errors.returnDate}
                </p>
              )}
            </div>
          </div>

          {/* Row 2: Car details */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-2 mb-3">
            <SelectField
              label="Car Type"
              value={carType}
              onChange={setCarType}
              options={CAR_TYPES}
              placeholder="Any — advise me"
            />
            <SelectField
              label="Driver Age"
              value={driverAge}
              onChange={setDriverAge}
              options={DRIVER_AGES}
            />
            <SelectField
              label="Licence"
              value={licence}
              onChange={setLicence}
              options={LICENCES}
            />

            {/* Promo Code */}
            <div
              className={cn(
                'bg-gray-50 border rounded-xl p-3 transition-colors',
                promoStatus === 'valid'
                  ? 'border-emerald-400 bg-emerald-50/30'
                  : promoStatus === 'invalid'
                  ? 'border-red-400'
                  : 'border-gray-200 hover:border-orange-400'
              )}
            >
              <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">
                Promo Code
              </label>
              <div className="flex items-center gap-1">
                <input
                  type="text"
                  placeholder="Optional"
                  value={promo}
                  onChange={(e) => {
                    setPromo(e.target.value);
                    setPromoStatus('idle');
                  }}
                  onBlur={validatePromo}
                  className="flex-1 bg-transparent text-gray-900 text-[13px] font-medium border-none focus:outline-none placeholder:text-gray-300 uppercase"
                  aria-label="Promo code"
                />
                {promoStatus === 'valid' && (
                  <CheckCircle2 size={14} className="text-emerald-500 shrink-0" />
                )}
                {promoStatus === 'invalid' && (
                  <AlertCircle size={14} className="text-red-400 shrink-0" />
                )}
              </div>
              {promoStatus === 'valid' && (
                <p className="text-emerald-600 text-[10px] mt-0.5">
                  {VALID_PROMOS[promo.toUpperCase()]} applied!
                </p>
              )}
              {promoStatus === 'invalid' && (
                <p className="text-red-500 text-[10px] mt-0.5">Invalid promo code</p>
              )}
            </div>
          </div>

          {/* Extras */}
          <div className="flex flex-wrap gap-2 mb-3">
            {EXTRAS.map((chip) => (
              <button
                key={chip}
                type="button"
                onClick={() => toggleExtra(chip)}
                className={cn(
                  'text-[12px] font-sans border rounded-full px-3.5 py-1.5 transition-all duration-200',
                  extras.includes(chip)
                    ? 'bg-gray-900 text-white border-gray-900'
                    : 'text-gray-500 border-gray-200 hover:border-gray-400 hover:text-gray-700'
                )}
                aria-pressed={extras.includes(chip)}
              >
                {chip}
              </button>
            ))}
          </div>

          {/* Bottom CTA row */}
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 pt-2 border-t border-gray-100">
            <span className="flex items-center gap-2 text-[12px] text-gray-400">
              <span className="w-2 h-2 rounded-full bg-green-400 animate-pulse shrink-0" />
              Instant quote · No card required · WhatsApp confirmation
            </span>
            <motion.button
              whileHover={{ scale: 1.03, y: -1 }}
              whileTap={{ scale: 0.97 }}
              onClick={handleGetRate}
              className="bg-gray-900 hover:bg-gray-800 text-white font-grotesk font-bold text-[13px] px-7 py-3 rounded-xl transition-colors whitespace-nowrap"
            >
              Get My Best Rate →
            </motion.button>
          </div>
        </div>
      </div>
    </>
  );
};

// ─── Ambient Particle ─────────────────────────────────────────────────────────
const AmbientParticle: React.FC<{
  x: string; y: string; size: number; delay: number; dur: number; color?: string;
}> = ({ x, y, size, delay, dur, color = 'rgba(255,160,60,0.55)' }) => (
  <motion.div
    className="absolute rounded-full pointer-events-none"
    style={{ left: x, top: y, width: size, height: size, background: color, filter: 'blur(1px)' }}
    animate={{ opacity: [0, 1, 0], scale: [0.6, 1.4, 0.6], y: [0, -18, 0] }}
    transition={{ duration: dur, repeat: Infinity, delay, ease: 'easeInOut' }}
    aria-hidden
  />
);

// ─── Luxury Trust Badge ────────────────────────────────────────────────────────
const TrustBadge: React.FC<{ icon: React.ReactNode; label: string; sub: string; delay: number }> = ({
  icon, label, sub, delay,
}) => (
  <motion.div
    initial={{ opacity: 0, y: 10 }}
    animate={{ opacity: 1, y: 0 }}
    transition={{ duration: 0.5, delay }}
    whileHover={{ y: -2, backgroundColor: 'rgba(255,255,255,0.06)' }}
    className="flex items-center gap-2.5 px-3.5 py-2 rounded-xl border border-white/8 bg-white/3 backdrop-blur-sm cursor-default transition-colors duration-300"
  >
    <span className="text-orange-400/90 shrink-0">{icon}</span>
    <div className="flex flex-col leading-tight">
      <span className="font-grotesk font-semibold text-[12px] text-white/90 tracking-[-0.01em]">{label}</span>
      <span className="font-mono text-[9px] uppercase tracking-[0.12em] text-white/35">{sub}</span>
    </div>
  </motion.div>
);

// ─── Hero ─────────────────────────────────────────────────────────────────────
const Hero: React.FC = () => {
  const heroRef = useRef<HTMLElement>(null);
  const { scrollY } = useScroll();
  const textY = useTransform(scrollY, [0, 600], [0, -60]);
  const bgY  = useTransform(scrollY, [0, 600], [0, 30]);

  // Mouse parallax
  const [mouse, setMouse] = React.useState({ x: 0, y: 0 });
  const handleMouseMove = React.useCallback((e: React.MouseEvent<HTMLElement>) => {
    const { left, top, width, height } = e.currentTarget.getBoundingClientRect();
    setMouse({
      x: ((e.clientX - left) / width - 0.5) * 14,
      y: ((e.clientY - top)  / height - 0.5) * 10,
    });
  }, []);
  const handleMouseLeave = React.useCallback(() => setMouse({ x: 0, y: 0 }), []);

  const handleWhatsApp = () => {
    openWhatsApp("Hi Falcon View, I'd like to book a car");
  };

  return (
    <section
      id="top"
      ref={heroRef}
      className="relative overflow-hidden"
      style={{ background: '#0A0A0A' }}
      aria-label="FalconView — Dubai's Premier Luxury Car Rental"
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
    >
      {/* ── Background Image ── */}
      <motion.div
        className="absolute inset-x-0 top-0 h-[92%] z-0 pointer-events-none"
        style={{ y: bgY }}
      >
        <img
          src="/falconviewbackground.png"
          alt="Dubai luxury fleet"
          className="w-full h-full object-cover object-center opacity-[0.78]"
        />
        {/* Left-to-right read zone */}
        <div className="absolute inset-0 bg-gradient-to-r from-[#0A0A0A]/90 via-[#0A0A0A]/45 to-transparent" />
        {/* Top vignette */}
        <div className="absolute inset-x-0 top-0 h-32 bg-gradient-to-b from-[#0A0A0A]/60 to-transparent" />
        {/* Bottom fade */}
        <div className="absolute inset-x-0 bottom-0 h-72 bg-gradient-to-t from-[#0A0A0A] to-transparent" />
        {/* Warm golden glow — right side vehicle zone */}
        <div
          className="absolute inset-0 pointer-events-none"
          style={{
            background:
              'radial-gradient(ellipse 55% 60% at 78% 58%, rgba(255,140,30,0.10) 0%, rgba(255,100,0,0.05) 40%, transparent 70%)',
          }}
        />
      </motion.div>

      {/* ── Ambient Glow Layers ── */}
      <div className="absolute inset-0 pointer-events-none z-0" aria-hidden>
        {/* Orange left glow */}
        <motion.div
          className="absolute inset-0"
          animate={{ opacity: [0.8, 1, 0.8] }}
          transition={{ duration: 8, repeat: Infinity, ease: 'easeInOut' }}
          style={{ background: 'radial-gradient(ellipse 50% 55% at 10% 60%, rgba(255,107,0,0.08) 0%, transparent 70%)' }}
        />
        {/* Warm gold center-right */}
        <motion.div
          className="absolute inset-0"
          animate={{ opacity: [0.6, 1, 0.6] }}
          transition={{ duration: 12, repeat: Infinity, ease: 'easeInOut', delay: 2 }}
          style={{ background: 'radial-gradient(ellipse 60% 50% at 70% 40%, rgba(255,160,50,0.07) 0%, transparent 65%)' }}
        />
      </div>

      {/* ── Ambient Particles ── */}
      <div className="absolute inset-0 z-0 pointer-events-none overflow-hidden" aria-hidden>
        <AmbientParticle x="8%"  y="25%" size={3} delay={0}   dur={7}  />
        <AmbientParticle x="15%" y="70%" size={2} delay={1.2} dur={9}  color="rgba(255,200,100,0.45)" />
        <AmbientParticle x="22%" y="45%" size={2} delay={3.1} dur={11} />
        <AmbientParticle x="38%" y="18%" size={2} delay={0.8} dur={8}  color="rgba(255,200,100,0.4)" />
        <AmbientParticle x="78%" y="22%" size={3} delay={2.4} dur={10} />
        <AmbientParticle x="85%" y="65%" size={2} delay={4}   dur={8}  color="rgba(255,200,100,0.5)" />
        <AmbientParticle x="92%" y="38%" size={2} delay={1.6} dur={12} />
      </div>

      {/* ── Main Content ── */}
      <div className="relative w-full">
        <motion.div
          style={{ y: textY }}
          className="relative z-10 section-container pt-40 pb-20 flex flex-col lg:flex-row items-start gap-12 lg:gap-20"
        >
          {/* ── LEFT Column ── */}
          <div className="flex-1 flex flex-col gap-10 lg:pr-10 max-w-[620px]">

            {/* Premium status pill */}
            <motion.div
              initial={{ opacity: 0, y: 12 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.7, ease: ease.elegant, delay: 0.1 }}
              className="self-start"
            >
              <div className="inline-flex items-center gap-2.5 px-4 py-2 rounded-full border border-white/10 bg-white/[0.04] backdrop-blur-md">
                {/* Live pulse ring */}
                <span className="relative flex h-2 w-2">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-60" />
                  <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-400" />
                </span>
                <span className="font-mono text-[10px] uppercase tracking-[0.18em] text-white/65">
                  36 Vehicles Available
                </span>
                <span className="w-px h-3 bg-white/15" />
                <span className="font-mono text-[10px] uppercase tracking-[0.18em] text-orange-400/80">
                  UAE-Wide Delivery
                </span>
              </div>
            </motion.div>

            {/* Headline */}
            <div className="flex flex-col" style={{ gap: '0.12em' }}>
              <motion.span
                className="block font-grotesk font-extrabold text-white leading-[0.93] tracking-[-0.035em]"
                style={{ fontSize: 'clamp(3rem,6.8vw,5.4rem)' }}
                initial={{ opacity: 0, y: 40 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.8, ease: ease.elegant, delay: 0.18 }}
              >
                Dubai's Premium
              </motion.span>

              <motion.h1
                className="font-grotesk font-extrabold text-white leading-[0.93] tracking-[-0.035em]"
                style={{ fontSize: 'clamp(3rem,6.8vw,5.4rem)' }}
                initial={{ opacity: 0, y: 40 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.8, ease: ease.elegant, delay: 0.28 }}
              >
                Car Rental.
              </motion.h1>

              {/* Orange accent with subtle warm gradient */}
              <motion.span
                className="block font-grotesk font-extrabold italic leading-[0.93] tracking-[-0.025em] relative"
                style={{
                  fontSize: 'clamp(2.5rem,5.6vw,4.4rem)',
                  background: 'linear-gradient(110deg, #FF6B00 0%, #FF9A30 55%, #FF6B00 100%)',
                  WebkitBackgroundClip: 'text',
                  WebkitTextFillColor: 'transparent',
                  backgroundClip: 'text',
                }}
                initial={{ opacity: 0, y: 40 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.8, ease: ease.elegant, delay: 0.38 }}
              >
                Delivered
              </motion.span>

              <motion.span
                className="block font-grotesk font-light text-white/55 leading-[1.1] tracking-[-0.01em]"
                style={{ fontSize: 'clamp(1.4rem,3vw,2.4rem)' }}
                initial={{ opacity: 0, y: 24 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.75, ease: ease.elegant, delay: 0.5 }}
              >
                to your door.
              </motion.span>
            </div>

            {/* Sub-copy */}
            <motion.p
              className="text-white/50 text-[14px] leading-[1.75] max-w-md font-grotesk tracking-[0.005em]"
              initial={{ opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.7, ease: ease.elegant, delay: 0.58 }}
            >
              Curated fleet. Concierge-level service. Every vehicle delivered,
              inspected, and ready — wherever you are in the UAE.
            </motion.p>

            {/* CTA Buttons */}
            <motion.div
              className="flex flex-wrap gap-3"
              initial={{ opacity: 0, y: 14 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.7, ease: ease.elegant, delay: 0.66 }}
            >
              {/* Primary — premium gradient */}
              <motion.button
                whileHover={{ scale: 1.025, y: -2 }}
                whileTap={{ scale: 0.975 }}
                onClick={() => document.getElementById('fleet')?.scrollIntoView({ behavior: 'smooth' })}
                className="relative overflow-hidden font-grotesk font-semibold text-[14px] text-white px-8 py-3.5 rounded-[16px] transition-shadow duration-300"
                style={{
                  background: 'linear-gradient(115deg, #E85D00 0%, #FF7A1A 50%, #E85D00 100%)',
                  backgroundSize: '200% 100%',
                  boxShadow: '0 4px 28px rgba(232,93,0,0.38), 0 1px 0 rgba(255,255,255,0.08) inset',
                }}
              >
                <motion.span
                  className="absolute inset-0 opacity-0 hover:opacity-100 transition-opacity duration-400"
                  style={{ background: 'linear-gradient(115deg, #FF7A1A 0%, #FFa040 50%, #FF7A1A 100%)' }}
                />
                <span className="relative z-10">Explore the Fleet</span>
              </motion.button>

              {/* Secondary — understated glass */}
              <motion.button
                whileHover={{ scale: 1.025, y: -2, borderColor: 'rgba(255,255,255,0.22)' }}
                whileTap={{ scale: 0.975 }}
                onClick={handleWhatsApp}
                className="flex items-center gap-2.5 font-grotesk font-medium text-[14px] text-white/80 px-7 py-3.5 rounded-[16px] border border-white/12 bg-white/[0.04] backdrop-blur-sm hover:text-white transition-all duration-300"
              >
                <MessageCircle size={15} className="text-emerald-400" />
                WhatsApp Concierge
              </motion.button>
            </motion.div>

            {/* Luxury Trust Badges */}
            <div className="flex flex-col gap-3">
              <motion.div
                className="w-12 h-px bg-gradient-to-r from-orange-500/60 to-transparent"
                initial={{ scaleX: 0, originX: 0 }}
                animate={{ scaleX: 1 }}
                transition={{ duration: 0.6, delay: 0.74 }}
              />
              <div className="flex flex-wrap gap-2">
                {[
                  { icon: <Star size={13} className="fill-orange-400" />, label: '4.9 Rating',       sub: 'Google Reviews',    delay: 0.76 },
                  { icon: <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M5 12h14M12 5l7 7-7 7"/></svg>, label: 'Free Delivery', sub: 'UAE-Wide',          delay: 0.82 },
                  { icon: <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>, label: 'Fully Insured', sub: 'Every Vehicle',    delay: 0.88 },
                  { icon: <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>, label: '24/7 Concierge', sub: 'Always On Call', delay: 0.94 },
                  { icon: <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="20 6 9 17 4 12"/></svg>, label: 'Instant Booking', sub: 'No Card Required', delay: 1.0  },
                ].map((b) => (
                  <TrustBadge key={b.label} icon={b.icon} label={b.label} sub={b.sub} delay={b.delay} />
                ))}
              </div>
            </div>

            {/* Animated Stats */}
            <motion.div
              className="flex flex-wrap gap-6 sm:gap-10 pt-5 border-t border-white/[0.08]"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 1.05 }}
            >
              <AnimatedStat value={100} suffix="+"    label="vehicles available"  />
              <AnimatedStat value={60}  suffix=" min" label="average delivery"    />
              <AnimatedStat value={5000} suffix="+"   label="happy customers"     />
              <AnimatedStat value={0}                 label="hidden fees"         />
            </motion.div>
          </div>

          {/* ── RIGHT Column — Logo with parallax + warm glow ── */}
          <motion.div
            className="flex-1 flex items-start justify-center relative pt-2"
            initial={{ opacity: 0, x: 40 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 1, ease: ease.elegant, delay: 0.4 }}
            animate-style={{ x: mouse.x * 0.6, y: mouse.y * 0.4 }}
          >
            {/* Warm golden halo behind logo */}
            <motion.div
              className="absolute rounded-full pointer-events-none"
              animate={{ opacity: [0.25, 0.5, 0.25], scale: [0.92, 1.06, 0.92] }}
              transition={{ duration: 6, repeat: Infinity, ease: 'easeInOut' }}
              style={{
                width: '360px', height: '360px',
                background: 'radial-gradient(circle, rgba(255,140,30,0.18) 0%, rgba(255,80,0,0.08) 45%, transparent 72%)',
                filter: 'blur(12px)',
              }}
            />

            {/* Floating logo */}
            <motion.div
              animate={{ y: [0, 20, 0] }}
              transition={{ duration: 5, repeat: Infinity, ease: 'easeInOut' }}
              className="relative z-10"
              style={{ x: mouse.x * 0.9, y: mouse.y * 0.6 } as React.CSSProperties}
            >
              {/* Orbit ring */}
              <motion.div
                className="absolute pointer-events-none"
                animate={{ rotate: 360 }}
                transition={{ duration: 28, repeat: Infinity, ease: 'linear' }}
                style={{
                  border: '1px dashed rgba(255,107,0,0.12)',
                  borderRadius: '50%',
                  width: '220px', height: '220px',
                  top: '50%', left: '50%',
                  transform: 'translate(-50%, -50%)',
                }}
              />
              {/* Counter-orbit ring */}
              <motion.div
                className="absolute pointer-events-none"
                animate={{ rotate: -360 }}
                transition={{ duration: 44, repeat: Infinity, ease: 'linear' }}
                style={{
                  border: '1px solid rgba(255,180,60,0.06)',
                  borderRadius: '50%',
                  width: '300px', height: '300px',
                  top: '50%', left: '50%',
                  transform: 'translate(-50%, -50%)',
                }}
              />

              <img
                src={falconLogo}
                alt="FalconView Wings"
                className="w-[420px] max-w-[82vw] h-auto object-contain drop-shadow-[0_12px_48px_rgba(255,107,0,0.32)]"
              />

              {/* Accent dots */}
              <motion.div
                className="absolute w-2 h-2 rounded-full bg-orange-500"
                style={{ top: '22%', right: '30px' }}
                animate={{ scale: [1, 1.4, 1], opacity: [0.5, 1, 0.5] }}
                transition={{ duration: 2.4, repeat: Infinity }}
              />
              <motion.div
                className="absolute w-1.5 h-1.5 rounded-full bg-white/30"
                style={{ bottom: '28%', left: '28px' }}
                animate={{ scale: [1, 1.5, 1], opacity: [0.2, 0.7, 0.2] }}
                transition={{ duration: 3.2, repeat: Infinity, delay: 1 }}
              />
              <motion.div
                className="absolute w-1 h-1 rounded-full"
                style={{ top: '60%', right: '15px', background: 'rgba(255,160,50,0.8)' }}
                animate={{ scale: [1, 1.6, 1], opacity: [0.3, 0.9, 0.3] }}
                transition={{ duration: 2.8, repeat: Infinity, delay: 0.5 }}
              />
            </motion.div>
          </motion.div>
        </motion.div>
      </div>

      {/* ── Scroll Indicator ── */}
      <motion.div
        className="absolute bottom-14 left-1/2 -translate-x-1/2 z-10 flex flex-col items-center gap-2"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 2.2 }}
        aria-hidden
      >
        <span className="font-mono text-[8px] uppercase tracking-[0.2em] text-white/25">Scroll</span>
        <motion.div
          className="w-px h-10 bg-gradient-to-b from-orange-500/50 to-transparent"
          animate={{ scaleY: [0.2, 1, 0.2], opacity: [0.3, 0.8, 0.3] }}
          transition={{ duration: 2.4, repeat: Infinity, ease: 'easeInOut' }}
        />
      </motion.div>
    </section>
  );
};

export default Hero;

