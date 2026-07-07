import React from 'react';
import { motion } from 'framer-motion';
import { Smartphone, Bell, MapPin, Shield, Star } from 'lucide-react';
import { ease, duration } from '../lib/easing';
import { useToastStore } from '../store';
import { falconLogo } from '../components/layout/Navbar';

// ── SVG Official Logos ──
const AppleLogo: React.FC<React.SVGProps<SVGSVGElement>> = (props) => (
  <svg viewBox="0 0 24 24" fill="currentColor" {...props}>
    <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 4.17c.66-.81 1.11-1.93.99-3.06-1 .04-2.22.67-2.94 1.5-.62.71-1.16 1.85-1.01 2.96 1.12.09 2.27-.58 2.96-1.4z" />
  </svg>
);

const PlayStoreLogo: React.FC<React.SVGProps<SVGSVGElement>> = (props) => (
  <svg viewBox="0 0 24 24" fill="currentColor" {...props}>
    <path d="M3.25 2.3c-.1.1-.2.3-.2.5v18.4c0 .2.1.4.2.5l9.7-9.7-9.7-9.7zM17.8 7.4L13.8 12l4 4.6 4.7-2.7c1.3-.7 1.3-1.9 0-2.7L17.8 7.4zM4.3 1.2l12.7 7.3-3.2 3.2L4.3 1.2zm0 21.6l9.8-9.8 3.2 3.2L4.3 22.8z" />
  </svg>
);

const APP_FEATURES = [
  { icon: Bell,      title: 'Real-time Notifications', desc: 'Delivery status, booking confirmations, and concierge updates instantly on your phone.' },
  { icon: MapPin,    title: 'Live Vehicle Tracking',   desc: 'Watch your vehicle approach on the map. No more waiting and wondering.' },
  { icon: Shield,    title: 'Digital ID & Documents',  desc: 'Store your licence and passport in-app — no paperwork at handoff, ever.' },
  { icon: Star,      title: 'Loyalty & Rewards',       desc: 'Earn Falcon View credits on every rental. Redeem for free days, upgrades, and events.' },
];

// ── Dark Phone Mockup ─────────────────────────────────────────────
const PhoneMockup: React.FC = () => (
  <div className="relative mx-auto" style={{ width: 240, height: 490 }} aria-hidden="true">
    <svg viewBox="0 0 240 490" fill="none" xmlns="http://www.w3.org/2000/svg" className="absolute inset-0 w-full h-full drop-shadow-2xl">
      {/* Phone body — dark */}
      <rect x="4" y="4" width="232" height="482" rx="36" fill="#1A1A1A" stroke="#2A2A2A" strokeWidth="1.5" />
      <rect x="10" y="10" width="220" height="470" rx="30" fill="#141414" />
      {/* Notch */}
      <rect x="88" y="16" width="64" height="8" rx="4" fill="#2A2A2A" />
      {/* Status bar */}
      <rect x="20" y="36" width="60" height="5" rx="2.5" fill="#2A2A2A" />
      <rect x="172" y="36" width="38" height="5" rx="2.5" fill="#2A2A2A" />
      {/* Hero card — orange tinted */}
      <rect x="16" y="58" width="208" height="110" rx="16" fill="#1E1A16" />
      <rect x="28" y="74" width="80" height="8" rx="4" fill="#FFFFFF" />
      <rect x="28" y="90" width="120" height="5" rx="2.5" fill="#A0A0A0" />
      <rect x="28" y="108" width="70" height="22" rx="11" fill="#FF6B00" />
      {/* Map area — dark with orange pin */}
      <rect x="16" y="180" width="208" height="90" rx="16" fill="#1A1A1A" stroke="#2A2A2A" strokeWidth="1" />
      <circle cx="120" cy="225" r="14" fill="#FF6B00" opacity="0.15" />
      <circle cx="120" cy="225" r="7" fill="#FF6B00" />
      <rect x="24" y="190" width="100" height="5" rx="2.5" fill="#2A2A2A" />
      <rect x="24" y="202" width="70" height="5" rx="2.5" fill="#2A2A2A" />
      {/* Status cards */}
      <rect x="16" y="284" width="98" height="60" rx="12" fill="#1A1A1A" stroke="#2A2A2A" strokeWidth="1" />
      <rect x="126" y="284" width="98" height="60" rx="12" fill="#1E1A16" stroke="#FF6B00" strokeWidth="1" strokeOpacity="0.3" />
      <rect x="28" y="300" width="40" height="5" rx="2.5" fill="#606060" />
      <rect x="28" y="313" width="60" height="8" rx="4" fill="#FFFFFF" />
      <rect x="138" y="300" width="40" height="5" rx="2.5" fill="#FF6B00" opacity="0.7" />
      <rect x="138" y="313" width="55" height="8" rx="4" fill="#FF6B00" />
      {/* Bottom nav */}
      <rect x="16" y="436" width="208" height="40" rx="12" fill="#1A1A1A" stroke="#2A2A2A" strokeWidth="1" />
      <rect x="36" y="450" width="24" height="12" rx="6" fill="#FF6B00" />
      <rect x="78" y="450" width="24" height="12" rx="6" fill="#2A2A2A" />
      <rect x="120" y="450" width="24" height="12" rx="6" fill="#2A2A2A" />
      <rect x="162" y="450" width="24" height="12" rx="6" fill="#2A2A2A" />
    </svg>
  </div>
);

const AppTeaser: React.FC = () => {
  const { addToast } = useToastStore();

  return (
    <section id="app" className="py-24 bg-vanta-paper-soft overflow-hidden">
      <div className="section-container">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
          {/* Phone mockup */}
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: duration.cinematic, ease: ease.elegant }}
            className="flex justify-center lg:justify-start"
          >
            <motion.div
              animate={{ y: [-6, 6, -6] }}
              transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut' }}
            >
              <PhoneMockup />
            </motion.div>
          </motion.div>

          {/* Content */}
          <div>
            <motion.div
              className="eyebrow mb-3"
              initial={{ opacity: 0, x: -16 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ duration: duration.slow, ease: ease.elegant }}
            >
              Falcon View for Mobile
            </motion.div>

            <motion.h2
              className="font-display text-display-lg text-vanta-ink mb-5"
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.1 }}
            >
              Everything in your{' '}
              <span className="italic font-light text-vanta-amber">pocket.</span>
            </motion.h2>

            <motion.p
              className="text-vanta-ink-muted text-[15px] leading-relaxed mb-10"
              initial={{ opacity: 0, y: 16 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.15 }}
            >
              The Falcon View app brings the full booking experience, live vehicle tracking, and your concierge line into one beautifully designed interface. Book a car in two taps.
            </motion.p>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-5 mb-10">
              {APP_FEATURES.map((feat, i) => {
                const Icon = feat.icon;
                return (
                  <motion.div
                    key={feat.title}
                    initial={{ opacity: 0, y: 20 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    viewport={{ once: true }}
                    transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.2 + i * 0.08 }}
                    className="flex flex-col gap-2"
                  >
                    <div className="flex items-center gap-2">
                      <Icon size={16} className="text-vanta-amber shrink-0" />
                      <h3 className="font-grotesk font-semibold text-[14px] text-vanta-ink">{feat.title}</h3>
                    </div>
                    <p className="text-vanta-ink-muted text-[12px] leading-relaxed">{feat.desc}</p>
                  </motion.div>
                );
              })}
            </div>

            {/* Store Buttons */}
            <motion.div
              initial={{ opacity: 0, y: 16 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.5 }}
              className="flex flex-wrap gap-4"
            >
              {/* App Store Badge */}
              <motion.button
                whileHover={{ scale: 1.04, y: -1 }}
                whileTap={{ scale: 0.98 }}
                onClick={() => addToast('App Store launch coming soon')}
                className="flex items-center gap-3 bg-black text-white px-4 py-2.5 rounded-lg border border-white/10 shadow-sm"
                aria-label="Download on App Store"
                style={{ minWidth: 156, height: 48 }}
              >
                <AppleLogo className="w-6 h-6 text-white shrink-0" />
                <div className="text-left flex flex-col justify-center">
                  <span className="font-sans text-[8px] uppercase tracking-wider font-semibold text-white/70 leading-none">Download on the</span>
                  <span className="font-sans font-bold text-[15px] text-white leading-tight mt-0.5">App Store</span>
                </div>
              </motion.button>

              {/* Google Play Badge */}
              <motion.button
                whileHover={{ scale: 1.04, y: -1 }}
                whileTap={{ scale: 0.98 }}
                onClick={() => addToast('Google Play launch coming soon')}
                className="flex items-center gap-3 bg-black text-white px-4 py-2.5 rounded-lg border border-white/10 shadow-sm"
                aria-label="Get it on Google Play"
                style={{ minWidth: 156, height: 48 }}
              >
                <PlayStoreLogo className="w-5 h-5 text-white shrink-0" />
                <div className="text-left flex flex-col justify-center">
                  <span className="font-sans text-[8px] uppercase tracking-wider font-semibold text-white/70 leading-none">GET IT ON</span>
                  <span className="font-sans font-bold text-[14px] text-white leading-tight mt-0.5">Google Play</span>
                </div>
              </motion.button>
            </motion.div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default AppTeaser;
