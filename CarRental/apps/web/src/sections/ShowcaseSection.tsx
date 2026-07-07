import React, { useRef, useEffect, Suspense, useState } from 'react';
import { motion } from 'framer-motion';
import { ease, duration } from '../lib/easing';
import { cn } from '../lib/cn';
import { usePrefersReducedMotion } from '../hooks/useMediaQuery';

// ── 3D Scene (lazy-loaded) ──────────────────────────────────────
const CarScene = React.lazy(() => import('../three/CarScene'));

// ── Color Swatches ──────────────────────────────────────────────
const SWATCHES = [
  { name: 'Obsidian', hex: '#1a1a1a' },
  { name: 'Glacier White', hex: '#f0f0ee' },
  { name: 'Amber Dusk', hex: '#C8873A' },
  { name: 'Midnight Blue', hex: '#1a2744' },
  { name: 'Racing Green', hex: '#1A4A2E' },
];

// ── Camera Angle Presets ────────────────────────────────────────
const CAMERA_ANGLES = [
  { id: 'front', label: 'Front', icon: '↑' },
  { id: 'side', label: 'Side', icon: '→' },
  { id: 'rear', label: 'Rear', icon: '↓' },
  { id: 'top', label: 'Top', icon: '⊙' },
] as const;

type CameraAngle = typeof CAMERA_ANGLES[number]['id'];

// ── Fallback for reduced-motion / low-end devices ───────────────
const ShowcaseFallback: React.FC = () => (
  <div className="w-full h-full flex items-center justify-center relative overflow-hidden">
    <img
      src="https://images.pexels.com/photos/20131973/pexels-photo-20131973.jpeg?auto=compress&cs=tinysrgb&w=1200"
      alt="VANTA Vantage GT showcase"
      className="w-full h-full object-cover"
    />
    <div className="absolute inset-0 bg-gradient-to-t from-black/30 to-transparent" />
    <span className="absolute bottom-4 left-1/2 -translate-x-1/2 font-mono text-[10px] text-white/60 uppercase tracking-[0.15em]">
      3D Viewer — Enable WebGL for interactive controls
    </span>
  </div>
);

// ── Loading Spinner ─────────────────────────────────────────────
const SceneLoader: React.FC = () => (
  <div className="w-full h-full flex flex-col items-center justify-center gap-4 bg-vanta-paper-soft">
    <div className="w-8 h-8 border-2 border-vanta-border border-t-vanta-amber rounded-full animate-spin" />
    <span className="font-mono text-[10px] uppercase tracking-[0.18em] text-vanta-ink-muted">Loading 3D Scene</span>
  </div>
);

// ── Main Showcase Section ───────────────────────────────────────
const ShowcaseSection: React.FC = () => {
  const [activeColor, setActiveColor] = useState(SWATCHES[0]);
  const [activeCameraAngle, setActiveCameraAngle] = useState<CameraAngle>('side');
  const reducedMotion = usePrefersReducedMotion();

  return (
    <section id="showcase" className="py-24 bg-vanta-paper overflow-hidden">
      <div className="section-container">
        {/* Header */}
        <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-6 mb-12">
          <div>
            <motion.div
              className="eyebrow mb-3"
              initial={{ opacity: 0, x: -16 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ duration: duration.slow, ease: ease.elegant }}
            >
              360° Vehicle Showcase
            </motion.div>
            <motion.h2
              className="font-display text-display-lg text-vanta-ink"
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.1 }}
            >
              Explore Every{' '}
              <span className="italic font-light text-vanta-amber">Angle.</span>
            </motion.h2>
            <motion.p
              className="text-vanta-ink-muted mt-3 max-w-md text-[15px] leading-relaxed"
              initial={{ opacity: 0, y: 16 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: duration.slow, ease: ease.elegant, delay: 0.2 }}
            >
              Drag to orbit. Click a swatch to change the exterior finish. Use the angle presets to jump to key views.
            </motion.p>
          </div>
        </div>

        {/* 3D Canvas + Controls */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: duration.cinematic, ease: ease.elegant }}
          className="grid grid-cols-1 lg:grid-cols-[1fr_240px] gap-6"
        >
          {/* Canvas */}
          <div className="relative h-[420px] sm:h-[520px] rounded-2xl overflow-hidden border border-vanta-border shadow-card-lg bg-vanta-paper-soft">
            {reducedMotion ? (
              <ShowcaseFallback />
            ) : (
              <Suspense fallback={<SceneLoader />}>
                <CarScene
                  color={activeColor.hex}
                  cameraAngle={activeCameraAngle}
                />
              </Suspense>
            )}

            {/* Drag Hint */}
            <motion.div
              className="absolute bottom-4 right-4 flex items-center gap-1.5 bg-white/80 backdrop-blur-sm px-3 py-1.5 rounded-full border border-vanta-border shadow-card-sm"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 1 }}
            >
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-vanta-ink-muted">
                <path d="M9 3H5a2 2 0 0 0-2 2v4m6-6h10a2 2 0 0 1 2 2v4M9 3v18m0 0h10a2 2 0 0 0 2-2V9M9 21H5a2 2 0 0 1-2-2V9m0 0h18"/>
              </svg>
              <span className="font-mono text-[9px] uppercase tracking-[0.12em] text-vanta-ink-muted">Drag to rotate</span>
            </motion.div>
          </div>

          {/* Controls Panel */}
          <div className="flex flex-col gap-6">
            {/* Color Swatches */}
            <div className="bg-vanta-panel border border-vanta-border rounded-2xl p-5">
              <h3 className="font-mono text-[10px] uppercase tracking-[0.18em] text-vanta-ink-subtle mb-4">Exterior Finish</h3>
              <div className="flex flex-col gap-2.5">
                {SWATCHES.map((swatch) => (
                  <motion.button
                    key={swatch.name}
                    whileHover={{ x: 3 }}
                    whileTap={{ scale: 0.97 }}
                    onClick={() => setActiveColor(swatch)}
                    className={cn(
                      'flex items-center gap-3 p-2.5 rounded-xl border transition-all duration-200',
                      activeColor.name === swatch.name
                        ? 'border-vanta-amber bg-vanta-amber-pale'
                        : 'border-transparent hover:border-vanta-border hover:bg-vanta-paper-soft'
                    )}
                    aria-pressed={activeColor.name === swatch.name}
                  >
                    <span
                      className="w-7 h-7 rounded-lg border border-black/10 shadow-card-sm shrink-0"
                      style={{ background: swatch.hex }}
                    />
                    <span className="font-grotesk text-[13px] text-vanta-ink font-medium">{swatch.name}</span>
                    {activeColor.name === swatch.name && (
                      <motion.span
                        layoutId="color-check"
                        className="ml-auto text-vanta-amber"
                        initial={{ scale: 0 }}
                        animate={{ scale: 1 }}
                      >
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                          <polyline points="20 6 9 17 4 12"/>
                        </svg>
                      </motion.span>
                    )}
                  </motion.button>
                ))}
              </div>
            </div>

            {/* Camera Angle Presets */}
            <div className="bg-vanta-panel border border-vanta-border rounded-2xl p-5">
              <h3 className="font-mono text-[10px] uppercase tracking-[0.18em] text-vanta-ink-subtle mb-4">Camera Angle</h3>
              <div className="grid grid-cols-2 gap-2">
                {CAMERA_ANGLES.map((angle) => (
                  <motion.button
                    key={angle.id}
                    whileHover={{ y: -2 }}
                    whileTap={{ scale: 0.95 }}
                    onClick={() => setActiveCameraAngle(angle.id)}
                    className={cn(
                      'flex flex-col items-center gap-1.5 py-3 rounded-xl border font-mono text-[10px] uppercase tracking-[0.1em] transition-all duration-200',
                      activeCameraAngle === angle.id
                        ? 'bg-vanta-amber border-vanta-amber text-white shadow-amber-sm'
                        : 'border-vanta-border text-vanta-ink-muted hover:border-vanta-amber/50'
                    )}
                    aria-pressed={activeCameraAngle === angle.id}
                  >
                    <span className="text-lg leading-none">{angle.icon}</span>
                    {angle.label}
                  </motion.button>
                ))}
              </div>
            </div>

            {/* CTA */}
            <motion.button
              whileHover={{ scale: 1.02, y: -1 }}
              whileTap={{ scale: 0.98 }}
              onClick={() => document.getElementById('fleet')?.scrollIntoView({ behavior: 'smooth' })}
              className="btn-amber text-sm w-full justify-center"
            >
              Book This Model
            </motion.button>
          </div>
        </motion.div>
      </div>
    </section>
  );
};

export default ShowcaseSection;
