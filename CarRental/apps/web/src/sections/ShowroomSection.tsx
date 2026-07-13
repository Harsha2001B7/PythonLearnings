import { MapPin, Phone, Clock, Navigation2, MessageCircle } from 'lucide-react';
import { motion } from 'framer-motion';
import { getWhatsAppUrl } from '../utils/whatsapp';

const ShowroomSection: React.FC = () => {
  return (
    <section className="py-12 relative overflow-hidden">
      {/* Decorative gradient */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute right-0 bottom-0 w-96 h-96 bg-vanta-amber/5 rounded-full blur-[100px]" />
      </div>

      <div className="max-w-7xl mx-auto px-4 md:px-8 relative z-10">
        <motion.div 
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.6 }}
          className="flex flex-col lg:flex-row gap-12 lg:gap-16"
        >
          <div className="lg:w-[65%] shrink-0 flex flex-col justify-center">
            <h2 className="font-grotesk text-3xl md:text-5xl font-bold text-gray-900 mb-2">
              Visit Our Showroom
            </h2>
            <p className="text-vanta-amber font-mono text-sm tracking-widest uppercase mb-10">
              Luxury Car Rentals in Dubai
            </p>

            <div className="space-y-8">
              {/* Office Details */}
              <div className="flex items-start gap-4">
                <div className="w-10 h-10 rounded-full bg-gray-100 border border-gray-200 flex items-center justify-center shrink-0">
                  <MapPin className="text-vanta-amber" size={20} />
                </div>
                <div>
                  <h3 className="font-bold text-gray-900 text-lg mb-2">Falcon View Car Rentals LLC</h3>
                  <p className="text-gray-600 leading-relaxed">
                    Unique World Business Center – M01-0362<br />
                    Khalid Bin Al Waleed Road<br />
                    Al Karama<br />
                    Dubai<br />
                    United Arab Emirates
                  </p>
                </div>
              </div>

              {/* Working Hours */}
              <div className="flex items-start gap-4">
                <div className="w-10 h-10 rounded-full bg-gray-100 border border-gray-200 flex items-center justify-center shrink-0">
                  <Clock className="text-vanta-amber" size={20} />
                </div>
                <div>
                  <h3 className="font-bold text-gray-900 text-lg mb-1">Working Hours</h3>
                  <p className="text-gray-600">
                    Open Daily<br />
                    9:00 AM – 10:00 PM
                  </p>
                </div>
              </div>

              {/* Phone */}
              <div className="flex items-start gap-4">
                <div className="w-10 h-10 rounded-full bg-gray-100 border border-gray-200 flex items-center justify-center shrink-0">
                  <Phone className="text-vanta-amber" size={20} />
                </div>
                <div>
                  <h3 className="font-bold text-gray-900 text-lg mb-1">Phone</h3>
                  <p className="text-gray-600">+971 50 099 9733</p>
                </div>
              </div>
            </div>

            {/* Actions */}
            <div className="mt-10 flex flex-col sm:flex-row gap-4">
              <a 
                href="https://maps.google.com/?q=Falcon+View+Car+Rentals+LLC"
                target="_blank"
                rel="noopener noreferrer"
                className="group flex-1 flex items-center justify-center gap-2 px-6 py-4 bg-gray-900 text-white font-grotesk font-semibold rounded-xl hover:bg-gray-800 transition-colors"
              >
                <Navigation2 size={18} />
                Get Directions
              </a>
              <a
                href={getWhatsAppUrl("Hi Falcon View, I'd like to visit your showroom")}
                target="_blank"
                rel="noopener noreferrer"
                className="group flex-1 flex items-center justify-center gap-2 px-6 py-4 bg-transparent border border-vanta-amber text-vanta-amber font-grotesk font-semibold rounded-xl hover:bg-vanta-amber/10 transition-colors"
              >
                <MessageCircle size={18} />
                WhatsApp Us
              </a>
            </div>
          </div>

          {/* Right Side: Map */}
          <div className="w-full lg:w-[35%] h-[300px] lg:h-[400px] rounded-[24px] overflow-hidden border-2 border-vanta-amber/30 shadow-[0_20px_50px_rgba(212,175,55,0.1)] group relative">
            {/* Interactive Cover for opening map when clicking the overlay (optional, but requested interactive map, so we just let the iframe handle it) */}
            <iframe 
              width="100%" 
              height="100%" 
              frameBorder="0" 
              scrolling="no" 
              marginHeight={0} 
              marginWidth={0} 
              src="https://maps.google.com/maps?width=100%25&amp;height=600&amp;hl=en&amp;q=Falcon%20View%20Car%20Rentals%20LLC&amp;t=&amp;z=15&amp;ie=UTF8&amp;iwloc=&amp;output=embed"
              title="Falcon View Showroom Map"
              className="w-full h-full transition-all duration-700 ease-in-out"
            ></iframe>
          </div>
        </motion.div>
      </div>
    </section>
  );
};

export default ShowroomSection;
