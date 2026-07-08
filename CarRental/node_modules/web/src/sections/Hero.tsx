import React, { useState, useRef, useCallback } from 'react';
import { motion, useScroll, useTransform, AnimatePresence } from 'framer-motion';
import { MessageCircle, MapPin, Calendar, ChevronDown, X, CheckCircle2, AlertCircle, Info } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useCountUp } from '../hooks/useCountUp';
import { ease, duration } from '../lib/easing';
import { falconLogo } from '../components/layout/Navbar';
import { cn } from '../lib/cn';
import { formatAED } from '../lib/formatters';

// â”€â”€â”€ Animated Stat â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

// â”€â”€â”€ Floating Logo Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

const DRIVER_AGES = ['18â€“20', '21â€“24', '25+', '30+', '40+'];
const LICENCES = ['UAE', 'GCC', 'International', 'UK', 'EU', 'US', 'India', 'Pakistan', 'Other'];
const CAR_TYPES = ['Any', 'Economy', 'Sedan', 'Hatchback', 'SUV', '7 Seater', 'Coupe / Muscle'];
const VALID_PROMOS: Record<string, string> = { 'FALCON10': '10% Off', 'WELCOME5': '5% Off', 'DUBAI2026': 'AED 50 Off' };
const EXTRAS = ['Baby seat', 'Additional driver', 'Zero deposit', 'Airport pick-up', 'Unlimited km', 'Oman border pass'];

// Rate calculation helper
function calcBestRate(tab: RentalTab, pickupDate: string, returnDate: string) {
  if (!pickupDate || !returnDate) return null;
  const days = Math.max(1, Math.ceil((new Date(returnDate).getTime() - new Date(pickupDate).getTime()) / 86400000));
  // Use approximate market average: daily 150, weekly 120, monthly 3500
  // This gives approximate pricing. Vehicle-specific pricing is on detail pages.
  const isWeekly = days >= 7 && days < 30;
  const isMonthly = days >= 30;
  const rateType = isMonthly ? 'Monthly' : isWeekly ? 'Weekly' : 'Daily';
  const tabMultiplier = tab === 'Daily' ? 1 : tab === 'Weekly' ? 0.87 : tab === 'Monthly' ? 0.65 : 1.15;
  const baseDaily = 150 * tabMultiplier;
  const estimatedTotal = isMonthly ? baseDaily * 30 : baseDaily * days;
  return { days, rateType, baseDaily: Math.round(baseDaily), estimatedTotal: Math.round(estimatedTotal), vat: Math.round(estimatedTotal * 0.05), deposit: 2000 };
}

// Premium SelectField
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
      {icon && <span className="inline-flex mr-1 opacity-60">{icon}</span>}{label}
    </label>
    <select
      className="w-full bg-transparent text-gray-900 text-[13px] font-medium border-none focus:outline-none cursor-pointer"
      value={value}
      onChange={(e) => onChange(e.target.value)}
    >
      {placeholder && <option value="">{placeholder}</option>}
      {options.map(o => <option key={o} value={o}>{o}</option>)}
    </select>
  </div>
);

// DateField
const DateField: React.FC<{ label: string; value: string; onChange: (v: string) => void; min?: string }> = ({ label, value, onChange, min }) => (
  <div className="bg-gray-50 border border-gray-200 rounded-xl p-3 hover:border-orange-400 focus-within:border-orange-400 transition-colors">
    <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">{label}</label>
    <input
      type="date"
      value={value}
      min={min || new Date().toISOString().split('T')[0]}
      onChange={(e) => onChange(e.target.value)}
      className="w-full bg-transparent text-gray-900 text-[13px] font-medium border-none focus:outline-none"
    />
  </div>
);

// Summary Modal
const SummaryModal: React.FC<{
  open: boolean;
  onClose: () => void;
  onConfirm: () => void;
  data: { tab: RentalTab; delivery: string; carType: string; pickupDate: string; returnDate: string; driverAge: string; licence: string; promo: string; extras: string[] };
}> = ({ open, onClose, onConfirm, data }) => {
  const calc = calcBestRate(data.tab, data.pickupDate, data.returnDate);
  const promoDiscount = VALID_PROMOS[data.promo.toUpperCase()];

  return (
    <AnimatePresence>
      {open && (
        <motion.div
          initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
          className="fixed inset-0 z-[999] bg-black/70 backdrop-blur-sm flex items-center justify-center p-4"
          onClick={onClose}
          role="dialog" aria-modal="true" aria-label="Booking summary"
        >
          <motion.div
            initial={{ scale: 0.93, y: 20 }} animate={{ scale: 1, y: 0 }} exit={{ scale: 0.93, y: 20 }}
            transition={{ type: 'spring', stiffness: 300, damping: 28 }}
            onClick={(e) => e.stopPropagation()}
            className="bg-white rounded-2xl w-full max-w-lg shadow-2xl overflow-hidden"
          >
            {/* Header */}
            <div className="bg-gray-900 px-6 py-5 flex items-start justify-between">
              <div>
                <p className="font-mono text-[10px] uppercase tracking-[0.2em] text-orange-400 mb-1">Booking Summary</p>
                <h2 className="font-grotesk font-bold text-xl text-white">Your Best Rate</h2>
              </div>
              <button onClick={onClose} className="w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center text-white/60 hover:text-white transition-colors" aria-label="Close">
                <X size={15} />
              </button>
            </div>

            <div className="p-6 flex flex-col gap-5">
              {/* Details */}
              <div className="grid grid-cols-2 gap-3">
                {[
                  ['Rental Type', data.tab],
                  ['Delivery To', data.delivery || 'Not selected'],
                  ['Pick-up', data.pickupDate || 'â€”'],
                  ['Return', data.returnDate || 'â€”'],
                  ['Car Type', data.carType || 'Any'],
                  ['Driver Age', data.driverAge],
                  ['Licence', data.licence],
                ].map(([k, v]) => (
                  <div key={k}>
                    <p className="font-mono text-[10px] uppercase tracking-wider text-gray-400">{k}</p>
                    <p className="font-grotesk font-semibold text-[14px] text-gray-900 mt-0.5">{v}</p>
                  </div>
                ))}
              </div>

              {/* Estimate */}
              {calc && (
                <div className="bg-orange-50 border border-orange-100 rounded-xl p-4">
                  <p className="font-mono text-[10px] uppercase tracking-wider text-orange-600 mb-3">Estimated Price ({calc.days} day{calc.days > 1 ? 's' : ''})</p>
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
                      <span className="font-grotesk font-bold text-orange-500">~{formatAED(calc.estimatedTotal + calc.vat + calc.deposit)}</span>
                    </div>
                  </div>
                  {promoDiscount && (
                    <div className="mt-3 flex items-center gap-2 text-[12px] text-emerald-600 font-medium">
                      <CheckCircle2 size={13} /> Promo "{data.promo.toUpperCase()}" applied: {promoDiscount}
                    </div>
                  )}
                  <p className="text-[11px] text-gray-400 mt-2 flex items-center gap-1">
                    <Info size={11} /> Estimates only. Final pricing varies by vehicle. Prices exclude VAT.
                  </p>
                </div>
              )}

              {data.extras.length > 0 && (
                <div>
                  <p className="font-mono text-[10px] uppercase tracking-wider text-gray-400 mb-2">Extras Requested</p>
                  <div className="flex flex-wrap gap-1.5">
                    {data.extras.map(e => <span key={e} className="text-[11px] bg-gray-100 text-gray-700 px-2.5 py-1 rounded-full">{e}</span>)}
                  </div>
                </div>
              )}

              {/* CTAs */}
              <div className="flex flex-col gap-2">
                <button
                  onClick={onConfirm}
                  className="flex items-center justify-center gap-2 bg-gray-900 hover:bg-gray-800 text-white font-grotesk font-bold text-[14px] py-4 rounded-xl transition-colors"
                >
                  Browse Matching Fleet â†’
                </button>
                <a
                  href={`https://wa.me/971500999733?text=${encodeURIComponent(`Hi Falcon View! Rental: ${data.tab}, ${calc?.days || '?'} days. Delivery to: ${data.delivery || 'TBD'}. Car type: ${data.carType || 'Any'}. Driver age: ${data.driverAge}. Licence: ${data.licence}.${data.extras.length ? ' Extras: ' + data.extras.join(', ') : ''}${data.promo ? '. Promo: ' + data.promo : ''}`)}`}
                  target="_blank" rel="noopener noreferrer"
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
    setExtras((prev) => prev.includes(c) ? prev.filter((x) => x !== c) : [...prev, c]);

  const validatePromo = () => {
    if (!promo) { setPromoStatus('idle'); return; }
    setPromoStatus(VALID_PROMOS[promo.toUpperCase()] ? 'valid' : 'invalid');
  };

  const validate = () => {
    const e: Record<string, string> = {};
    if (!delivery) e.delivery = 'Please select a delivery location';
    if (!pickupDate) e.pickupDate = 'Pick-up date required';
    if (!returnDate) e.returnDate = 'Return date required';
    if (pickupDate && returnDate && new Date(returnDate) <= new Date(pickupDate)) e.returnDate = 'Return must be after pick-up';
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
      const catMap: Record<string, string> = { 'Economy': 'sedan', 'Sedan': 'sedan', 'Hatchback': 'hatchback', 'SUV': 'suv', '7 Seater': '7seater', 'Coupe / Muscle': 'coupe' };
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
        {/* ── Tabs ── */}
        <div className="flex items-center gap-1 p-3 pb-2">
          <div className="inline-flex items-center gap-1 p-1 bg-gray-100/80 rounded-full border border-gray-200/60">
            {(['Daily', 'Weekly', 'Monthly', 'With driver'] as RentalTab[]).map((t) => (
              <button
                key={t}
                onClick={() => setTab(t)}
                className={cn(
                  'px-4 py-2 rounded-full text-[12px] sm:text-[13px] font-grotesk font-semibold transition-all duration-300',
                  tab === t ? 'bg-gray-900 text-white shadow-md' : 'text-gray-500 hover:text-gray-900 hover:bg-gray-200/50'
                )}
                aria-pressed={tab === t}
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
            <div className={cn('bg-gray-50 border rounded-xl p-3 transition-colors', errors.delivery ? 'border-red-400' : 'border-gray-200 hover:border-orange-400 focus-within:border-orange-400')}>
              <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">Delivery Location</label>
              <select
                className="w-full bg-transparent text-gray-900 text-[13px] font-medium border-none focus:outline-none cursor-pointer"
                value={delivery}
                onChange={(e) => { setDelivery(e.target.value); setErrors(prev => ({ ...prev, delivery: '' })); }}
                aria-invalid={!!errors.delivery}
              >
                <option value="">Select area…</option>
                {DELIVERY_LOCATIONS.map(l => <option key={l} value={l}>{l}</option>)}
              </select>
              {errors.delivery && <p className="text-red-500 text-[10px] mt-0.5 flex items-center gap-1"><AlertCircle size={9} />{errors.delivery}</p>}
            </div>

            {/* Return Location */}
            <div className="bg-gray-50 border border-gray-200 rounded-xl p-3 hover:border-orange-400 transition-colors">
              <div className="flex items-center justify-between mb-1">
                <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400">Return Location</label>
                <button
                  onClick={() => setReturnSame(v => !v)}
                  className={cn('text-[9px] font-mono uppercase tracking-wider px-1.5 py-0.5 rounded transition-colors', returnSame ? 'bg-orange-100 text-orange-600' : 'bg-gray-200 text-gray-500')}
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
                  value={returnLoc} onChange={(e) => setReturnLoc(e.target.value)}
                >
                  <option value="">Select area…</option>
                  {DELIVERY_LOCATIONS.map(l => <option key={l} value={l}>{l}</option>)}
                </select>
              )}
            </div>

            {/* Pick-up Date */}
            <div className={cn('bg-gray-50 border rounded-xl p-3 transition-colors', errors.pickupDate ? 'border-red-400' : 'border-gray-200 hover:border-orange-400 focus-within:border-orange-400')}>
              <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">Pick-up Date</label>
              <input
                type="date" value={pickupDate} min={today}
                onChange={(e) => { setPickupDate(e.target.value); setErrors(prev => ({ ...prev, pickupDate: '' })); }}
                className="w-full bg-transparent text-gray-900 text-[13px] font-medium border-none focus:outline-none"
                aria-label="Pick-up date" aria-invalid={!!errors.pickupDate}
              />
              {errors.pickupDate && <p className="text-red-500 text-[10px] mt-0.5 flex items-center gap-1"><AlertCircle size={9} />{errors.pickupDate}</p>}
            </div>

            {/* Return Date */}
            <div className={cn('bg-gray-50 border rounded-xl p-3 transition-colors', errors.returnDate ? 'border-red-400' : 'border-gray-200 hover:border-orange-400 focus-within:border-orange-400')}>
              <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">Return Date</label>
              <input
                type="date" value={returnDate} min={pickupDate || today}
                onChange={(e) => { setReturnDate(e.target.value); setErrors(prev => ({ ...prev, returnDate: '' })); }}
                className="w-full bg-transparent text-gray-900 text-[13px] font-medium border-none focus:outline-none"
                aria-label="Return date" aria-invalid={!!errors.returnDate}
              />
              {errors.returnDate && <p className="text-red-500 text-[10px] mt-0.5 flex items-center gap-1"><AlertCircle size={9} />{errors.returnDate}</p>}
            </div>
          </div>

          {/* Row 2: Car details */}
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-2 mb-3">
            {/* Car Type */}
            <SelectField label="Car Type" value={carType} onChange={setCarType} options={CAR_TYPES} placeholder="Any — advise me" />

            {/* Driver Age */}
            <SelectField label="Driver Age" value={driverAge} onChange={setDriverAge} options={DRIVER_AGES} />

            {/* Licence */}
            <SelectField label="Licence" value={licence} onChange={setLicence} options={LICENCES} />

            {/* Promo Code */}
            <div className={cn('bg-gray-50 border rounded-xl p-3 transition-colors', promoStatus === 'valid' ? 'border-emerald-400 bg-emerald-50/30' : promoStatus === 'invalid' ? 'border-red-400' : 'border-gray-200 hover:border-orange-400')}>
              <label className="block text-[10px] font-mono uppercase tracking-[0.16em] text-gray-400 mb-1">Promo Code</label>
              <div className="flex items-center gap-1">
                <input
                  type="text" placeholder="Optional" value={promo}
                  onChange={(e) => { setPromo(e.target.value); setPromoStatus('idle'); }}
                  onBlur={validatePromo}
                  className="flex-1 bg-transparent text-gray-900 text-[13px] font-medium border-none focus:outline-none placeholder:text-gray-300 uppercase"
                  aria-label="Promo code"
                />
                {promoStatus === 'valid' && <CheckCircle2 size={14} className="text-emerald-500 shrink-0" />}
                {promoStatus === 'invalid' && <AlertCircle size={14} className="text-red-400 shrink-0" />}
              </div>
              {promoStatus === 'valid' && <p className="text-emerald-600 text-[10px] mt-0.5">{VALID_PROMOS[promo.toUpperCase()]} applied!</p>}
              {promoStatus === 'invalid' && <p className="text-red-500 text-[10px] mt-0.5">Invalid promo code</p>}
            </div>
          </div>

          {/* Extras Chips */}
          <div className="flex flex-wrap gap-2 mb-3">
            {EXTRAS.map((chip) => (
              <button
                key={chip} type="button" onClick={() => toggleExtra(chip)}
                className={cn(
                  'text-[12px] font-sans border rounded-full px-3.5 py-1.5 transition-all duration-200',
                  extras.includes(chip) ? 'bg-gray-900 text-white border-gray-900' : 'text-gray-500 border-gray-200 hover:border-gray-400 hover:text-gray-700'
                )}
                aria-pressed={extras.includes(chip)}
              >
                {chip}
              </button>
            ))}
          </div>

          {/* Bottom CTA */}
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 pt-2 border-t border-gray-100">
            <span className="flex items-center gap-2 text-[12px] text-gray-400">
              <span className="w-2 h-2 rounded-full bg-green-400 animate-pulse shrink-0" />
              Instant quote · No card required · WhatsApp confirmation
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
    </>
  );
};

// â”€â”€â”€ Hero â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
      className="relative overflow-hidden"
      style={{ background: '#0D0D0D' }}
      aria-label="Falcon View â€” Drive Dubai, delivered to you"
    >
      <div className="relative w-full">
        {/* Background Image & Overlay */}
        <div className="absolute inset-x-0 top-0 h-[90%] lg:h-[85%] z-0 pointer-events-none">
          <img 
            src="/falconviewbackground.png" 
            alt="Luxury Fleet" 
            className="w-full h-full object-cover object-center"
          />
          {/* Left-to-right gradient to protect text readability while leaving cars visible */}
          <div className="absolute inset-0 bg-[#0D0D0D]/40 lg:bg-gradient-to-r lg:from-[#0D0D0D]/90 lg:via-[#0D0D0D]/50 lg:to-transparent" />
          {/* Bottom fade to blend seamlessly into the dark background below */}
          <div className="absolute inset-x-0 bottom-0 h-64 bg-gradient-to-t from-[#0D0D0D] to-transparent" />
        </div>

        {/* Ambient glow */}
        <div className="absolute inset-0 pointer-events-none z-0" aria-hidden>
          <div style={{ background: 'radial-gradient(ellipse at 65% 50%, rgba(255,107,0,0.12) 0%, transparent 60%)' }} className="absolute inset-0" />
          <div style={{ background: 'radial-gradient(ellipse at 20% 85%, rgba(255,107,0,0.06) 0%, transparent 50%)' }} className="absolute inset-0" />
        </div>

        {/* â”€â”€ Top section: Headline + Logo card â”€â”€ */}
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
              Available today Â· Free delivery across Dubai
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
            Sedans, SUVs and 7-seaters on daily, weekly or monthly plans. Pick your car, drop a pin â€” we bring the keys anywhere in Dubai.
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
            <AnimatedStat value={100} suffix="+" label="cars ready now" />
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
      </div>

      {/* â”€â”€ Booking Form Card â€” white, at bottom of dark hero â”€â”€ */}


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
