import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Menu, X, BarChart2, User } from 'lucide-react';
import { useAppStore } from '../../store';
import { ease, duration } from '../../lib/easing';
import { cn } from '../../lib/cn';

import falconLogo from '../../../assets/falconviewLogotrans.png';
export { falconLogo };

const NAV_LINKS = [
  { label: 'Fleet',        href: '#fleet' },
  { label: 'How it works', href: '#how-it-works' },
  { label: 'FAQ',          href: '#faq' },
  { label: 'Contact',      href: '#contact' },
] as const;

const Navbar: React.FC = () => {
  const [isScrolled, setIsScrolled] = useState(false);
  const [activeLink, setActiveLink] = useState('');
  const [mobileOpen, setMobileOpen] = useState(false);
  const { compareList, setCompareOpen, setCmdkOpen } = useAppStore();

  useEffect(() => {
    const handleScroll = () => setIsScrolled(window.scrollY > 60);
    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  useEffect(() => {
    if (window.innerWidth >= 768) setMobileOpen(false);
  }, []);

  const handleNavClick = (href: string) => {
    setActiveLink(href);
    setMobileOpen(false);
    document.querySelector(href)?.scrollIntoView({ behavior: 'smooth' });
  };

  /* Text color is permanently dark theme styled (white on dark background) */
  const linkColor = 'text-white/75 hover:text-white';
  const iconColor = 'text-white/60 hover:text-white border-white/20 hover:border-orange-400';

  return (
    <>
      {/* ── Floating pill navbar ────────────────────────────────────── */}
      <motion.header
        initial={{ x: "-50%", y: -60, opacity: 0 }}
        animate={{ x: "-50%", y: 0, opacity: 1 }}
        transition={{ duration: duration.cinematic, ease: ease.elegant }}
        className="fixed top-3 left-1/2 z-[900]"
        role="banner"
      >
        <div
          className={cn(
            'flex items-center justify-between pl-3 pr-4 py-3 rounded-full transition-all duration-500 w-[680px] md:w-[860px] lg:w-[1000px] max-w-[95vw] border border-subtle bg-surface-glass backdrop-blur-[24px] saturate-[180%]',
            isScrolled ? 'shadow-card-md' : 'shadow-none'
          )}
        >
          {/* ── Logo Only (Wings cropped) ── */}
          <motion.a
            href="#top"
            onClick={(e) => { e.preventDefault(); handleNavClick('#top'); }}
            className="shrink-0 flex items-center justify-center"
            whileHover={{ scale: 1.08 }}
            aria-label="Falcon View home"
          >
            <div className="flex items-center justify-center py-1" style={{ width: 135, height: 48 }}>
              <img
                src={falconLogo}
                alt="Falcon View Logo"
                className="w-full h-full object-contain"
              />
            </div>
          </motion.a>

          {/* ── Desktop nav ── */}
          <nav className="hidden md:flex items-center gap-2 mx-4" role="navigation">
            {NAV_LINKS.map((link) => (
              <button
                key={link.href}
                onClick={() => handleNavClick(link.href)}
                className={cn(
                  'relative px-5 py-2.5 font-grotesk text-body-sm tracking-wide font-medium rounded-full transition-all duration-300',
                  linkColor,
                  activeLink === link.href && 'text-white'
                )}
              >
                <span className="relative z-10">{link.label}</span>
                {activeLink === link.href && (
                  <motion.span
                    layoutId="pill-indicator"
                    className="absolute inset-0 rounded-full bg-accent-orange/15"
                    transition={{ type: 'spring', stiffness: 350, damping: 30 }}
                  />
                )}
              </button>
            ))}
          </nav>

          {/* ── Actions ── */}
          <div className="hidden md:flex items-center gap-1.5">
            <button
              onClick={() => setCmdkOpen(true)}
              className={cn('w-10 h-10 rounded-full border flex items-center justify-center transition-all duration-300', iconColor)}
              aria-label="Search"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
              </svg>
            </button>

            <button
              onClick={() => setCompareOpen(true)}
              className={cn('relative w-10 h-10 rounded-full border flex items-center justify-center transition-all duration-300', iconColor)}
              aria-label={`Compare (${compareList.length})`}
            >
              <BarChart2 size={16} />
              <AnimatePresence>
                {compareList.length > 0 && (
                  <motion.span
                    initial={{ scale: 0 }} animate={{ scale: 1 }} exit={{ scale: 0 }}
                    className="absolute -top-1 -right-1 w-4 h-4 bg-accent-orange text-white text-[9px] font-bold rounded-full flex items-center justify-center shadow-amber-glow"
                  >
                    {compareList.length}
                  </motion.span>
                )}
              </AnimatePresence>
            </button>

            <button
              className={cn('w-10 h-10 rounded-full border flex items-center justify-center transition-all duration-300', iconColor)}
              aria-label="Account"
            >
              <User size={16} />
            </button>

            <motion.button
              whileHover={{ scale: 1.02, y: -2 }}
              whileTap={{ scale: 0.98 }}
              onClick={() => handleNavClick('#fleet')}
              className="bg-accent-orange hover:bg-orange-400 text-white font-grotesk font-semibold text-body-sm px-6 py-3 rounded-full transition-colors shadow-amber-sm hover:shadow-amber-glow ml-2"
            >
              Book now
            </motion.button>
          </div>

          {/* ── Mobile toggle ── */}
          <button
            className={cn('md:hidden w-9 h-9 rounded-full border flex items-center justify-center ml-auto transition-all', iconColor)}
            onClick={() => setMobileOpen((v) => !v)}
            aria-expanded={mobileOpen}
            aria-label="Toggle menu"
          >
            <AnimatePresence mode="wait">
              {mobileOpen
                ? <motion.span key="x" initial={{ rotate: -90, opacity: 0 }} animate={{ rotate: 0, opacity: 1 }} exit={{ rotate: 90, opacity: 0 }} transition={{ duration: 0.2 }}><X size={15}/></motion.span>
                : <motion.span key="m" initial={{ rotate: 90, opacity: 0 }} animate={{ rotate: 0, opacity: 1 }} exit={{ rotate: -90, opacity: 0 }} transition={{ duration: 0.2 }}><Menu size={15}/></motion.span>
              }
            </AnimatePresence>
          </button>
        </div>
      </motion.header>

      {/* ── Mobile full-screen menu ── */}
      <AnimatePresence>
        {mobileOpen && (
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.3, ease: ease.snap }}
            className="fixed inset-0 z-[850] bg-vanta-paper flex flex-col"
            role="dialog"
            aria-label="Mobile navigation"
          >
            <div className="flex-1 flex flex-col justify-center px-8 gap-2 pt-20">
              {NAV_LINKS.map((link, i) => (
                <motion.button
                  key={link.href}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: i * 0.07, duration: 0.4, ease: ease.elegant }}
                  onClick={() => handleNavClick(link.href)}
                  className="text-left py-4 font-display text-4xl font-light text-vanta-ink border-b border-vanta-border hover:text-orange-500 transition-colors"
                >
                  {link.label}
                </motion.button>
              ))}
            </div>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.4 }}
              className="px-8 pb-10 flex gap-3"
            >
              <button
                className="bg-orange-500 hover:bg-orange-400 text-white font-grotesk font-bold text-[15px] px-6 py-3.5 rounded-full flex-1 transition-colors"
                onClick={() => handleNavClick('#fleet')}
              >
                Book now
              </button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
};

export default Navbar;
