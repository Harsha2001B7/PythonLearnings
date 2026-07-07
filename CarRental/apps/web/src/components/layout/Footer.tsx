import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { ArrowRight, MapPin, Phone, Mail, Globe, MessageCircle } from 'lucide-react';
import { useToastStore } from '../../store';
import { falconLogo } from './Navbar';

const FOOTER_LINKS = {
  Fleet: ['Sedans', 'Hatchbacks', 'Compact SUVs', '7-Seaters', 'Muscle Cars'],
  Services: ['Daily Rental', 'Weekly Rental', 'Monthly Rental', 'With Driver', 'Airport Pick-up'],
  Company: ['About Falcon View', 'Careers', 'Press & Media', 'Partner with Us', 'Oman Border Pass'],
  Support: ['WhatsApp Us', 'Booking FAQ', 'Insurance Info', 'Contact', 'T&Cs'],
};

const Footer: React.FC = () => {
  const [email, setEmail] = useState('');
  const [submitted, setSubmitted] = useState(false);
  const { addToast } = useToastStore();

  const handleNewsletter = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim()) return;
    setSubmitted(true);
    addToast("You're on the list — welcome to Falcon View.");
    setTimeout(() => { setSubmitted(false); setEmail(''); }, 4000);
  };

  const handleWhatsApp = () => {
    window.open('https://wa.me/971500999733?text=Hi%20Falcon%20View%2C%20I%20have%20a%20question', '_blank');
  };

  return (
    <footer id="contact" className="bg-[#080808] text-white border-t border-vanta-border" role="contentinfo">
      {/* Newsletter Bar */}
      <div className="border-b border-white/8">
        <div className="section-container py-12">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-center">
            <div>
              <h3 className="font-grotesk font-bold text-2xl text-white mb-1">
                Stay in the <span className="text-vanta-amber">fast lane.</span>
              </h3>
              <p className="text-white/40 text-[13px]">New arrivals, exclusive deals, and UAE driving tips — delivered monthly.</p>
            </div>
            <form onSubmit={handleNewsletter} className="flex gap-2">
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your@email.com"
                required
                className="flex-1 bg-white/6 border border-white/15 rounded-xl px-4 py-3 text-white text-[14px] font-sans placeholder:text-white/25 focus:outline-none focus:border-vanta-amber transition-colors"
                aria-label="Email for newsletter"
              />
              <motion.button
                type="submit"
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.97 }}
                className="bg-vanta-amber text-white px-5 py-3 rounded-xl font-grotesk font-semibold text-[13px] flex items-center gap-2 hover:bg-vanta-amber-light transition-colors whitespace-nowrap"
              >
                {submitted ? 'Subscribed ✓' : (<>Subscribe <ArrowRight size={13} /></>)}
              </motion.button>
            </form>
          </div>
        </div>
      </div>

      {/* Main Footer */}
      <div className="section-container py-16">
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-10 mb-16">
          {/* Brand */}
          <div className="col-span-2 md:col-span-3 lg:col-span-1">
            <a href="#top" className="flex items-center gap-2 mb-4">
              <img
                src={falconLogo}
                alt="Falcon View Car Rentals"
                className="h-16 w-auto object-contain rounded-lg"
              />
            </a>
            <p className="text-white/40 text-[12px] leading-relaxed mb-3">
              Falcon View Car Rentals L.L.C
            </p>
            <p className="text-white/25 text-[12px] leading-relaxed mb-2 font-sans" dir="rtl">
              فالكون فيو لتأجير السيارات ش.ذ.م.م
            </p>
            <p className="text-white/25 text-[11px] leading-relaxed mb-6">
              M01-0362, Unique Business World,<br />
              Al Karama, Dubai. PO Box 9040
            </p>
            {/* Social + WhatsApp */}
            <div className="flex gap-2.5">
              <motion.button
                onClick={handleWhatsApp}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-green-500/10 border border-green-500/30 text-green-400 text-[12px] font-medium hover:bg-green-500/20 transition-colors"
                aria-label="WhatsApp"
              >
                <MessageCircle size={13} />
                WhatsApp
              </motion.button>
              <a
                href="https://instagram.com"
                target="_blank"
                rel="noopener noreferrer"
                aria-label="Instagram"
                className="w-9 h-9 rounded-lg border border-white/10 flex items-center justify-center text-white/30 hover:text-vanta-amber hover:border-vanta-amber/40 transition-all"
              >
                <Globe size={14} />
              </a>
              <a
                href="https://wa.me/971500999733"
                target="_blank"
                rel="noopener noreferrer"
                aria-label="Website"
                className="w-9 h-9 rounded-lg border border-white/10 flex items-center justify-center text-white/30 hover:text-vanta-amber hover:border-vanta-amber/40 transition-all"
              >
                <Globe size={14} />
              </a>
            </div>
          </div>

          {/* Link columns */}
          {Object.entries(FOOTER_LINKS).map(([heading, links]) => (
            <div key={heading}>
              <h4 className="font-mono text-[10px] uppercase tracking-[0.2em] text-white/30 mb-5">{heading}</h4>
              <ul className="flex flex-col gap-3">
                {links.map((link) => (
                  <li key={link}>
                    <a
                      href="#"
                      onClick={(e) => e.preventDefault()}
                      className="text-white/45 text-[13px] hover:text-vanta-amber transition-colors font-sans"
                    >
                      {link}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        {/* Contact + Legal */}
        <div className="border-t border-white/8 pt-8 flex flex-col md:flex-row justify-between gap-6 items-start md:items-center">
          <div className="flex flex-wrap gap-6">
            {[
              { icon: MapPin, text: 'Al Karama, Dubai, PO Box 9040' },
              { icon: Phone, text: '+971 50 099 9733' },
              { icon: Mail,  text: 'sales@falconviewcarrentals.com' },
              { icon: Globe, text: 'www.falconviewcarrentals.com' },
            ].map(({ icon: Icon, text }) => (
              <div key={text} className="flex items-center gap-2 text-white/35 text-[12px]">
                <Icon size={12} className="text-vanta-amber shrink-0" />
                <span>{text}</span>
              </div>
            ))}
          </div>

          <div className="flex flex-wrap gap-5 text-white/25 text-[11px] font-mono">
            <a href="#" className="hover:text-white/60 transition-colors">Privacy Policy</a>
            <a href="#" className="hover:text-white/60 transition-colors">Terms of Service</a>
            <a href="#" className="hover:text-white/60 transition-colors">Cookie Policy</a>
            <span>© 2026 Falcon View Car Rentals L.L.C</span>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
