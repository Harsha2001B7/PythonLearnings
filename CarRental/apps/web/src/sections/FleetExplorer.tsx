import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Heart, BarChart2, ArrowRight, SlidersHorizontal } from 'lucide-react';
import { FLEET_DATA } from '../data/fleet';
import { useAppStore, useToastStore, useBookingStore, useFilterStore } from '../store';
import { formatAED } from '../lib/formatters';
import { ease, duration } from '../lib/easing';
import { cn } from '../lib/cn';

const CATEGORIES = ['all', 'coupe', 'sedan', 'suv', 'ev', 'roadster'] as const;
const TRANSMISSIONS = ['all', 'auto', 'manual'] as const;
const FUELS = ['all', 'electric', 'petrol', 'hybrid'] as const;
const SEATS = ['all', '2', '4', '5', '7+'] as const;

// Animated filter chip
const Chip: React.FC<{
  label: string;
  active: boolean;
  onClick: () => void;
}> = ({ label, active, onClick }) => (
  <motion.button
    onClick={onClick}
    whileTap={{ scale: 0.95 }}
    className={cn(
      'px-4 py-1.5 rounded-full font-mono text-[10px] uppercase tracking-[0.12em] border transition-all duration-200',
      active
        ? 'bg-vanta-amber border-vanta-amber text-white shadow-amber-sm'
        : 'border-vanta-border text-vanta-ink-muted hover:border-vanta-amber/50 hover:text-vanta-ink'
    )}
    aria-pressed={active}
  >
    {label === 'all' ? 'All' : label}
  </motion.button>
);

const FleetExplorer: React.FC = () => {
  const { wishlist, toggleWishlist, compareList, toggleCompare, setCompareOpen } = useAppStore();
  const { addToast } = useToastStore();
  const { setSelectedVehicle } = useBookingStore();
  const {
    category, maxPrice, transmission, fuel, seats,
    setCategory, setMaxPrice, setTransmission, setFuel, setSeats, resetFilters,
  } = useFilterStore();

  const filteredVehicles = FLEET_DATA.filter((v) => {
    const priceMatch = v.pricePerDay <= maxPrice;
    const catMatch = category === 'all' || v.category === category;
    const transMatch = transmission === 'all' || v.specs.transmission === transmission;
    const fuelMatch = fuel === 'all' || v.specs.fuel === fuel;
    const seatsMatch =
      seats === 'all'
        ? true
        : seats === '7+'
        ? v.specs.seats >= 7
        : v.specs.seats === parseInt(seats);
    return priceMatch && catMatch && transMatch && fuelMatch && seatsMatch;
  });

  const handleWishlist = (id: number, name: string) => {
    toggleWishlist(id);
    addToast(wishlist.includes(id) ? `Removed ${name} from wishlist` : `Added ${name} to wishlist`);
  };

  const handleCompare = (id: number, name: string) => {
    if (!compareList.includes(id) && compareList.length >= 3) {
      addToast('Compare up to 3 vehicles at a time', 'error');
      return;
    }
    toggleCompare(id);
    if (!compareList.includes(id)) addToast(`${name} added to compare`);
  };

  return (
    <section id="fleet-explorer" className="py-24 bg-vanta-paper-soft">
      <div className="section-container flex flex-col gap-12">
        {/* Header */}
        <div>
          <motion.div
            className="eyebrow mb-3"
            initial={{ opacity: 0, x: -16 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: duration.slow, ease: ease.elegant }}
          >
            Interactive Explorer
          </motion.div>
          <motion.h2
            className="font-display text-display-lg text-vanta-ink"
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.1 }}
          >
            Find Your Perfect{' '}
            <span className="italic font-light text-vanta-amber">Match.</span>
          </motion.h2>
        </div>

        {/* Filters Panel */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.15 }}
          className="bg-vanta-panel border border-vanta-border rounded-2xl p-6 shadow-card-sm"
        >
          <div className="flex items-center justify-between mb-5">
            <div className="flex items-center gap-2 text-vanta-ink-muted">
              <SlidersHorizontal size={14} />
              <span className="font-mono text-[11px] uppercase tracking-[0.15em]">Filters</span>
            </div>
            <button
              onClick={resetFilters}
              className="font-mono text-[10px] uppercase tracking-[0.12em] text-vanta-amber hover:text-vanta-amber-light transition-colors"
            >
              Reset
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {/* Category */}
            <div className="flex flex-col gap-2">
              <span className="font-mono text-[9px] uppercase tracking-[0.18em] text-vanta-ink-subtle">Category</span>
              <div className="flex flex-wrap gap-1.5">
                {CATEGORIES.map((c) => (
                  <Chip key={c} label={c} active={category === c} onClick={() => setCategory(c)} />
                ))}
              </div>
            </div>

            {/* Price */}
            <div className="flex flex-col gap-2">
              <div className="flex justify-between">
                <span className="font-mono text-[9px] uppercase tracking-[0.18em] text-vanta-ink-subtle">Max Price</span>
                <span className="font-grotesk font-semibold text-[12px] text-vanta-amber">{formatAED(maxPrice)}/day</span>
              </div>
              <input
                type="range"
                min={500}
                max={2000}
                step={50}
                value={maxPrice}
                onChange={(e) => setMaxPrice(parseInt(e.target.value))}
                className="w-full accent-vanta-amber"
                aria-label="Maximum price per day"
              />
            </div>

            {/* Transmission */}
            <div className="flex flex-col gap-2">
              <span className="font-mono text-[9px] uppercase tracking-[0.18em] text-vanta-ink-subtle">Transmission</span>
              <div className="flex flex-wrap gap-1.5">
                {TRANSMISSIONS.map((t) => (
                  <Chip key={t} label={t} active={transmission === t} onClick={() => setTransmission(t)} />
                ))}
              </div>
            </div>

            {/* Seats */}
            <div className="flex flex-col gap-2">
              <span className="font-mono text-[9px] uppercase tracking-[0.18em] text-vanta-ink-subtle">Seats</span>
              <div className="flex flex-wrap gap-1.5">
                {SEATS.map((s) => (
                  <Chip key={s} label={s} active={seats === s} onClick={() => setSeats(s)} />
                ))}
              </div>
            </div>
          </div>
        </motion.div>

        {/* Results */}
        <div>
          <div className="flex items-center justify-between mb-5">
            <span className="font-mono text-[11px] uppercase tracking-[0.15em] text-vanta-ink-muted">
              {filteredVehicles.length} {filteredVehicles.length === 1 ? 'vehicle' : 'vehicles'} found
            </span>
            {compareList.length > 0 && (
              <motion.button
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                onClick={() => setCompareOpen(true)}
                className="btn-amber text-[11px] py-2 px-4 flex items-center gap-1.5"
              >
                <BarChart2 size={12} /> Compare {compareList.length}
              </motion.button>
            )}
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            <AnimatePresence mode="popLayout">
              {filteredVehicles.length === 0 ? (
                <motion.div
                  key="empty"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                  className="col-span-full py-20 text-center"
                >
                  <p className="font-grotesk text-vanta-ink-muted text-lg">No vehicles match your filters.</p>
                  <button onClick={resetFilters} className="btn-ghost mt-4 text-sm">Reset Filters</button>
                </motion.div>
              ) : (
                filteredVehicles.map((vehicle) => (
                  <motion.article
                    layout
                    key={vehicle.id}
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 0.92 }}
                    transition={{ duration: 0.3, ease: ease.elegant }}
                    className="shimmer-card bg-vanta-panel rounded-xl overflow-hidden flex flex-col"
                    role="article"
                    aria-label={vehicle.name}
                  >
                    {/* Image */}
                    <div className="relative h-40 overflow-hidden bg-vanta-paper-soft">
                      <img
                        src={vehicle.images.thumbnail}
                        alt={vehicle.name}
                        className="w-full h-full object-cover"
                        loading="lazy"
                      />
                      <button
                        onClick={() => handleWishlist(vehicle.id, vehicle.name)}
                        className={cn(
                          'absolute top-2 right-2 w-8 h-8 rounded-full bg-white/80 backdrop-blur-sm flex items-center justify-center shadow-card-sm transition-colors',
                          wishlist.includes(vehicle.id) ? 'text-vanta-danger' : 'text-vanta-ink-subtle hover:text-vanta-ink'
                        )}
                        aria-label={`${wishlist.includes(vehicle.id) ? 'Remove' : 'Add'} ${vehicle.name} from wishlist`}
                      >
                        <Heart size={12} fill={wishlist.includes(vehicle.id) ? 'currentColor' : 'none'} />
                      </button>
                    </div>

                    <div className="p-4 flex flex-col gap-3 flex-1">
                      <div className="flex items-start justify-between">
                        <div>
                          <h3 className="font-grotesk font-semibold text-[15px] text-vanta-ink">{vehicle.name}</h3>
                          <span className="font-mono text-[10px] text-vanta-ink-muted">
                            {vehicle.specs.seats} seats · {vehicle.specs.transmission} · {vehicle.specs.fuel}
                          </span>
                        </div>
                        <span className="font-grotesk font-bold text-vanta-amber text-[15px]">
                          {formatAED(vehicle.pricePerDay)}<span className="text-vanta-ink-subtle text-[10px] font-normal">/day</span>
                        </span>
                      </div>

                      <div className="flex gap-2 mt-auto">
                        <motion.button
                          whileTap={{ scale: 0.97 }}
                          onClick={() => setSelectedVehicle(vehicle.name)}
                          className="btn-amber text-[11px] py-2 px-3 flex-1"
                        >
                          Book Now
                        </motion.button>
                        <button
                          onClick={() => handleCompare(vehicle.id, vehicle.name)}
                          className={cn(
                            'w-9 h-9 rounded-lg border flex items-center justify-center transition-all',
                            compareList.includes(vehicle.id)
                              ? 'border-vanta-amber bg-vanta-amber/10 text-vanta-amber'
                              : 'border-vanta-border text-vanta-ink-subtle hover:border-vanta-amber hover:text-vanta-amber'
                          )}
                          aria-label={`${compareList.includes(vehicle.id) ? 'Remove from' : 'Add to'} compare`}
                        >
                          <BarChart2 size={13} />
                        </button>
                      </div>
                    </div>
                  </motion.article>
                ))
              )}
            </AnimatePresence>
          </div>
        </div>
      </div>
    </section>
  );
};

export default FleetExplorer;
