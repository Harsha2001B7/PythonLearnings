import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { ArrowRight, MapPin, Phone, Mail, Globe, MessageCircle, ExternalLink } from 'lucide-react';
import { useToastStore } from '../../store';
import { falconLogo } from './Navbar';
import instagramLogo from '../../../assets/instagramlogo.svg';
import whatsappLogo from '../../../assets/whatsapplogo.svg';

import { openWhatsApp } from '../../utils/whatsapp';

const Footer: React.FC = () => {
  const [email, setEmail] = useState('');
  const [submitted, setSubmitted] = useState(false);
  const { addToast } = useToastStore();
  const navigate = useNavigate();

  const handleNewsletter = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim()) return;
    setSubmitted(true);
    addToast("You're on the list — welcome to Falcon View.");
    setTimeout(() => { setSubmitted(false); setEmail(''); }, 4000);
  };

  const handleWhatsApp = () => {
    openWhatsApp('Hi Falcon View, I have a question');
  };

  const scrollTo = (id: string) => {
    const el = document.getElementById(id);
    if (el) el.scrollIntoView({ behavior: 'smooth' });
  };

  const FOOTER_LINKS = {
    Fleet: [
      { label: 'Sedans', action: () => navigate('/fleet?category=sedan') },
      { label: 'Hatchbacks', action: () => navigate('/fleet?category=hatchback') },
      { label: 'Compact SUVs', action: () => navigate('/fleet?category=suv') },
      { label: '7-Seaters', action: () => navigate('/fleet?category=7seater') },
      { label: 'Muscle Cars', action: () => navigate('/fleet?category=coupe') },
    ],
    Services: [
      { label: 'Daily Rental', action: () => navigate('/fleet') },
      { label: 'Weekly Rental', action: () => navigate('/fleet') },
      { label: 'Monthly Rental', action: () => navigate('/fleet') },
      { label: 'Airport Pick-up', action: () => handleWhatsApp() },
      { label: 'Free Delivery', action: () => scrollTo('how-it-works') },
    ],
    Company: [
      { label: 'About Falcon View', action: () => scrollTo('why') },
      { label: 'Oman Border Pass', action: () => handleWhatsApp() },
      { label: 'Partner with Us', action: () => window.open('mailto:sales@falconviewcarrentals.com', '_blank') },
      { label: 'Press & Media', action: () => window.open('mailto:sales@falconviewcarrentals.com', '_blank') },
    ],
    Support: [
      { label: 'WhatsApp Us', action: () => handleWhatsApp() },
      { label: 'Booking FAQ', action: () => scrollTo('faq') },
      { label: 'Insurance Info', action: () => scrollTo('faq') },
      { label: 'Contact', action: () => scrollTo('contact') },
      { label: 'T&Cs', action: () => handleWhatsApp() },
    ],
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
            <button onClick={() => navigate('/')} className="flex items-center gap-2 mb-6">
              <img src={falconLogo} alt="Falcon View Car Rentals" className="h-16 w-auto object-contain rounded-lg" />
            </button>
            <p className="text-text-secondary text-body-sm leading-relaxed mb-3">
              Falcon View Car Rentals L.L.C
            </p>
            <p className="text-text-subtle text-body-sm leading-relaxed mb-3 font-sans" dir="rtl">
              فالكون فيو لتأجير السيارات ش.ذ.م.م
            </p>
            <p className="text-text-subtle text-caption leading-relaxed mb-4">
              Ansar Gallery Building, Hamsah-A Building<br />
              87556 3A St, Al Karama, Dubai, UAE
            </p>
            <div className="w-full h-32 rounded-xl overflow-hidden border border-white/[0.08] mb-6">
              <iframe
                title="Office Location Map"
                src="https://maps.google.com/maps?q=Ansar%20Gallery%20Building,%20Hamsah-A%20Building%20-%2087556%203A%20St%20-%20Al%20Karama%20-%20Dubai%20-%20United%20Arab%20Emirates&t=&z=14&ie=UTF8&iwloc=&output=embed"
                width="100%"
                height="100%"
                style={{ border: 0, filter: 'grayscale(1) invert(0.9) contrast(1.2)' }}
                allowFullScreen={false}
                loading="lazy"
              ></iframe>
            </div>
            {/* Social + WhatsApp */}
            <div className="flex items-center gap-4">
              <motion.button
                onClick={handleWhatsApp}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="flex items-center gap-2 px-4 py-2.5 rounded-lg bg-green-500/10 border border-green-500/30 text-green-400 text-body-sm font-medium hover:bg-green-500/20 transition-colors"
                aria-label="WhatsApp"
              >
                <img src={whatsappLogo} className="w-4 h-4 object-contain" alt="" />
                WhatsApp
              </motion.button>
              <a
                href="https://instagram.com/falconviewcarrentals"
                target="_blank"
                rel="noopener noreferrer"
                aria-label="Instagram"
                className="flex items-center justify-center hover:opacity-80 transition-opacity"
              >
                <img src={instagramLogo} className="w-6 h-6 object-contain" alt="" />
              </a>
            </div>
          </div>

          {/* Link columns */}
          {Object.entries(FOOTER_LINKS).map(([heading, links]) => (
            <div key={heading}>
              <h4 className="font-mono text-label uppercase text-text-subtle mb-6">{heading}</h4>
              <ul className="flex flex-col gap-4">
                {links.map((link) => (
                  <li key={link.label}>
                    <button
                      onClick={link.action}
                      className="text-text-secondary text-body-sm hover:text-accent-orange transition-colors font-sans text-left"
                    >
                      {link.label}
                    </button>
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
              { icon: MapPin, text: 'Ansar Gallery Building, Al Karama, Dubai', href: 'https://share.google/tlEqLM8WjwUwnpm1z' },
              { icon: Phone, text: '+971 50 099 9733', href: 'tel:+971500999733' },
              { icon: Mail, text: 'sales@falconviewcarrentals.com', href: 'mailto:sales@falconviewcarrentals.com' },
              { icon: Globe, text: 'www.falconviewcarrentals.com', href: 'https://www.falconviewcarrentals.com' },
            ].map(({ icon: Icon, text, href }) => (
              <a key={text} href={href} target="_blank" rel="noopener noreferrer" className="flex items-center gap-2 text-text-subtle text-caption hover:text-accent-orange transition-colors">
                <Icon size={14} className="text-accent-orange shrink-0" />
                <span>{text}</span>
              </a>
            ))}
          </div>

          <div className="flex flex-wrap gap-6 text-text-subtle text-caption font-mono">
            <button onClick={() => handleWhatsApp()} className="hover:text-text-primary transition-colors">Privacy Policy</button>
            <button onClick={() => handleWhatsApp()} className="hover:text-text-primary transition-colors">Terms of Service</button>
            <button onClick={() => handleWhatsApp()} className="hover:text-text-primary transition-colors">Cookie Policy</button>
            <span>© 2026 Falcon View Car Rentals L.L.C</span>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
