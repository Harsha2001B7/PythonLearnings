import React, { useEffect, useState } from 'react';
import Navbar, { falconLogo } from '../components/layout/Navbar';
import Footer from '../components/layout/Footer';
import { ToastContainer } from '../components/Toast';
import ChatWidget from '../chatbot/ChatWidget';
import Hero from '../sections/Hero';
import MarqueeTicker from '../sections/MarqueeTicker';
import FeaturedFleet from '../sections/FeaturedFleet';
import FleetExplorer from '../sections/FleetExplorer';
import WhyVanta from '../sections/WhyVanta';
import BookingProcess from '../sections/BookingProcess';
import MembershipSection from '../sections/MembershipSection';
import Testimonials from '../sections/Testimonials';
import CorporateSection from '../sections/CorporateSection';
import AppTeaser from '../sections/AppTeaser';
import FaqSection from '../sections/FaqSection';
import { useBookingStore, useAppStore, useToastStore } from '../store';
import { motion, AnimatePresence } from 'framer-motion';
import { X, BarChart2, MessageCircle } from 'lucide-react';
import { FLEET_DATA } from '../data/fleet';
import { formatAED } from '../lib/formatters';
import { useGSAPReveal } from '../hooks/useGSAPReveal';

// ── Preloader ─────────────────────────────────────────────────────
const Preloader: React.FC<{ done: boolean }> = ({ done }) => (
  <AnimatePresence>
    {!done && (
      <motion.div
        key="preloader"
        exit={{ opacity: 0 }}
        transition={{ duration: 0.6, ease: [0.77, 0, 0.175, 1] }}
        className="fixed inset-0 z-[10000] flex flex-col items-center justify-center gap-8"
        style={{ background: '#0D0D0D' }}
        aria-hidden
      >
        <motion.div
          initial={{ scale: 0.8, opacity: 0, y: 20 }}
          animate={{ scale: 1, opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: 'easeOut' }}
          className="flex flex-col items-center gap-4"
        >
          <motion.div
            animate={{ boxShadow: ['0 0 20px rgba(255,107,0,0.3)', '0 0 60px rgba(255,107,0,0.6)', '0 0 20px rgba(255,107,0,0.3)'] }}
            transition={{ duration: 2, repeat: Infinity }}
            className="rounded-2xl overflow-hidden"
          >
            <img src={falconLogo} alt="Falcon View" className="h-28 w-auto object-contain" />
          </motion.div>
          <motion.p
            initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}
            className="font-grotesk font-bold text-[20px] tracking-widest text-white"
          >
            FALCON VIEW
          </motion.p>
          <motion.p
            initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.5 }}
            className="font-mono text-[9px] uppercase tracking-[0.3em] text-white/40"
          >
            Car Rentals L.L.C · Dubai
          </motion.p>
        </motion.div>
        <div className="w-[180px] h-[2px] bg-white/10 overflow-hidden rounded-full">
          <motion.div
            className="h-full bg-orange-500 rounded-full"
            initial={{ scaleX: 0 }} animate={{ scaleX: 1 }}
            transition={{ duration: 1.4, ease: [0.25, 0.46, 0.45, 0.94] }}
            style={{ transformOrigin: 'left' }}
          />
        </div>
      </motion.div>
    )}
  </AnimatePresence>
);

// ── Booking Modal ─────────────────────────────────────────────────
const BookingModal: React.FC = () => {
  const { selectedVehicleName, setSelectedVehicle } = useBookingStore();
  const { addToast } = useToastStore();
  if (!selectedVehicleName) return null;

  const handleWhatsApp = () => {
    const msg = encodeURIComponent(`Hi Falcon View, I'd like to book the ${selectedVehicleName}. Please send me availability and pricing.`);
    window.open(`https://wa.me/971500999733?text=${msg}`, '_blank');
    setSelectedVehicle(null);
  };

  return (
    <AnimatePresence>
      <motion.div
        key="booking-modal"
        initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
        className="fixed inset-0 z-[800] bg-black/60 backdrop-blur-sm flex items-center justify-center p-6"
        onClick={() => setSelectedVehicle(null)}
        role="dialog" aria-modal="true" aria-label={`Book ${selectedVehicleName}`}
      >
        <motion.div
          initial={{ scale: 0.94, y: 20 }} animate={{ scale: 1, y: 0 }} exit={{ scale: 0.94, y: 20 }}
          transition={{ type: 'spring', stiffness: 300, damping: 28 }}
          onClick={(e) => e.stopPropagation()}
          className="bg-white rounded-2xl p-8 w-full max-w-md shadow-2xl border border-gray-100"
        >
          <div className="flex items-start justify-between mb-5">
            <div>
              <p className="font-mono text-[10px] uppercase tracking-[0.18em] text-orange-500 mb-1">Booking Request</p>
              <h2 className="font-grotesk font-bold text-2xl text-gray-900">{selectedVehicleName}</h2>
            </div>
            <button onClick={() => setSelectedVehicle(null)}
              className="w-8 h-8 rounded-lg border border-gray-200 flex items-center justify-center text-gray-400 hover:border-red-300 hover:text-red-500 transition-all"
              aria-label="Close">
              <X size={15} />
            </button>
          </div>
          <p className="text-gray-500 text-[14px] leading-relaxed mb-6">
            We'll reply in minutes with availability and pricing — no signup, no card required.
          </p>
          <div className="flex gap-3">
            <motion.button whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.97 }}
              onClick={handleWhatsApp}
              className="flex items-center gap-2 flex-1 justify-center bg-green-500 hover:bg-green-600 text-white font-grotesk font-semibold text-[14px] py-3.5 rounded-xl transition-colors"
            >
              <MessageCircle size={16} /> Book via WhatsApp
            </motion.button>
            <button onClick={() => setSelectedVehicle(null)} className="border border-gray-200 text-gray-600 px-4 rounded-xl hover:border-gray-400 transition-colors">
              Cancel
            </button>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
};

// ── Compare Drawer ────────────────────────────────────────────────
const CompareDrawer: React.FC = () => {
  const { compareList, isCompareOpen, setCompareOpen, clearCompare } = useAppStore();
  if (!isCompareOpen) return null;
  const vehicles = compareList.map((id) => FLEET_DATA.find((v) => v.id === id)).filter(Boolean);

  return (
    <AnimatePresence>
      <motion.div key="compare-drawer"
        initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
        className="fixed inset-0 z-[800] bg-black/50 backdrop-blur-sm"
        onClick={() => setCompareOpen(false)}
      >
        <motion.aside
          initial={{ y: '100%' }} animate={{ y: 0 }} exit={{ y: '100%' }}
          transition={{ type: 'spring', stiffness: 300, damping: 32 }}
          onClick={(e) => e.stopPropagation()}
          className="absolute bottom-0 left-0 right-0 bg-white rounded-t-3xl shadow-2xl border-t border-gray-100"
          role="complementary" aria-label="Compare vehicles"
        >
          <div className="section-container py-8">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-2">
                <BarChart2 size={18} className="text-orange-500" />
                <h2 className="font-grotesk font-bold text-xl text-gray-900">Comparing {vehicles.length} vehicles</h2>
              </div>
              <div className="flex gap-2">
                <button onClick={clearCompare} className="border border-gray-200 text-gray-600 text-sm py-2 px-4 rounded-full hover:border-orange-400 hover:text-orange-500 transition-all">Clear</button>
                <button onClick={() => setCompareOpen(false)} className="w-8 h-8 rounded-lg border border-gray-200 flex items-center justify-center text-gray-400">
                  <X size={15} />
                </button>
              </div>
            </div>
            {vehicles.length === 0 ? (
              <p className="text-gray-400 text-center py-8">No vehicles selected.</p>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {vehicles.map((v) => v && (
                  <div key={v.id} className="border border-gray-100 rounded-xl p-5 bg-gray-50">
                    <img src={v.images.thumbnail} alt={v.name} className="w-full h-32 object-cover rounded-lg mb-4" />
                    <h3 className="font-grotesk font-bold text-gray-900 text-lg">{v.name}</h3>
                    <p className="text-orange-500 font-semibold">{formatAED(v.pricePerDay)}/day</p>
                    <div className="mt-3 flex flex-col gap-1.5">
                      {[
                        ['Seats', `${v.specs.seats}`],
                        ['Fuel', v.specs.fuel],
                        ['Transmission', v.specs.transmission],
                        v.specs.power ? ['Power', v.specs.power] : null,
                      ].filter((x): x is [string, string] => x !== null).map(([k, val]) => (
                        <div key={k} className="flex justify-between text-[12px]">
                          <span className="text-gray-400 font-mono uppercase tracking-wider">{k}</span>
                          <span className="text-gray-800 font-medium">{val}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </motion.aside>
      </motion.div>
    </AnimatePresence>
  );
};

// ── WhatsApp Circle FAB ───────────────────────────────────────────
// Sits just above the existing ChatWidget (bottom-6 right-6 → offset by 1 widget-height)
const WhatsAppFAB: React.FC = () => (
  <motion.a
    href="https://wa.me/971500999733?text=Hi%20Falcon%20View%2C%20I%27d%20like%20to%20book%20a%20car"
    target="_blank"
    rel="noopener noreferrer"
    aria-label="Chat on WhatsApp"
    className="fixed z-[700] right-6 flex items-center justify-center bg-green-500 hover:bg-green-600 text-white rounded-full shadow-[0_4px_20px_rgba(34,197,94,0.5)] transition-colors"
    style={{ width: 56, height: 56, bottom: '6rem' }}
    initial={{ scale: 0, opacity: 0 }}
    animate={{ scale: 1, opacity: 1 }}
    transition={{ delay: 2.5, type: 'spring', stiffness: 300, damping: 20 }}
    whileHover={{ scale: 1.1, y: -2 }}
    whileTap={{ scale: 0.92 }}
  >
    {/* WhatsApp SVG icon */}
    <svg width="26" height="26" viewBox="0 0 24 24" fill="white">
      <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
    </svg>
  </motion.a>
);

// ── Floating Compare Button ───────────────────────────────────────
const FloatingCompareBtn: React.FC = () => {
  const { compareList, setCompareOpen } = useAppStore();
  if (compareList.length === 0) return null;

  return (
    <motion.button
      initial={{ opacity: 0, y: 50, scale: 0.9 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      exit={{ opacity: 0, y: 50, scale: 0.9 }}
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
      onClick={() => setCompareOpen(true)}
      className="fixed z-[700] bottom-8 left-1/2 -translate-x-1/2 bg-gray-900 text-white font-grotesk font-semibold px-6 py-3 rounded-full flex items-center gap-2 shadow-[0_8px_30px_rgba(0,0,0,0.3)]"
    >
      <BarChart2 size={16} className="text-orange-500" />
      Compare {compareList.length} Vehicle{compareList.length > 1 ? 's' : ''}
    </motion.button>
  );
};

// ── Home Page ─────────────────────────────────────────────────────
const Home: React.FC = () => {
  const [preloaderDone, setPreloaderDone] = useState(() => {
    return sessionStorage.getItem('falcon_preloader_done') === 'true';
  });
  
  useGSAPReveal();

  useEffect(() => {
    if (preloaderDone) return;
    const t = setTimeout(() => {
      setPreloaderDone(true);
      sessionStorage.setItem('falcon_preloader_done', 'true');
    }, 1800);
    return () => clearTimeout(t);
  }, [preloaderDone]);

  return (
    <>
      <Preloader done={preloaderDone} />

      <div className="min-h-screen">
        <Navbar />

        <main>
          {/* ── DARK section: Hero only ── */}
          <Hero />

          {/* ── LIGHT sections: everything below ── */}
          <div data-theme="light">
            <MarqueeTicker />
            <FeaturedFleet />
            <WhyVanta />
            <FleetExplorer />
            <BookingProcess />
            <MembershipSection />
            <Testimonials />
            <CorporateSection />
            <AppTeaser />
            <FaqSection />
          </div>
        </main>

        {/* Footer stays dark by its own explicit bg-[#080808] */}
        <Footer />

        {/* Global overlays */}
        <BookingModal />
        <CompareDrawer />
        <ChatWidget />
        <ToastContainer />
        {/* WhatsApp circle FAB — sits above the chat widget */}
        <WhatsAppFAB />
        <AnimatePresence>
          <FloatingCompareBtn />
        </AnimatePresence>
      </div>
    </>
  );
};

export default Home;
