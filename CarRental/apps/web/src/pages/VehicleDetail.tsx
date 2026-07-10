import React, { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import {
  ArrowLeft, ChevronLeft, ChevronRight, Star, Users, Fuel, Gauge,
  Calendar, MapPin, Shield, Phone, MessageCircle, ChevronDown, CheckCircle2,
  Info, ArrowRight, Zap, Car,
} from 'lucide-react';
import { useQuery } from '@tanstack/react-query';
import { vehicleService } from '../services/api/vehicles';
import { formatAED } from '../lib/formatters';
import { cn } from '../lib/cn';
import { falconLogo } from '../components/layout/Navbar';
import api from '../services/api/axios';
import SEO from '../components/seo/SEO';

// ─── Helpers ──────────────────────────────────────────────────────
const CATEGORY_LABEL: Record<string, string> = {
  sedan: 'Sedan', hatchback: 'Hatchback', suv: 'SUV',
  '7seater': '7 Seater', coupe: 'Coupe / Muscle', ev: 'Electric', roadster: 'Roadster',
};

const CATEGORY_COLOR: Record<string, string> = {
  sedan: 'bg-sky-500/15 text-sky-600 border-sky-200',
  hatchback: 'bg-purple-500/15 text-purple-600 border-purple-200',
  suv: 'bg-emerald-500/15 text-emerald-600 border-emerald-200',
  '7seater': 'bg-amber-500/15 text-amber-600 border-amber-200',
  coupe: 'bg-orange-500/15 text-orange-600 border-orange-200',
};

// ─── FAQ Accordion ────────────────────────────────────────────────
const FAQItem: React.FC<{ question: string; answer: string; index: number }> = ({ question, answer, index }) => {
  const [open, setOpen] = useState(false);
  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.05 }}
      className="border-b border-gray-100 last:border-0"
    >
      <button
        className="w-full flex items-center justify-between py-5 text-left group"
        onClick={() => setOpen(v => !v)}
        aria-expanded={open}
      >
        <span className="font-grotesk font-semibold text-[15px] text-gray-900 pr-4 group-hover:text-orange-500 transition-colors">{question}</span>
        <ChevronDown size={18} className={cn('text-gray-400 shrink-0 transition-transform duration-300', open && 'rotate-180 text-orange-500')} />
      </button>
      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ height: 0, opacity: 0 }} animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }} transition={{ duration: 0.3 }}
            className="overflow-hidden"
          >
            <p className="text-gray-600 text-[14px] leading-relaxed pb-5">{answer}</p>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
};

// ─── Related Vehicle Card ─────────────────────────────────────────
const RelatedCard: React.FC<{ slug: string, fleetData: any[] }> = ({ slug, fleetData }) => {
  const navigate = useNavigate();
  const vehicle = fleetData.find(v => v.slug === slug);
  if (!vehicle) return null;
  return (
    <motion.div
      whileHover={{ y: -4 }}
      className="bg-white rounded-2xl overflow-hidden border border-gray-100 shadow-sm cursor-pointer flex-none w-64"
      onClick={() => navigate(`/vehicles/${slug}`)}
    >
      <img src={vehicle.images.thumbnail} alt={vehicle.name} className="w-full h-36 object-cover" loading="lazy" />
      <div className="p-4">
        <h4 className="font-grotesk font-bold text-[14px] text-gray-900">{vehicle.name}</h4>
        <div className="flex items-center justify-between mt-2">
          <span className="text-orange-500 font-bold text-[15px]">{formatAED(vehicle.pricing.daily)}<span className="text-gray-400 font-normal text-[11px]">/day</span></span>
          <span className="font-mono text-[9px] uppercase tracking-wider text-gray-400 bg-gray-50 px-2 py-1 rounded-full">{CATEGORY_LABEL[vehicle.category] || vehicle.category}</span>
        </div>
      </div>
    </motion.div>
  );
};

// ─── Sticky Booking Card ──────────────────────────────────────────
const StickyBookingCard: React.FC<{ vehicle: any }> = ({ vehicle }) => {
  const msPerDay = 86400000;
  const toDateStr = (ms: number) => new Date(ms).toISOString().split('T')[0];

  const getDurationDays = (d: 'daily' | 'weekly' | 'monthly') =>
    d === 'daily' ? 1 : d === 'weekly' ? 7 : 30;

  const today = toDateStr(Date.now());

  const [duration, setDuration] = useState<'daily' | 'weekly' | 'monthly'>('daily');
  const [startDate, setStartDate] = useState(today);
  const [endDate, setEndDate] = useState(toDateStr(Date.now() + getDurationDays('daily') * msPerDay));
  const [isBooking, setIsBooking] = useState(false);
  const [booked, setBooked] = useState(false);
  const { pricing } = vehicle;

  // Auto-adjust end date whenever duration type changes
  const handleDurationChange = (d: 'daily' | 'weekly' | 'monthly') => {
    setDuration(d);
    setEndDate(toDateStr(new Date(startDate).getTime() + getDurationDays(d) * msPerDay));
    setBooked(false);
  };

  // Auto-adjust end date whenever start date changes (keep same duration span)
  const handleStartDateChange = (newStart: string) => {
    setStartDate(newStart);
    setEndDate(toDateStr(new Date(newStart).getTime() + getDurationDays(duration) * msPerDay));
    setBooked(false);
  };

  // Compute totals
  const diffDays = Math.max(1, Math.ceil((new Date(endDate).getTime() - new Date(startDate).getTime()) / msPerDay));
  const units = duration === 'daily' ? diffDays : duration === 'weekly' ? Math.ceil(diffDays / 7) : Math.ceil(diffDays / 30);
  const ratePerUnit = (duration === 'daily' ? pricing?.daily : duration === 'weekly' ? pricing?.weekly : pricing?.monthly) || 0;
  
  const multiplier = duration === 'monthly' ? units : diffDays;
  const totalPrice = parseFloat((ratePerUnit * multiplier).toFixed(2));
  const unit = duration === 'monthly' ? '/mo' : '/day';

  const handleWhatsAppBook = async () => {
    setIsBooking(true);
    try {
      await api.post('/bookings/', {
        vehicle_id: vehicle.id,
        start_date: new Date(startDate).toISOString(),
        end_date: new Date(endDate).toISOString(),
        total_price: totalPrice,
        duration_type: duration,
      });
      setBooked(true);
    } catch {
      // Still open WhatsApp even if the API call fails
    } finally {
      setIsBooking(false);
      const waMsg = encodeURIComponent(
        `Hi Falcon View! I'd like to book the ${vehicle.name}.\nRental type: ${duration}.\nPickup: ${startDate}  Return: ${endDate}.\nEstimated total: AED ${totalPrice}. Please confirm availability.`
      );
      window.open(`https://wa.me/971500999733?text=${waMsg}`, '_blank', 'noopener,noreferrer');
    }
  };

  return (
    <div className="bg-white border border-gray-100 rounded-2xl shadow-xl p-6 sticky top-24">
      <div className="mb-4">
        <div className="flex items-baseline gap-1">
          <span className="font-grotesk font-bold text-3xl text-gray-900">{formatAED(ratePerUnit)}</span>
          <span className="text-gray-400 text-[13px] font-medium">{unit}</span>
        </div>
        <div className="flex items-center gap-1.5 mt-2 pt-2 border-t border-dashed border-gray-100 text-[12px]">
          <span className="text-gray-500 font-medium">Estimated Total:</span>
          <span className="font-bold text-orange-500">{formatAED(totalPrice)}</span>
          <span className="text-gray-400">for {units} {duration === 'daily' ? (units === 1 ? 'day' : 'days') : duration === 'weekly' ? (units === 1 ? 'week' : 'weeks') : (units === 1 ? 'month' : 'months')}</span>
        </div>
        <p className="text-[10px] text-gray-400 mt-1.5">+5% VAT · Salik AED {pricing?.salikSurcharge || 0}/toll</p>
      </div>

      {/* Duration toggle */}
      <div className="grid grid-cols-3 gap-1 bg-gray-50 p-1 rounded-xl mb-4">
        {(['daily', 'weekly', 'monthly'] as const).map(d => (
          <button
            key={d}
            onClick={() => handleDurationChange(d)}
            className={cn('py-2 rounded-lg font-grotesk font-semibold text-[11px] capitalize transition-all',
              duration === d ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-500 hover:text-gray-700'
            )}
          >
            {d}
          </button>
        ))}
      </div>

      {/* Date Pickers */}
      <div className="grid grid-cols-2 gap-2 mb-4">
        <div>
          <label className="block font-mono text-[9px] uppercase tracking-wider text-gray-400 mb-1">Pickup Date</label>
          <input
            type="date"
            value={startDate}
            min={today}
            onChange={e => handleStartDateChange(e.target.value)}
            className="w-full border border-gray-200 rounded-lg px-3 py-2 text-[13px] font-grotesk text-gray-800 focus:outline-none focus:border-orange-500 transition-colors"
          />
        </div>
        <div>
          <label className="block font-mono text-[9px] uppercase tracking-wider text-gray-400 mb-1">Return Date</label>
          <input
            type="date"
            value={endDate}
            min={startDate}
            onChange={e => { setEndDate(e.target.value); setBooked(false); }}
            className="w-full border border-gray-200 rounded-lg px-3 py-2 text-[13px] font-grotesk text-gray-800 focus:outline-none focus:border-orange-500 transition-colors"
          />
        </div>
      </div>

      {/* KM info */}
      <div className="bg-orange-50 border border-orange-100 rounded-xl p-3 mb-5 text-[12px] text-orange-700">
        <p className="font-semibold mb-0.5">Included kilometres</p>
        <p>Daily: {pricing?.kmsDaily || '—'} km · Weekly: {pricing?.kmsWeekly || '—'} km/day · Monthly: {pricing?.kmsMonthly || '—'} km</p>
        <p className="mt-1 text-orange-600/70">Excess: AED {pricing?.excessPerKm || 0}/km</p>
      </div>

      {/* CTAs */}
      <div className="flex flex-col gap-3">
        {booked && (
          <div className="flex items-center gap-2 bg-green-50 border border-green-100 rounded-xl px-4 py-3 text-[12px] text-green-700 font-grotesk">
            <CheckCircle2 size={14} className="text-green-500 shrink-0" />
            Booking recorded! Opening WhatsApp to confirm…
          </div>
        )}
        <button
          onClick={handleWhatsAppBook}
          disabled={isBooking}
          className="flex items-center justify-center gap-2 bg-green-500 hover:bg-green-600 disabled:opacity-60 text-white font-grotesk font-bold text-[14px] py-4 rounded-xl transition-colors shadow-lg shadow-green-500/20"
          aria-label="Book via WhatsApp"
        >
          {isBooking ? (
            <svg className="animate-spin w-4 h-4" viewBox="0 0 24 24" fill="none">
              <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
              <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.4 0 0 5.4 0 12h4z" />
            </svg>
          ) : (
            <MessageCircle size={16} />
          )}
          {isBooking ? 'Saving booking…' : 'Book via WhatsApp'}
        </button>
        <a
          href="tel:+971500999733"
          className="flex items-center justify-center gap-2 bg-gray-900 hover:bg-gray-800 text-white font-grotesk font-semibold text-[14px] py-3.5 rounded-xl transition-colors"
          aria-label="Call to book"
        >
          <Phone size={15} /> Call +971 50 099 9733
        </a>
      </div>

      {/* Trust signals */}
      <div className="mt-4 pt-4 border-t border-gray-100 space-y-2">
        {['Free delivery across Dubai', 'Comprehensive insurance included', 'No hidden fees or charges'].map(t => (
          <div key={t} className="flex items-center gap-2 text-[12px] text-gray-500">
            <CheckCircle2 size={13} className="text-green-500 shrink-0" />
            {t}
          </div>
        ))}
      </div>

      {/* Min age */}
      <div className="mt-3 flex items-center gap-2 text-[11px] text-gray-400">
        <Info size={11} className="shrink-0" />
        Min. driver age: {vehicle.minDriverAge} years · {(vehicle.licenceRequired || []).join(', ')} licence
      </div>
    </div>
  );
};


// ─── Vehicle Detail Page ──────────────────────────────────────────
const VehicleDetailPage: React.FC = () => {
  const { slug } = useParams<{ slug: string }>();
  const navigate = useNavigate();
  const [imgIdx, setImgIdx] = useState(0);
  const galleryRef = useRef<HTMLDivElement>(null);

  useEffect(() => { window.scrollTo(0, 0); }, [slug]);

  const { data: fleetData = [], isLoading } = useQuery({
    queryKey: ['vehicles', 'all'],
    queryFn: () => vehicleService.getVehicles(),
  });

  const vehicle = fleetData.find((v: any) => v.slug === slug);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-[#F7F7F5] flex flex-col items-center justify-center gap-6">
        <div className="w-12 h-12 rounded-full border-2 border-orange-500/30 border-t-orange-500 animate-spin" />
      </div>
    );
  }

  if (!vehicle) {
    return (
      <div className="min-h-screen bg-[#F7F7F5] flex flex-col items-center justify-center gap-6">
        <img src={falconLogo} alt="Falcon View" className="h-16 w-auto opacity-40" />
        <h1 className="font-grotesk font-bold text-2xl text-gray-400">Vehicle not found</h1>
        <button onClick={() => navigate('/fleet')} className="bg-orange-500 text-white px-6 py-3 rounded-full font-grotesk font-semibold">
          Browse All Vehicles
        </button>
      </div>
    );
  }

  const images = (vehicle.images?.exterior?.length || 0) > 1
    ? vehicle.images.exterior
    : [vehicle.images?.thumbnail || ''];

  const waMsg = encodeURIComponent(
    `Hi Falcon View! I'd like to get a quote for the ${vehicle.name}. Please send pricing and availability.`
  );

  const specRows = [
    { label: 'Engine', value: vehicle.specs?.engine },
    { label: 'Power', value: vehicle.specs?.power },
    { label: 'Torque', value: vehicle.specs?.torque },
    { label: 'Transmission', value: vehicle.specs?.transmission ? (vehicle.specs.transmission === 'auto' ? 'Automatic' : 'Manual') : undefined },
    { label: 'Fuel Type', value: vehicle.specs?.fuel ? (vehicle.specs.fuel.charAt(0).toUpperCase() + vehicle.specs.fuel.slice(1)) : undefined },
    { label: 'Seats', value: vehicle.specs?.seats ? `${vehicle.specs.seats} passengers` : undefined },
    { label: 'Doors', value: vehicle.specs?.doors ? `${vehicle.specs.doors} doors` : undefined },
    { label: 'Boot Space', value: vehicle.specs?.luggage ? `${vehicle.specs.luggage} litres` : undefined },
    { label: 'Year', value: vehicle.specs?.year?.toString() },
    { label: '0-100 km/h', value: vehicle.specs?.zeroToSixty },
    { label: 'Top Speed', value: vehicle.specs?.topSpeed },
  ].filter(r => r.value) as { label: string; value: string }[];

  const vehicleJsonLd = [
    {
      "@context": "https://schema.org",
      "@type": "Car",
      "name": vehicle.name,
      "description": vehicle.description || vehicle.tagline,
      "brand": {
        "@type": "Brand",
        "name": vehicle.brand
      },
      "model": vehicle.model,
      "vehicleConfiguration": vehicle.category,
      "vehicleSeatingCapacity": vehicle.specs?.seats,
      "vehicleTransmission": vehicle.specs?.transmission,
      "fuelType": vehicle.specs?.fuel,
      "image": vehicle.images?.exterior?.[0] || vehicle.images?.thumbnail,
      "offers": {
        "@type": "Offer",
        "price": vehicle.pricing?.daily,
        "priceCurrency": "AED",
        "availability": "https://schema.org/InStock"
      }
    },
    {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": [
        {
          "@type": "ListItem",
          "position": 1,
          "name": "Home",
          "item": "https://falconviewcarrentals.com"
        },
        {
          "@type": "ListItem",
          "position": 2,
          "name": "Fleet",
          "item": "https://falconviewcarrentals.com/fleet"
        },
        {
          "@type": "ListItem",
          "position": 3,
          "name": vehicle.name,
          "item": `https://falconviewcarrentals.com/vehicles/${vehicle.slug}`
        }
      ]
    }
  ];

  return (
    <>
      <SEO 
        title={`${vehicle.name} Rental Dubai | Falcon View`}
        description={vehicle.tagline || vehicle.description?.substring(0, 150)}
        canonicalUrl={`/vehicles/${vehicle.slug}`}
        ogImage={images[0]}
        jsonLd={vehicleJsonLd}
      />
      <div className="min-h-screen bg-[#F7F7F5]">
        {/* ── Sticky Nav ── */}
      <header className="sticky top-0 z-50 bg-white/95 backdrop-blur-xl border-b border-gray-100 shadow-sm">
        <div className="max-w-[1400px] mx-auto px-4 sm:px-6 lg:px-8 py-3 flex items-center gap-4">
          <button onClick={() => navigate(-1)} className="flex items-center gap-2 text-gray-500 hover:text-gray-900 transition-colors shrink-0" aria-label="Go back">
            <ArrowLeft size={18} />
            <img src={falconLogo} alt="Falcon View" className="h-8 w-auto object-contain" />
          </button>
          <div className="hidden sm:block w-px h-6 bg-gray-200" />
          <nav className="hidden sm:flex items-center gap-1 text-[12px] text-gray-400 font-mono">
            <Link to="/" className="hover:text-orange-500 transition-colors">Home</Link>
            <span className="mx-1">/</span>
            <Link to="/fleet" className="hover:text-orange-500 transition-colors">Fleet</Link>
            <span className="mx-1">/</span>
            <span className="text-gray-700 max-w-[200px] truncate">{vehicle.name}</span>
          </nav>
          <div className="flex-1" />
          <a
            href={`https://wa.me/971500999733?text=${waMsg}`}
            target="_blank" rel="noopener noreferrer"
            className="hidden sm:flex items-center gap-2 bg-green-500 hover:bg-green-600 text-white font-grotesk font-semibold text-[13px] px-5 py-2.5 rounded-full transition-colors shadow-sm"
          >
            <MessageCircle size={14} /> Get Quote
          </a>
        </div>
      </header>

      <div className="max-w-[1400px] mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* ── LEFT COLUMN (images + details) ── */}
          <div className="lg:col-span-2 flex flex-col gap-8">
            {/* Hero gallery */}
            <div ref={galleryRef} className="bg-white rounded-2xl overflow-hidden border border-gray-100 shadow-sm">
              <div className="relative aspect-[16/9] bg-gray-50">
                <motion.img
                  key={imgIdx}
                  src={images[imgIdx]}
                  alt={`${vehicle.name} — view ${imgIdx + 1}`}
                  className="w-full h-full object-cover"
                  initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ duration: 0.4 }}
                />
                {/* Badges */}
                <div className="absolute top-4 left-4 flex flex-wrap gap-2">
                  {vehicle.badge && (
                    <span className="bg-orange-500 text-white font-mono text-[10px] uppercase tracking-[0.15em] px-3 py-1.5 rounded-full shadow-lg">{vehicle.badge}</span>
                  )}
                  <span className={cn('font-mono text-[10px] uppercase tracking-[0.1em] px-3 py-1.5 rounded-full border', CATEGORY_COLOR[vehicle.category] || 'bg-gray-100 text-gray-600 border-gray-200')}>
                    {CATEGORY_LABEL[vehicle.category] || vehicle.category}
                  </span>
                </div>

                {/* Gallery nav */}
                {images.length > 1 && (
                  <>
                    <button
                      onClick={() => setImgIdx(i => (i === 0 ? images.length - 1 : i - 1))}
                      className="absolute left-3 top-1/2 -translate-y-1/2 w-10 h-10 rounded-full bg-black/40 backdrop-blur text-white flex items-center justify-center hover:bg-black/60 transition-colors"
                      aria-label="Previous image"
                    >
                      <ChevronLeft size={18} />
                    </button>
                    <button
                      onClick={() => setImgIdx(i => (i === images.length - 1 ? 0 : i + 1))}
                      className="absolute right-3 top-1/2 -translate-y-1/2 w-10 h-10 rounded-full bg-black/40 backdrop-blur text-white flex items-center justify-center hover:bg-black/60 transition-colors"
                      aria-label="Next image"
                    >
                      <ChevronRight size={18} />
                    </button>
                    <div className="absolute bottom-3 left-1/2 -translate-x-1/2 flex gap-1.5">
                      {images.map((_, i) => (
                        <button
                          key={i}
                          onClick={() => setImgIdx(i)}
                          className={cn('w-1.5 h-1.5 rounded-full transition-all', imgIdx === i ? 'w-4 bg-white' : 'bg-white/50')}
                          aria-label={`View image ${i + 1}`}
                        />
                      ))}
                    </div>
                  </>
                )}
              </div>
              {/* Thumbnails */}
              {images.length > 1 && (
                <div className="flex gap-2 p-3 overflow-x-auto">
                  {images.map((img, i) => (
                    <button key={i} onClick={() => setImgIdx(i)}
                      className={cn('flex-none w-16 h-12 rounded-lg overflow-hidden border-2 transition-all', imgIdx === i ? 'border-orange-500' : 'border-transparent opacity-60 hover:opacity-100')}>
                      <img src={img} alt="" className="w-full h-full object-cover" />
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* Title & Rating */}
            <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
              <h1 className="font-grotesk font-extrabold text-3xl sm:text-4xl text-gray-900 leading-tight">{vehicle.name}</h1>
              <p className="text-gray-500 text-[16px] mt-2">{vehicle.tagline}</p>
              <div className="flex flex-wrap items-center gap-4 mt-4">
                <div className="flex items-center gap-1.5">
                  {[...Array(5)].map((_, i) => (
                    <Star key={i} size={14} className={i < Math.floor(vehicle.rating) ? 'text-orange-400 fill-orange-400' : 'text-gray-200 fill-gray-200'} />
                  ))}
                  <span className="font-grotesk font-bold text-[14px] text-gray-900 ml-1">{vehicle.rating}</span>
                  <span className="text-gray-400 text-[13px]">({vehicle.reviewCount} verified rentals)</span>
                </div>
                {vehicle.deliveryAvailable && (
                  <span className="flex items-center gap-1.5 text-[13px] text-emerald-600 font-medium">
                    <MapPin size={13} /> Free delivery across Dubai
                  </span>
                )}
              </div>
              <p className="text-gray-600 text-[15px] leading-relaxed mt-5">{vehicle.description}</p>
            </div>

            {/* Pricing Table */}
            <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
              <h2 className="font-grotesk font-bold text-xl text-gray-900 mb-5">Rental Pricing</h2>
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-5">
                {[
                  { label: 'Daily Rate', sublabel: '1–6 days', price: vehicle.pricing.daily, unit: '/day', color: 'border-blue-200 bg-blue-50' },
                  { label: 'Weekly Rate', sublabel: '7–29 days', price: vehicle.pricing.weekly, unit: '/day', color: 'border-orange-200 bg-orange-50', highlight: true },
                  { label: 'Monthly Rate', sublabel: '30+ days', price: vehicle.pricing.monthly, unit: '/month', color: 'border-emerald-200 bg-emerald-50' },
                ].map(tier => (
                  <div key={tier.label} className={cn('border rounded-xl p-4 relative', tier.color)}>
                    {tier.highlight && (
                      <span className="absolute -top-2.5 left-4 bg-orange-500 text-white font-mono text-[9px] uppercase tracking-wider px-2.5 py-0.5 rounded-full">Best Value</span>
                    )}
                    <p className="font-mono text-[10px] uppercase tracking-[0.12em] text-gray-500 mb-1">{tier.label}</p>
                    <p className="font-grotesk font-bold text-2xl text-gray-900">{formatAED(tier.price)}<span className="text-gray-400 font-normal text-[13px]">{tier.unit}</span></p>
                    <p className="text-[11px] text-gray-500 mt-1">{tier.sublabel}</p>
                  </div>
                ))}
              </div>

              {/* Extras table */}
              <div className="border border-gray-100 rounded-xl overflow-hidden">
                {[
                  { label: 'Excess per km', value: `AED ${vehicle.pricing.excessPerKm}` },
                  { label: 'Km included (Daily)', value: `${vehicle.pricing.kmsDaily} km` },
                  { label: 'Km included (Weekly)', value: `${vehicle.pricing.kmsWeekly} km/day` },
                  { label: 'Km included (Monthly)', value: `${vehicle.pricing.kmsMonthly} km` },
                  { label: 'Salik toll surcharge', value: `AED ${vehicle.pricing.salikSurcharge} per toll` },
                  { label: 'VAT', value: `${vehicle.pricing.vatRate}%` },
                  { label: 'Security deposit', value: vehicle.pricing.deposit ? formatAED(vehicle.pricing.deposit) + ' (refundable)' : 'Contact us' },
                ].map((row, i) => (
                  <div key={row.label} className={cn('flex items-center justify-between px-4 py-3 text-[13px]', i % 2 === 0 ? 'bg-white' : 'bg-gray-50')}>
                    <span className="text-gray-500">{row.label}</span>
                    <span className="font-grotesk font-semibold text-gray-900">{row.value}</span>
                  </div>
                ))}
              </div>
              <p className="text-[11px] text-gray-400 mt-3 flex items-center gap-1">
                <Info size={11} /> All prices are exclusive of VAT. Salik charges apply where applicable.
              </p>
            </div>

            {/* Specifications */}
            <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
              <h2 className="font-grotesk font-bold text-xl text-gray-900 mb-5">Specifications</h2>
              <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
                {specRows.map((spec, i) => (
                  <div key={spec.label} className={cn('rounded-xl p-4', i % 2 === 0 ? 'bg-gray-50' : 'bg-white border border-gray-100')}>
                    <p className="font-mono text-[10px] uppercase tracking-[0.12em] text-gray-400 mb-1.5">{spec.label}</p>
                    <p className="font-grotesk font-semibold text-[14px] text-gray-900">{spec.value}</p>
                  </div>
                ))}
              </div>
            </div>

            {/* Features */}
            <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
              <h2 className="font-grotesk font-bold text-xl text-gray-900 mb-5">Key Features</h2>
              <div className="flex flex-wrap gap-2">
                {vehicle.features.map(f => (
                  <span key={f} className="flex items-center gap-1.5 bg-gray-50 border border-gray-100 text-gray-700 text-[13px] font-medium px-3.5 py-2 rounded-xl">
                    <CheckCircle2 size={13} className="text-orange-500" /> {f}
                  </span>
                ))}
              </div>
            </div>

            {/* What's included */}
            <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
              <h2 className="font-grotesk font-bold text-xl text-gray-900 mb-5">
                <span className="flex items-center gap-2"><Shield size={20} className="text-orange-500" /> Included in Every Rental</span>
              </h2>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                {vehicle.rentalIncludes.map(item => (
                  <div key={item} className="flex items-center gap-3 py-2.5 border-b border-gray-50 last:border-0">
                    <CheckCircle2 size={16} className="text-green-500 shrink-0" />
                    <span className="text-[14px] text-gray-700">{item}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* FAQs */}
            {vehicle.faqs && vehicle.faqs.length > 0 && (
              <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
                <h2 className="font-grotesk font-bold text-xl text-gray-900 mb-2">Frequently Asked Questions</h2>
                {vehicle.faqs.map((faq, i) => (
                  <FAQItem key={i} question={faq.question} answer={faq.answer} index={i} />
                ))}
              </div>
            )}

            {/* Related Vehicles */}
            {vehicle.relatedVehicles && vehicle.relatedVehicles.length > 0 && (
              <div>
                <div className="flex items-center justify-between mb-4">
                  <h2 className="font-grotesk font-bold text-xl text-gray-900">You May Also Like</h2>
                  <Link to="/fleet" className="text-orange-500 hover:text-orange-600 text-[13px] font-medium flex items-center gap-1 transition-colors">
                    View all <ArrowRight size={13} />
                  </Link>
                </div>
                <div className="flex gap-4 overflow-x-auto pb-2">
                  {vehicle.relatedVehicles.map((s: string) => (
                    <RelatedCard key={s} slug={s} fleetData={fleetData} />
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* ── RIGHT COLUMN: Sticky booking card ── */}
          <div className="hidden lg:block">
            <StickyBookingCard vehicle={vehicle} />
          </div>
        </div>

        {/* Mobile booking bar */}
        <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 p-4 flex gap-3 lg:hidden z-40 shadow-2xl">
          <div className="flex-1">
            <p className="font-mono text-[10px] text-gray-400 uppercase tracking-wider">From</p>
            <p className="font-grotesk font-bold text-[18px] text-gray-900">{formatAED(vehicle.pricing.daily)}<span className="text-gray-400 font-normal text-[11px]">/day</span></p>
          </div>
          <a
            href={`https://wa.me/971500999733?text=${waMsg}`}
            target="_blank" rel="noopener noreferrer"
            className="flex items-center gap-2 bg-green-500 text-white font-grotesk font-bold text-[14px] px-5 py-3 rounded-xl shadow-lg shadow-green-500/20"
          >
            <MessageCircle size={15} /> Book Now
          </a>
          <a
            href="tel:+971500999733"
            className="flex items-center gap-2 bg-gray-900 text-white font-grotesk font-semibold text-[14px] px-4 py-3 rounded-xl"
            aria-label="Call us"
          >
            <Phone size={15} />
          </a>
        </div>
      </div>
    </div>
    </>
  );
};

export default VehicleDetailPage;
