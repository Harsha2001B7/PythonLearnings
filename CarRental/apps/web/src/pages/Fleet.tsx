import React, { useState, useMemo, useEffect } from 'react';
import { useNavigate, useSearchParams, Link } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Search, SlidersHorizontal, X, Heart, ChevronDown, RotateCcw,
  MapPin, Users, Fuel, Gauge, Star, ArrowLeft, MessageCircle,
} from 'lucide-react';
import { useQuery } from '@tanstack/react-query';
import { vehicleService } from '../services/api/vehicles';
import { formatAED } from '../lib/formatters';
import { cn } from '../lib/cn';
import { useAppStore, useToastStore } from '../store';
import { falconLogo } from '../components/layout/Navbar';
import SEO from '../components/seo/SEO';

// ─── Types ────────────────────────────────────────────────────────
type Category = 'all' | 'sedan' | 'hatchback' | 'suv' | '7seater' | 'coupe';
type SortKey = 'featured' | 'price_asc' | 'price_desc' | 'rating';

const CATEGORIES: { key: Category; label: string }[] = [
  { key: 'all', label: 'All Vehicles' },
  { key: 'sedan', label: 'Sedan' },
  { key: 'hatchback', label: 'Hatchback' },
  { key: 'suv', label: 'SUV' },
  { key: '7seater', label: '7 Seater' },
  { key: 'coupe', label: 'Coupe / Muscle' },
];

const SORT_OPTIONS: { key: SortKey; label: string }[] = [
  { key: 'featured', label: 'Featured First' },
  { key: 'price_asc', label: 'Price: Low to High' },
  { key: 'price_desc', label: 'Price: High to Low' },
  { key: 'rating', label: 'Top Rated' },
];

const CATEGORY_BADGE_COLORS: Record<string, string> = {
  coupe:     'bg-orange-500/15 text-orange-400 border-orange-500/30',
  sedan:     'bg-sky-500/15 text-sky-400 border-sky-500/30',
  suv:       'bg-emerald-500/15 text-emerald-400 border-emerald-500/30',
  hatchback: 'bg-purple-500/15 text-purple-400 border-purple-500/30',
  '7seater': 'bg-amber-500/15 text-amber-400 border-amber-500/30',
};

// ─── Vehicle Card ─────────────────────────────────────────────────
const VehicleCard: React.FC<{
  vehicle: any;
  index: number;
}> = ({ vehicle, index }) => {
  const navigate = useNavigate();
  const { wishlist, toggleWishlist } = useAppStore();
  const { addToast } = useToastStore();
  const isWishlisted = wishlist.includes(vehicle.id);

  const handleWishlist = (e: React.MouseEvent) => {
    e.stopPropagation();
    toggleWishlist(vehicle.id);
    addToast(isWishlisted ? `Removed ${vehicle.name} from wishlist` : `Added ${vehicle.name} to wishlist`);
  };

  const whatsappMsg = encodeURIComponent(
    `Hi Falcon View! I'm interested in the ${vehicle.name} (AED ${vehicle.pricePerDay}/day). Please send availability and pricing.`
  );

  return (
    <motion.article
      layout
      initial={{ opacity: 0, y: 24 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, scale: 0.95 }}
      transition={{ duration: 0.4, delay: Math.min(index * 0.05, 0.3) }}
      className="group bg-white rounded-2xl overflow-hidden border border-gray-100 shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all duration-300 cursor-pointer flex flex-col"
      onClick={() => navigate(`/vehicles/${vehicle.slug}`)}
      role="article"
      aria-label={`${vehicle.name} — AED ${vehicle.pricing.daily} per day`}
    >
      {/* Image */}
      <div className="relative h-48 overflow-hidden bg-gray-50">
        <img
          src={vehicle.images.thumbnail}
          alt={vehicle.name}
          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
          loading="lazy"
        />
        {/* Badges */}
        <div className="absolute top-3 left-3 flex flex-col gap-1.5">
          {vehicle.badge && (
            <span className="bg-orange-500 text-white font-mono text-[9px] uppercase tracking-[0.15em] px-2.5 py-1 rounded-full shadow-lg">
              {vehicle.badge}
            </span>
          )}
          {vehicle.isNewArrival && !vehicle.badge && (
            <span className="bg-emerald-500 text-white font-mono text-[9px] uppercase tracking-[0.15em] px-2.5 py-1 rounded-full">
              New
            </span>
          )}
        </div>
        {/* Wishlist */}
        <button
          onClick={handleWishlist}
          className={cn(
            'absolute top-3 right-3 w-9 h-9 rounded-full bg-white/90 backdrop-blur-sm shadow flex items-center justify-center transition-all',
            isWishlisted ? 'text-red-500' : 'text-gray-400 hover:text-gray-700'
          )}
          aria-label={isWishlisted ? `Remove ${vehicle.name} from wishlist` : `Add ${vehicle.name} to wishlist`}
        >
          <Heart size={14} fill={isWishlisted ? 'currentColor' : 'none'} />
        </button>
        {/* Availability dot */}
        <div className="absolute bottom-3 left-3 flex items-center gap-1.5 bg-black/50 backdrop-blur-sm px-2 py-1 rounded-full">
          <span className="w-1.5 h-1.5 rounded-full bg-green-400 animate-pulse" />
          <span className="text-white font-mono text-[9px] uppercase tracking-wider">Available</span>
        </div>
      </div>

      {/* Content */}
      <div className="p-5 flex flex-col gap-3 flex-1">
        <div className="flex items-start justify-between gap-2">
          <div>
            <span className={cn('font-mono text-[9px] uppercase tracking-[0.12em] px-2 py-0.5 rounded-full border', CATEGORY_BADGE_COLORS[vehicle.category] || 'bg-gray-100 text-gray-600 border-gray-200')}>
              {vehicle.category === '7seater' ? '7 Seater' : vehicle.category}
            </span>
            <h3 className="font-grotesk font-bold text-[16px] text-gray-900 mt-2 leading-tight">{vehicle.name}</h3>
            <p className="text-gray-500 text-[12px] mt-0.5 line-clamp-1">{vehicle.tagline}</p>
          </div>
        </div>

        {/* Quick specs */}
        <div className="flex flex-wrap gap-2">
          <span className="inline-flex items-center gap-1 text-[11px] text-gray-500 bg-gray-50 border border-gray-100 rounded-md px-2 py-1">
            <Users size={10} /> {vehicle.specs.seats} seats
          </span>
          <span className="inline-flex items-center gap-1 text-[11px] text-gray-500 bg-gray-50 border border-gray-100 rounded-md px-2 py-1">
            <Fuel size={10} /> {vehicle.specs.fuel}
          </span>
          {vehicle.specs.power && (
            <span className="inline-flex items-center gap-1 text-[11px] text-gray-500 bg-gray-50 border border-gray-100 rounded-md px-2 py-1">
              <Gauge size={10} /> {vehicle.specs.power}
            </span>
          )}
        </div>

        {/* Rating */}
        <div className="flex items-center gap-1.5">
          <div className="flex items-center gap-0.5">
            {[...Array(5)].map((_, i) => (
              <Star key={i} size={10} className={i < Math.floor(vehicle.rating) ? 'text-orange-400 fill-orange-400' : 'text-gray-200 fill-gray-200'} />
            ))}
          </div>
          <span className="text-[11px] text-gray-500">{vehicle.rating} ({vehicle.reviewCount} reviews)</span>
        </div>

        {/* Price + CTA */}
        <div className="flex items-end justify-between gap-3 pt-3 border-t border-gray-100 mt-auto">
          <div>
            <div className="flex items-baseline gap-1">
              <span className="font-grotesk font-bold text-2xl text-gray-900">{formatAED(vehicle.pricePerDay)}</span>
              <span className="text-gray-400 text-[12px]">/day</span>
            </div>
            <p className="text-[11px] text-gray-400">{formatAED(vehicle.pricePerDay * 30)}/mo · {formatAED(vehicle.pricePerWeek)}/week (weekly)</p>
          </div>
          <a
            href={`https://wa.me/971500999733?text=${whatsappMsg}`}
            target="_blank"
            rel="noopener noreferrer"
            onClick={(e) => e.stopPropagation()}
            className="flex items-center gap-1.5 bg-green-500 hover:bg-green-600 text-white font-grotesk font-semibold text-[12px] px-4 py-2.5 rounded-xl transition-colors whitespace-nowrap shadow-sm"
            aria-label={`Enquire about ${vehicle.name} via WhatsApp`}
          >
            <MessageCircle size={13} />
            Enquire
          </a>
        </div>

        {/* Delivery badge */}
        {vehicle.deliveryAvailable && (
          <div className="flex items-center gap-1.5 text-[11px] text-emerald-600">
            <MapPin size={10} />
            <span>Free delivery across Dubai</span>
          </div>
        )}
      </div>
    </motion.article>
  );
};

// ─── Fleet Page ───────────────────────────────────────────────────
const FleetPage: React.FC = () => {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();

  // Initialize state from URL params
  const [search, setSearch] = useState(searchParams.get('search') || '');
  const [category, setCategory] = useState<Category>((searchParams.get('category') as Category) || 'all');
  const [maxPrice, setMaxPrice] = useState(() => {
    const p = searchParams.get('maxPrice');
    return p ? parseInt(p) : 600;
  });
  const [seats, setSeats] = useState(searchParams.get('seats') || 'all');
  const [sortBy, setSortBy] = useState<SortKey>((searchParams.get('sort') as SortKey) || 'featured');
  const [deliveryOnly, setDeliveryOnly] = useState(searchParams.get('delivery') === 'true');
  const [filtersOpen, setFiltersOpen] = useState(false);
  const [sortOpen, setSortOpen] = useState(false);

  // Sync URL params on mount
  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  const { data: fleetData = [], isLoading } = useQuery({
    queryKey: ['vehicles', 'all'],
    queryFn: () => vehicleService.getVehicles(),
  });

  const filteredVehicles = useMemo(() => {
    let results = fleetData.filter((v: any) => {
      if (!v.available) return false;
      const searchLower = search.toLowerCase();
      const matchSearch = !search ||
        v.name.toLowerCase().includes(searchLower) ||
        v.brand.toLowerCase().includes(searchLower) ||
        v.model.toLowerCase().includes(searchLower) ||
        v.category.toLowerCase().includes(searchLower) ||
        (v.tagline && v.tagline.toLowerCase().includes(searchLower)) ||
        (v.keywords && v.keywords.some((k: string) => k.toLowerCase().includes(searchLower)));
      const matchCategory = category === 'all' || v.category === category;
      const matchPrice = v.pricePerDay <= maxPrice;
      const matchSeats = seats === 'all' || (seats === '7+' ? v.specs.seats >= 7 : v.specs.seats === parseInt(seats));
      const matchDelivery = !deliveryOnly || v.deliveryAvailable;
      return matchSearch && matchCategory && matchPrice && matchSeats && matchDelivery;
    });

    // Sort
    switch (sortBy) {
      case 'price_asc': results.sort((a: any, b: any) => a.pricePerDay - b.pricePerDay); break;
      case 'price_desc': results.sort((a: any, b: any) => b.pricePerDay - a.pricePerDay); break;
      case 'rating': results.sort((a: any, b: any) => b.rating - a.rating); break;
      default: results.sort((a: any, b: any) => (b.featured ? 1 : 0) - (a.featured ? 1 : 0)); break;
    }
    return results;
  }, [search, category, maxPrice, seats, deliveryOnly, sortBy]);

  const filterProps = {
    search, setSearch, category, setCategory,
    maxPrice, setMaxPrice, seats, setSeats,
    deliveryOnly, setDeliveryOnly, sortBy, setSortBy,
    totalResults: filteredVehicles.length,
    maxPossiblePrice: Math.max(...(fleetData.length ? fleetData.map((v: any) => v.pricePerDay) : [3000]))
  };

  const resetFilters = () => {
    setSearch(''); setCategory('all'); setMaxPrice(600); setSeats('all');
    setDeliveryOnly(false); setSortBy('featured');
  };

  const hasActiveFilters = search || category !== 'all' || maxPrice < 600 || seats !== 'all' || deliveryOnly;

  const fleetJsonLd = {
    "@context": "https://schema.org",
    "@type": "ItemList",
    "itemListElement": fleetData.slice(0, 10).map((v: any, index: number) => ({
      "@type": "ListItem",
      "position": index + 1,
      "item": {
        "@type": "CarRental",
        "name": v.name,
        "url": `https://falconviewcarrentals.com/vehicles/${v.slug}`,
        "image": v.images.thumbnail
      }
    }))
  };

  return (
    <>
      <SEO 
        title="Our Luxury Fleet | Falcon View Car Rentals Dubai"
        description="Browse our curated fleet of luxury sedans, SUVs, and 7-seaters. Filter by price, category, and features. Free delivery anywhere in the UAE."
        canonicalUrl="/fleet"
        jsonLd={fleetJsonLd}
      />
      <div className="min-h-screen bg-[#F7F7F5]">
        {/* ── Sticky Header ── */}
      <header className="sticky top-0 z-50 bg-white/95 backdrop-blur-xl border-b border-gray-100 shadow-sm">
        <div className="max-w-[1400px] mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center gap-4">
            <button
              onClick={() => navigate('/')}
              className="flex items-center gap-2 text-gray-500 hover:text-gray-900 transition-colors shrink-0"
              aria-label="Back to home"
            >
              <ArrowLeft size={18} />
              <img src={falconLogo} alt="Falcon View" className="h-8 w-auto object-contain" />
            </button>
            <div className="hidden sm:block w-px h-6 bg-gray-200" />
            <div className="hidden sm:block">
              <nav className="flex items-center gap-1 text-[12px] text-gray-400 font-mono">
                <Link to="/" className="hover:text-orange-500 transition-colors">Home</Link>
                <span className="mx-1">/</span>
                <span className="text-gray-700">Fleet</span>
              </nav>
              <h1 className="font-grotesk font-bold text-[18px] text-gray-900 leading-tight">Browse All Vehicles</h1>
            </div>
            <div className="flex-1" />
            {/* Search */}
            <div className="relative max-w-xs w-full">
              <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
              <input
                type="search"
                placeholder="Search vehicles..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-full pl-9 pr-4 py-2.5 bg-gray-50 border border-gray-200 rounded-xl text-[13px] placeholder:text-gray-400 focus:outline-none focus:border-orange-400 focus:bg-white transition-all"
                aria-label="Search vehicles"
                style={{ colorScheme: 'light', color: '#111827', caretColor: '#FF6B00' }}
              />
              {search && (
                <button onClick={() => setSearch('')} className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-700">
                  <X size={12} />
                </button>
              )}
            </div>
            {/* Sort */}
            <div className="relative hidden sm:block">
              <button
                onClick={() => setSortOpen(v => !v)}
                className="flex items-center gap-2 bg-gray-50 border border-gray-200 rounded-xl px-4 py-2.5 text-[13px] text-gray-700 hover:border-gray-300 transition-all"
              >
                {SORT_OPTIONS.find(s => s.key === sortBy)?.label}
                <ChevronDown size={13} className={cn('transition-transform', sortOpen && 'rotate-180')} />
              </button>
              <AnimatePresence>
                {sortOpen && (
                  <motion.div
                    initial={{ opacity: 0, y: -8 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }}
                    className="absolute right-0 top-full mt-2 bg-white border border-gray-100 rounded-xl shadow-xl z-50 overflow-hidden min-w-[180px]"
                  >
                    {SORT_OPTIONS.map(opt => (
                      <button
                        key={opt.key}
                        onClick={() => { setSortBy(opt.key); setSortOpen(false); }}
                        className={cn('w-full text-left px-4 py-3 text-[13px] hover:bg-gray-50 transition-colors', sortBy === opt.key ? 'text-orange-500 font-semibold' : 'text-gray-700')}
                      >
                        {opt.label}
                      </button>
                    ))}
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
            {/* Filter toggle mobile */}
            <button
              onClick={() => setFiltersOpen(v => !v)}
              className={cn('flex items-center gap-2 border rounded-xl px-4 py-2.5 text-[13px] font-medium transition-all', hasActiveFilters ? 'bg-orange-500 border-orange-500 text-white' : 'bg-white border-gray-200 text-gray-700 hover:border-gray-300')}
              aria-expanded={filtersOpen}
            >
              <SlidersHorizontal size={14} />
              <span className="hidden sm:inline">Filters</span>
              {hasActiveFilters && <span className="bg-white text-orange-500 rounded-full w-4 h-4 text-[10px] font-bold flex items-center justify-center">{[search ? 1 : 0, category !== 'all' ? 1 : 0, maxPrice < 600 ? 1 : 0, seats !== 'all' ? 1 : 0, deliveryOnly ? 1 : 0].reduce((a, b) => a + b, 0)}</span>}
            </button>
          </div>
        </div>
      </header>

      <div className="max-w-[1400px] mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Category tabs */}
        <div className="flex flex-wrap gap-2 mb-6">
          {CATEGORIES.map(cat => (
            <button
              key={cat.key}
              onClick={() => setCategory(cat.key)}
              className={cn(
                'px-4 py-2 rounded-full font-grotesk font-semibold text-[13px] border transition-all duration-200',
                category === cat.key
                  ? 'bg-gray-900 text-white border-gray-900 shadow-md'
                  : 'bg-white text-gray-600 border-gray-200 hover:border-gray-400 hover:text-gray-900'
              )}
              aria-pressed={category === cat.key}
            >
              {cat.label}
            </button>
          ))}
        </div>

        {/* Expanded Filters Panel */}
        <AnimatePresence>
          {filtersOpen && (
            <motion.div
              initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} exit={{ opacity: 0, height: 0 }}
              className="overflow-hidden mb-6"
            >
              <div className="bg-white border border-gray-100 rounded-2xl p-6 shadow-sm">
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                  {/* Max Price */}
                  <div className="flex flex-col gap-2">
                    <div className="flex justify-between items-center">
                      <label className="font-mono text-[10px] uppercase tracking-[0.15em] text-gray-400">Max Price / Day</label>
                      <span className="font-grotesk font-bold text-[13px] text-orange-500">{formatAED(maxPrice)}</span>
                    </div>
                    <input
                      type="range" min={65} max={600} step={5}
                      value={maxPrice}
                      onChange={(e) => setMaxPrice(parseInt(e.target.value))}
                      className="w-full accent-orange-500"
                      aria-label="Maximum price per day"
                    />
                    <div className="flex justify-between text-[10px] text-gray-400 font-mono">
                      <span>AED 65</span><span>AED 600</span>
                    </div>
                  </div>

                  {/* Seats */}
                  <div className="flex flex-col gap-2">
                    <label className="font-mono text-[10px] uppercase tracking-[0.15em] text-gray-400">Seats</label>
                    <div className="flex flex-wrap gap-1.5">
                      {['all', '4', '5', '7+'].map(s => (
                        <button
                          key={s}
                          onClick={() => setSeats(s)}
                          className={cn('px-3 py-1.5 rounded-full font-mono text-[10px] uppercase tracking-[0.1em] border transition-all',
                            seats === s ? 'bg-gray-900 text-white border-gray-900' : 'text-gray-500 border-gray-200 hover:border-gray-400'
                          )}
                          aria-pressed={seats === s}
                        >
                          {s === 'all' ? 'Any' : s}
                        </button>
                      ))}
                    </div>
                  </div>

                  {/* Sort (mobile) */}
                  <div className="flex flex-col gap-2 sm:hidden">
                    <label className="font-mono text-[10px] uppercase tracking-[0.15em] text-gray-400">Sort By</label>
                    <select
                      value={sortBy}
                      onChange={(e) => setSortBy(e.target.value as SortKey)}
                      className="bg-gray-50 border border-gray-200 rounded-xl px-3 py-2.5 text-[13px] text-gray-700 focus:outline-none focus:border-orange-400"
                    >
                      {SORT_OPTIONS.map(o => <option key={o.key} value={o.key}>{o.label}</option>)}
                    </select>
                  </div>

                  {/* Delivery toggle */}
                  <div className="flex flex-col gap-2">
                    <label className="font-mono text-[10px] uppercase tracking-[0.15em] text-gray-400">Extras</label>
                    <label className="flex items-center gap-3 cursor-pointer">
                      <div
                        className={cn('w-10 h-5 rounded-full transition-colors relative', deliveryOnly ? 'bg-orange-500' : 'bg-gray-200')}
                        onClick={() => setDeliveryOnly(v => !v)}
                        role="switch"
                        aria-checked={deliveryOnly}
                        tabIndex={0}
                        onKeyDown={(e) => e.key === 'Enter' && setDeliveryOnly(v => !v)}
                      >
                        <span className={cn('absolute top-0.5 left-0.5 w-4 h-4 bg-white rounded-full shadow transition-transform', deliveryOnly && 'translate-x-5')} />
                      </div>
                      <span className="text-[13px] text-gray-700">Free delivery only</span>
                    </label>
                  </div>

                  {/* Reset */}
                  {hasActiveFilters && (
                    <div className="flex items-end">
                      <button onClick={resetFilters} className="flex items-center gap-2 text-[13px] text-orange-500 hover:text-orange-600 font-medium transition-colors">
                        <RotateCcw size={13} /> Reset all filters
                      </button>
                    </div>
                  )}
                </div>
              </div>
            </motion.div>
          )}
        </AnimatePresence>

        {/* Results header */}
        <div className="flex items-center justify-between mb-6">
          <p className="font-grotesk text-gray-600">
            <span className="font-bold text-gray-900">{filteredVehicles.length}</span>
            {' '}vehicle{filteredVehicles.length !== 1 ? 's' : ''} found
            {category !== 'all' && <span className="text-gray-400"> in {CATEGORIES.find(c => c.key === category)?.label}</span>}
          </p>
          {hasActiveFilters && (
            <button onClick={resetFilters} className="text-[12px] text-orange-500 hover:text-orange-600 font-medium flex items-center gap-1 transition-colors">
              <X size={11} /> Clear filters
            </button>
          )}
        </div>

        {/* Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
          <AnimatePresence mode="popLayout">
            {filteredVehicles.length === 0 ? (
              <motion.div key="empty" initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="col-span-full py-32 text-center">
                <p className="font-grotesk text-gray-400 text-lg mb-3">No vehicles match your filters.</p>
                <button onClick={resetFilters} className="text-orange-500 hover:text-orange-600 font-medium text-[14px] flex items-center gap-2 mx-auto transition-colors">
                  <RotateCcw size={14} /> Reset filters
                </button>
              </motion.div>
            ) : (
              filteredVehicles.map((vehicle, i) => (
                <VehicleCard key={vehicle.id} vehicle={vehicle} index={i} />
              ))
            )}
          </AnimatePresence>
        </div>

        {/* Bottom CTA */}
        <div className="mt-16 bg-gray-900 rounded-3xl p-8 md:p-12 text-center">
          <h2 className="font-grotesk font-bold text-2xl md:text-3xl text-white mb-3">Can't find what you're looking for?</h2>
          <p className="text-gray-400 mb-6 max-w-md mx-auto">Our team can source any vehicle in Dubai. Message us on WhatsApp and we'll find your perfect match within the hour.</p>
          <a
            href="https://wa.me/971500999733?text=Hi%20Falcon%20View%2C%20I%27m%20looking%20for%20a%20specific%20vehicle%20not%20on%20your%20website."
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2 bg-green-500 hover:bg-green-600 text-white font-grotesk font-semibold text-[15px] px-8 py-4 rounded-full transition-colors shadow-[0_4px_20px_rgba(34,197,94,0.4)]"
          >
            <MessageCircle size={17} /> WhatsApp Our Team
          </a>
        </div>
      </div>

      {/* Footer strip */}
      <footer className="mt-12 border-t border-gray-200 bg-white">
        <div className="max-w-[1400px] mx-auto px-4 sm:px-6 lg:px-8 py-6 flex flex-col sm:flex-row items-center justify-between gap-4">
          <Link to="/" className="flex items-center gap-2 text-gray-500 hover:text-gray-800 transition-colors text-[13px]">
            <ArrowLeft size={14} /> Back to Homepage
          </Link>
          <p className="text-gray-400 text-[12px] font-mono">© 2026 Falcon View Car Rentals L.L.C · Dubai</p>
          <a href="https://wa.me/971500999733" target="_blank" rel="noopener noreferrer"
            className="flex items-center gap-1.5 text-green-600 hover:text-green-700 text-[13px] font-medium transition-colors">
            <MessageCircle size={14} /> +971 50 099 9733
          </a>
        </div>
      </footer>
    </div>
    </>
  );
};

export default FleetPage;
