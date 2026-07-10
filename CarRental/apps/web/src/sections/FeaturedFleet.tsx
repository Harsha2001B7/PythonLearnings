import React, { useCallback } from 'react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { Heart, ArrowRight, Zap, Gauge, Users, ChevronLeft, ChevronRight } from 'lucide-react';
import useEmblaCarousel from 'embla-carousel-react';
import { useQuery } from '@tanstack/react-query';
import { vehicleService } from '../services/api/vehicles';
import { useAppStore, useToastStore, useBookingStore } from '../store';
import { formatAED } from '../lib/formatters';
import { ease, duration } from '../lib/easing';
import { cn } from '../lib/cn';

const CATEGORY_COLORS: Record<string, string> = {
  coupe:    'bg-orange-500/10 text-orange-400',
  sedan:    'bg-sky-500/10 text-sky-400',
  suv:      'bg-emerald-500/10 text-emerald-400',
  hatchback:'bg-purple-500/10 text-purple-400',
  '7seater':'bg-amber-500/10 text-amber-400',
  ev:       'bg-teal-500/10 text-teal-400',
  roadster: 'bg-rose-500/10 text-rose-400',
};

const FeaturedFleet: React.FC = () => {
  const navigate = useNavigate();
  const { wishlist, toggleWishlist, toggleCompare, compareList } = useAppStore();
  const { addToast } = useToastStore();
  const { setSelectedVehicle } = useBookingStore();
  
  const { data: featuredVehicles = [], isLoading } = useQuery({
    queryKey: ['vehicles', 'featured'],
    queryFn: () => vehicleService.getFeaturedVehicles(),
  });

  const [emblaRef, emblaApi] = useEmblaCarousel({ 
    loop: true, 
    align: 'start',
    skipSnaps: false,
    dragFree: true
  });

  const scrollPrev = useCallback(() => {
    if (emblaApi) emblaApi.scrollPrev();
  }, [emblaApi]);

  const scrollNext = useCallback(() => {
    if (emblaApi) emblaApi.scrollNext();
  }, [emblaApi]);

  const handleWishlist = (id: number, name: string) => {
    toggleWishlist(id);
    addToast(
      wishlist.includes(id) ? `Removed ${name} from wishlist` : `Added ${name} to wishlist`
    );
  };

  const handleCompare = (id: number, name: string) => {
    if (!compareList.includes(id) && compareList.length >= 3) {
      addToast('Compare up to 3 vehicles at a time', 'error');
      return;
    }
    toggleCompare(id);
    addToast(
      compareList.includes(id) ? `Removed from compare` : `Added ${name} to compare`
    );
  };

  return (
    <section id="fleet" className="py-24 bg-vanta-paper overflow-hidden">
      <div className="section-container mb-10">
        <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-6">
          <div>
            <motion.div
              className="eyebrow mb-3"
              initial={{ opacity: 0, x: -16 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ duration: duration.slow, ease: ease.elegant }}
            >
              Signature Collection
            </motion.div>
            <motion.h2
              className="font-display text-display-lg text-vanta-ink"
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.1 }}
            >
              Featured Fleet.{' '}
              <span className="italic font-light text-vanta-amber">Zero compromise.</span>
            </motion.h2>
            <motion.p
              className="text-vanta-ink-muted mt-3 max-w-md text-[15px] leading-relaxed"
              initial={{ opacity: 0, y: 16 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.2 }}
            >
              Every vehicle inspected, detailed, and calibrated before it reaches you.
            </motion.p>
          </div>
          <div className="flex flex-col sm:flex-row items-start sm:items-center gap-4 shrink-0 mt-4 md:mt-0">
            <motion.a
              href="#fleet-explorer"
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true }}
              transition={{ delay: 0.3 }}
              className="btn-ghost text-sm flex items-center gap-2"
              onClick={(e) => {
                e.preventDefault();
                document.getElementById('fleet-explorer')?.scrollIntoView({ behavior: 'smooth' });
              }}
            >
              Browse All Vehicles <ArrowRight size={14} />
            </motion.a>
          </div>
        </div>
      </div>

      {/* Infinite Scroll Carousel */}
      <div className="relative group mt-8">
        <div className="overflow-hidden pl-6 md:pl-10 lg:pl-16 py-4" ref={emblaRef}>
          <div className="flex gap-6 pb-6" style={{ backfaceVisibility: 'hidden', touchAction: 'pan-y' }}>
          {isLoading ? (
            <div className="w-full flex justify-center p-10"><div className="w-8 h-8 rounded-full border-2 border-orange-500/30 border-t-orange-500 animate-spin" /></div>
          ) : featuredVehicles.map((vehicle: any, i: number) => (
            <div key={`${vehicle.id}-${i}`} className="flex-none w-[300px] sm:w-[340px] relative">
              <motion.article
                initial={{ opacity: 0, x: 40 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true, margin: '-60px' }}
                transition={{ duration: duration.slow, ease: ease.elegant, delay: i * 0.08 }}
                className={cn(
                  'shimmer-card w-full h-full bg-surface-primary rounded-2xl overflow-hidden flex flex-col',
                  'focus-within:border-accent-orange cursor-pointer'
                )}
                role="listitem"
                onClick={() => navigate(`/vehicles/${vehicle.slug}`)}
              >
            {/* Image */}
            <div className="relative h-52 overflow-hidden bg-vanta-paper-soft">
              <motion.img
                src={vehicle.images.thumbnail}
                alt={`${vehicle.name} — ${vehicle.tagline}`}
                className="gsap-reveal-image w-full h-full object-cover origin-center"
                whileHover={{ scale: 1.05 }}
                transition={{ duration: 0.5, ease: ease.elegant }}
                loading="lazy"
              />
              {/* Badge */}
              {vehicle.badge && (
                <span className="absolute top-3 left-3 bg-vanta-amber text-white font-mono text-[9px] uppercase tracking-[0.15em] px-2.5 py-1 rounded-full z-10">
                  {vehicle.badge}
                </span>
              )}
              {/* Wishlist */}
              <motion.button
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
                onClick={(e) => {
                  e.stopPropagation();
                  handleWishlist(vehicle.id, vehicle.name);
                }}
                className={cn(
                  'absolute top-3 right-3 w-9 h-9 rounded-full bg-white/85 backdrop-blur-sm flex items-center justify-center shadow-card-sm transition-colors',
                  wishlist.includes(vehicle.id) ? 'text-vanta-danger' : 'text-vanta-ink-subtle hover:text-vanta-ink'
                )}
                aria-label={wishlist.includes(vehicle.id) ? `Remove ${vehicle.name} from wishlist` : `Add ${vehicle.name} to wishlist`}
              >
                <Heart size={14} fill={wishlist.includes(vehicle.id) ? 'currentColor' : 'none'} />
              </motion.button>
            </div>

            {/* Content */}
            <div className="p-5 flex flex-col gap-4 flex-1">
              <div className="flex items-start justify-between gap-2">
                <div>
                  <h3 className="font-grotesk font-bold text-lg text-text-primary leading-tight">{vehicle.name}</h3>
                  <p className="text-text-secondary text-[12px] mt-0.5">{vehicle.tagline}</p>
                </div>
                <span className={cn('font-mono text-[9px] uppercase tracking-[0.12em] px-2 py-1 rounded-full shrink-0', CATEGORY_COLORS[vehicle.category] || 'bg-gray-100 text-gray-600')}>
                  {vehicle.category}
                </span>
              </div>

              {/* Specs Pills */}
              <div className="flex flex-wrap gap-1.5">
                {vehicle.specs.power && (
                  <span className="inline-flex items-center gap-1 font-mono text-[10px] text-text-secondary border border-subtle px-2 py-0.5 rounded-md">
                    <Zap size={8} />{vehicle.specs.power}
                  </span>
                )}
                {vehicle.specs.zeroToSixty && (
                  <span className="inline-flex items-center gap-1 font-mono text-[10px] text-text-secondary border border-subtle px-2 py-0.5 rounded-md">
                    <Gauge size={8} />{vehicle.specs.zeroToSixty} 0–60
                  </span>
                )}
                <span className="inline-flex items-center gap-1 font-mono text-[10px] text-text-secondary border border-subtle px-2 py-0.5 rounded-md">
                  <Users size={8} />{vehicle.specs.seats} seats
                </span>
              </div>

              {/* Price + Actions */}
              <div className="flex items-center justify-between mt-auto pt-2 border-t border-subtle">
                <div>
                  <span className="font-grotesk font-bold text-xl text-text-primary">{formatAED(vehicle.pricePerDay)}</span>
                  <span className="text-text-secondary text-[11px]">/day</span>
                </div>
                <motion.button
                  whileHover={{ scale: 1.03, y: -1 }}
                  whileTap={{ scale: 0.97 }}
                  onClick={(e) => { e.stopPropagation(); navigate(`/vehicles/${vehicle.slug}`); }}
                  className="btn-amber text-[12px] py-2 px-4"
                >
                  View &amp; Book
                </motion.button>
              </div>

                <label 
                  onClick={(e) => e.stopPropagation()}
                  className="flex items-center gap-2 font-mono text-[10px] text-text-secondary cursor-pointer hover:text-text-primary transition-colors"
                >
                  <input
                    type="checkbox"
                    checked={compareList.includes(vehicle.id)}
                    onChange={() => handleCompare(vehicle.id, vehicle.name)}
                    className="accent-accent-orange rounded"
                    aria-label={`Add ${vehicle.name} to compare`}
                  />
                  Add to compare
                </label>
              </div>
            </motion.article>
          </div>
        ))}
      </div>
    </div>
      
    {/* Floating Side Arrows */}
      <button 
        onClick={scrollPrev} 
        className="absolute left-4 top-1/2 -translate-y-1/2 w-14 h-14 rounded-full bg-surface-primary/95 backdrop-blur border border-subtle flex items-center justify-center text-text-primary shadow-card-lg opacity-0 group-hover:opacity-100 transition-all hover:scale-105 hover:text-accent-orange hover:border-accent-orange z-10"
        aria-label="Previous vehicle"
      >
        <ChevronLeft size={28} />
      </button>
      <button 
        onClick={scrollNext} 
        className="absolute right-4 top-1/2 -translate-y-1/2 w-14 h-14 rounded-full bg-surface-primary/95 backdrop-blur border border-subtle flex items-center justify-center text-text-primary shadow-card-lg opacity-0 group-hover:opacity-100 transition-all hover:scale-105 hover:text-accent-orange hover:border-accent-orange z-10"
        aria-label="Next vehicle"
      >
        <ChevronRight size={28} />
      </button>
    </div>
    </section>
  );
};

export default FeaturedFleet;
