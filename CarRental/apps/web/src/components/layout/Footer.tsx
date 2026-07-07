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
    <footer id="contact" className="bg-surface-primary text-text-primary border-t border-subtle" role="contentinfo">
      {/* Newsletter Bar */}
      <div className="border-b border-subtle">
        <div className="section-container py-16">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-center">
            <div>
              <h3 className="font-grotesk font-bold text-heading-1 text-text-primary mb-2">
                Stay in the <span className="text-accent-orange">fast lane.</span>
              </h3>
              <p className="text-text-secondary text-body-md">New arrivals, exclusive deals, and UAE driving tips — delivered monthly.</p>
            </div>
            <form onSubmit={handleNewsletter} className="flex gap-2">
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your@email.com"
                required
                className="flex-1 bg-surface-glass border border-subtle rounded-xl px-5 py-4 text-text-primary text-body-md font-sans placeholder:text-text-subtle focus:outline-none focus:border-accent-orange transition-colors"
                aria-label="Email for newsletter"
              />
              <motion.button
                type="submit"
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.97 }}
                className="bg-accent-orange text-white px-8 py-4 rounded-xl font-grotesk font-semibold text-body-md flex items-center gap-2 hover:bg-orange-400 transition-colors whitespace-nowrap shadow-amber-sm hover:shadow-amber-glow"
              >
                {submitted ? 'Subscribed ✓' : (<>Subscribe <ArrowRight size={16} /></>)}
              </motion.button>
            </form>
          </div>
        </div>
      </div>

      {/* Main Footer */}
      <div className="section-container py-24">
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-12 mb-20">
          {/* Brand */}
          <div className="col-span-2 md:col-span-3 lg:col-span-1">
            <a href="#top" className="flex items-center gap-2 mb-6">
              <img
                src={falconLogo}
                alt="Falcon View Car Rentals"
                className="h-16 w-auto object-contain rounded-lg"
              />
            </a>
            <p className="text-text-secondary text-body-sm leading-relaxed mb-3">
              Falcon View Car Rentals L.L.C
            </p>
            <p className="text-text-subtle text-body-sm leading-relaxed mb-3 font-sans" dir="rtl">
              فالكون فيو لتأجير السيارات ش.ذ.م.م
            </p>
            <p className="text-text-subtle text-caption leading-relaxed mb-8">
              M01-0362, Unique Business World,<br />
              Al Karama, Dubai. PO Box 9040
            </p>
            {/* Social + WhatsApp */}
            <div className="flex gap-3">
              <motion.button
                onClick={handleWhatsApp}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="flex items-center gap-2 px-4 py-2.5 rounded-lg bg-green-500/10 border border-green-500/30 text-green-400 text-body-sm font-medium hover:bg-green-500/20 transition-colors"
                aria-label="WhatsApp"
              >
                <MessageCircle size={16} />
                WhatsApp
              </motion.button>
              <a
                href="https://instagram.com"
                target="_blank"
                rel="noopener noreferrer"
                aria-label="Instagram"
                className="w-10 h-10 rounded-lg border border-subtle flex items-center justify-center text-text-subtle hover:text-accent-orange hover:border-accent-orange/40 transition-all"
              >
                <Globe size={16} />
              </a>
              <a
                href="https://wa.me/971500999733"
                target="_blank"
                rel="noopener noreferrer"
                aria-label="Website"
                className="w-10 h-10 rounded-lg border border-subtle flex items-center justify-center text-text-subtle hover:text-accent-orange hover:border-accent-orange/40 transition-all"
              >
                <Globe size={16} />
              </a>
            </div>
          </div>

          {/* Link columns */}
          {Object.entries(FOOTER_LINKS).map(([heading, links]) => (
            <div key={heading}>
              <h4 className="font-mono text-label uppercase text-text-subtle mb-6">{heading}</h4>
              <ul className="flex flex-col gap-4">
                {links.map((link) => (
                  <li key={link}>
                    <a
                      href="#"
                      onClick={(e) => e.preventDefault()}
                      className="text-text-secondary text-body-sm hover:text-accent-orange transition-colors font-sans"
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
        <div className="border-t border-subtle pt-10 flex flex-col md:flex-row justify-between gap-8 items-start md:items-center">
          <div className="flex flex-wrap gap-8">
            {[
              { icon: MapPin, text: 'Al Karama, Dubai, PO Box 9040' },
              { icon: Phone, text: '+971 50 099 9733' },
              { icon: Mail,  text: 'sales@falconviewcarrentals.com' },
              { icon: Globe, text: 'www.falconviewcarrentals.com' },
            ].map(({ icon: Icon, text }) => (
              <div key={text} className="flex items-center gap-2 text-text-subtle text-caption">
                <Icon size={14} className="text-accent-orange shrink-0" />
                <span>{text}</span>
              </div>
            ))}
          </div>

          <div className="flex flex-wrap gap-6 text-text-subtle text-caption font-mono">
            <a href="#" className="hover:text-text-primary transition-colors">Privacy Policy</a>
            <a href="#" className="hover:text-text-primary transition-colors">Terms of Service</a>
            <a href="#" className="hover:text-text-primary transition-colors">Cookie Policy</a>
            <span>© 2026 Falcon View Car Rentals L.L.C</span>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
