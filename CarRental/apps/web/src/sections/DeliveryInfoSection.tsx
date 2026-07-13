import React from 'react';
import { motion } from 'framer-motion';
import { MapPin, ArrowRight } from 'lucide-react';
import { ease, duration } from '../lib/easing';

const GoldenRouteIllustration = () => (
  <div className="relative w-full max-w-[280px] h-[160px] flex items-center justify-center">
    {/* Soft glow behind the illustration */}
    <div className="absolute inset-0 bg-vanta-amber/10 blur-3xl rounded-full opacity-60" />
    
    <svg width="280" height="120" viewBox="0 0 280 120" fill="none" xmlns="http://www.w3.org/2000/svg" className="relative z-10">
      {/* Route Path */}
      <motion.path 
        d="M 20 100 C 100 100, 140 30, 250 20" 
        stroke="url(#goldGradient)" 
        strokeWidth="1.5" 
        strokeLinecap="round"
        strokeDasharray="4 4"
        initial={{ pathLength: 0, opacity: 0 }}
        whileInView={{ pathLength: 1, opacity: 1 }}
        transition={{ duration: 2.5, ease: "easeInOut" }}
        viewport={{ once: true, margin: "-50px" }}
      />
      
      {/* Starting Dot */}
      <motion.circle 
        cx="20" cy="100" r="3" 
        fill="#555" 
        initial={{ scale: 0, opacity: 0 }}
        whileInView={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.5, delay: 0.2 }}
        viewport={{ once: true }}
      />
      
      {/* Pulsing Destination Pin */}
      <motion.g 
        initial={{ y: -10, opacity: 0 }}
        whileInView={{ y: 0, opacity: 1 }}
        transition={{ duration: 0.8, delay: 2, ease: ease.elegant }}
        viewport={{ once: true }}
      >
        <motion.circle 
          cx="250" cy="20" r="12" 
          fill="rgba(255, 107, 0, 0.2)"
          animate={{ scale: [1, 1.5, 1], opacity: [0.7, 0, 0.7] }}
          transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
        />
        <circle cx="250" cy="20" r="4" fill="#FF6B00" />
      </motion.g>

      {/* Decorative luxury lines */}
      <motion.path 
        d="M 250 28 L 250 45" 
        stroke="rgba(255, 107, 0, 0.3)" 
        strokeWidth="1"
        initial={{ scaleY: 0 }}
        whileInView={{ scaleY: 1 }}
        transition={{ duration: 1, delay: 2.5 }}
        viewport={{ once: true }}
      />

      <defs>
        <linearGradient id="goldGradient" x1="20" y1="100" x2="250" y2="20" gradientUnits="userSpaceOnUse">
          <stop stopColor="#333" />
          <stop offset="0.6" stopColor="#FF8C33" />
          <stop offset="1" stopColor="#FF6B00" />
        </linearGradient>
      </defs>
    </svg>
  </div>
);

const DeliveryInfoSection: React.FC = () => {
  const handleScrollToFleet = () => {
    document.getElementById('fleet')?.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <section className="relative w-full pt-20 pb-28 lg:pt-32 lg:pb-36 overflow-hidden flex items-center" style={{ backgroundColor: '#0A0A0A' }}>
      
      {/* ── Background & Ambient Lighting ── */}
      <div className="absolute inset-0 pointer-events-none">
        {/* Soft noise texture overlay for luxury feel */}
        <div className="absolute inset-0 opacity-[0.03]" style={{ backgroundImage: 'url("data:image/svg+xml,%3Csvg viewBox=\'0 0 200 200\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cfilter id=\'noiseFilter\'%3E%3CfeTurbulence type=\'fractalNoise\' baseFrequency=\'0.85\' numOctaves=\'3\' stitchTiles=\'stitch\'/%3E%3C/filter%3E%3Crect width=\'100%25\' height=\'100%25\' filter=\'url(%23noiseFilter)\'/%3E%3C/svg%3E")' }} />
        
        {/* Subtle radial glow */}
        <div className="absolute top-1/2 right-0 -translate-y-1/2 w-[600px] h-[600px] bg-vanta-amber/5 blur-[120px] rounded-full" />
      </div>
      
      {/* ── Transition Bottom Gradient ── */}
      <div className="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-b from-transparent to-[#111111]" />
      <div className="absolute bottom-0 left-0 right-0 h-[1px] bg-gradient-to-r from-transparent via-white/10 to-transparent" />

      <div className="section-container relative z-10 w-full">
        <div className="flex flex-col lg:flex-row items-center justify-between gap-16 lg:gap-20">
          
          {/* ── Left: Content ── */}
          <div className="flex-1 flex flex-col items-center text-center lg:items-start lg:text-left">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-50px' }}
              transition={{ duration: duration.slow, ease: ease.elegant }}
            >
              <h2 className="font-display font-light text-4xl sm:text-5xl lg:text-6xl text-white tracking-tight leading-[1.1] mb-6">
                Free Pickup & Delivery <br className="hidden sm:block" />
                <span className="font-medium text-transparent bg-clip-text bg-gradient-to-r from-white via-white to-vanta-amber/80">Across Dubai</span>
              </h2>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-50px' }}
              transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.1 }}
            >
              <p className="text-white/80 text-base sm:text-lg leading-relaxed font-sans max-w-2xl mb-10 font-light tracking-wide">
                Enjoy complimentary pickup and delivery for qualifying reservations across Dubai. Our concierge team delivers your chosen vehicle directly to your hotel, residence, office, or airport, providing a seamless luxury rental experience from start to finish.
              </p>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-50px' }}
              transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.2 }}
            >
              <button
                onClick={handleScrollToFleet}
                className="group flex items-center gap-4 text-white hover:text-vanta-amber transition-colors duration-300 pb-1 border-b border-white/20 hover:border-vanta-amber"
              >
                <span className="font-mono text-xs uppercase tracking-[0.2em] font-medium">View Available Cars</span>
                <ArrowRight className="w-4 h-4 transform group-hover:translate-x-1 transition-transform" />
              </button>
            </motion.div>
          </div>

          {/* ── Right: Minimal Graphic ── */}
          <motion.div 
            className="w-full lg:w-auto flex justify-center items-center"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true, margin: '-50px' }}
            transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.3 }}
          >
            <GoldenRouteIllustration />
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default DeliveryInfoSection;
