import React, { useState } from 'react';
import { motion } from 'framer-motion';

interface HeroProps {
  openBookingModal: (name: string) => void;
  showToast: (msg: string) => void;
}

const Hero: React.FC<HeroProps> = ({ openBookingModal, showToast }) => {
  const [pickup, setPickup] = useState('Dubai — Downtown Hub');
  const [pickupDate, setPickupDate] = useState('2026-07-05');
  const [returnDate, setReturnDate] = useState('2026-07-08');
  const [vehicleType, setVehicleType] = useState('Sport Coupe · 2');

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    document.getElementById('fleet')?.scrollIntoView({ behavior: 'smooth' });
    showToast(`Showing available cars at ${pickup}`);
  };

  return (
    <section id="top" className="relative min-h-[90vh] flex flex-col justify-end px-8 pb-16 overflow-hidden">
      {/* Background Image Panel */}
      <div className="absolute inset-0 z-0">
        <div 
          className="w-full h-full bg-[url('https://images.pexels.com/photos/19292946/pexels-photo-19292946.jpeg?auto=compress&cs=tinysrgb&w=1800')] bg-cover bg-center"
          style={{ filter: 'grayscale(0.1) brightness(0.65)' }}
        />
        {/* Soft elegant gradient overlay */}
        <div className="absolute inset-0 bg-gradient-to-t from-background via-black/20 to-black/40" />
      </div>

      <div className="relative z-10 max-w-7xl mx-auto w-full flex flex-col gap-12">
        <div className="flex flex-col lg:flex-row justify-between items-end gap-8">
          <div className="flex flex-col">
            <span className="eyebrow mb-4">Drive beyond the ordinary</span>
            <h1 className="text-4xl sm:text-6xl lg:text-[80px] font-bold font-display leading-[0.95] text-white max-w-4xl">
              Elevate Your UAE <br/><span className="italic font-light text-primary-dim">Driving Journey</span>
            </h1>
          </div>
          <p className="text-gray-300 text-[15px] max-w-xs leading-relaxed">
            VANTA pairs an obsessively curated luxury fleet with a booking experience engineered for detail — every reservation confirmed in under ninety seconds.
          </p>
        </div>

        {/* Quick Booking Widget */}
        <form onSubmit={handleSearch} className="bg-panel/95 border border-border p-6 rounded-l shadow-2xl grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-6 items-center">
          <div className="flex flex-col border-b sm:border-b-0 sm:border-r border-border pb-4 sm:pb-0 sm:pr-4">
            <label className="font-mono text-[10px] uppercase text-text-muted mb-2">Pick-up Location</label>
            <select 
              value={pickup} 
              onChange={e => setPickup(e.target.value)} 
              className="bg-transparent text-text-heading font-medium text-sm focus:outline-none cursor-pointer"
            >
              <option value="Dubai — Downtown Hub">Dubai — Downtown Hub</option>
              <option value="Dubai Airport — DXB Terminal 3">Dubai Airport — DXB Terminal 3</option>
              <option value="Abu Dhabi — Yas Marina Studio">Abu Dhabi — Yas Marina Studio</option>
              <option value="Sharjah — City Center Plaza">Sharjah — City Center Plaza</option>
            </select>
          </div>

          <div className="flex flex-col border-b sm:border-b-0 sm:border-r border-border pb-4 sm:pb-0 sm:pr-4">
            <label className="font-mono text-[10px] uppercase text-text-muted mb-2">Pick-up Date</label>
            <input 
              type="date" 
              value={pickupDate}
              onChange={e => setPickupDate(e.target.value)}
              className="bg-transparent text-text-heading font-medium text-sm focus:outline-none"
            />
          </div>

          <div className="flex flex-col border-b sm:border-b-0 sm:border-r border-border pb-4 sm:pb-0 sm:pr-4">
            <label className="font-mono text-[10px] uppercase text-text-muted mb-2">Return Date</label>
            <input 
              type="date" 
              value={returnDate}
              onChange={e => setReturnDate(e.target.value)}
              className="bg-transparent text-text-heading font-medium text-sm focus:outline-none"
            />
          </div>

          <div className="flex flex-col border-b sm:border-b-0 sm:border-r border-border pb-4 sm:pb-0 sm:pr-4">
            <label className="font-mono text-[10px] uppercase text-text-muted mb-2">Vehicle Category</label>
            <select 
              value={vehicleType} 
              onChange={e => setVehicleType(e.target.value)} 
              className="bg-transparent text-text-heading font-medium text-sm focus:outline-none cursor-pointer"
            >
              <option value="Sport Coupe · 2">Sport Coupe · 2</option>
              <option value="Executive Sedan · 4">Executive Sedan · 4</option>
              <option value="Performance SUV · 5">Performance SUV · 5</option>
              <option value="Electric GT · 4">Electric GT · 4</option>
            </select>
          </div>

          <button 
            type="submit" 
            className="w-full h-full bg-primary hover:bg-primary-dim text-white font-semibold py-4 rounded-[12px] flex items-center justify-center gap-2 transition-colors shadow-md"
          >
            Find a Vantage
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4"><path d="M5 12h14M13 6l6 6-6 6"/></svg>
          </button>
        </form>

        {/* Stats */}
        <div className="flex flex-wrap gap-8 sm:gap-16">
          <div className="flex flex-col">
            <span className="font-display font-bold text-3xl sm:text-4xl text-white">248</span>
            <span className="font-mono text-[10px] uppercase text-gray-400">Vehicles in UAE</span>
          </div>
          <div className="flex flex-col">
            <span className="font-display font-bold text-3xl sm:text-4xl text-white">12</span>
            <span className="font-mono text-[10px] uppercase text-gray-400">Emirates Stations</span>
          </div>
          <div className="flex flex-col">
            <span className="font-display font-bold text-3xl sm:text-4xl text-white">99.8%</span>
            <span className="font-mono text-[10px] uppercase text-gray-400">On-time Delivery</span>
          </div>
          <div className="flex flex-col">
            <span className="font-display font-bold text-3xl sm:text-4xl text-white">18k+</span>
            <span className="font-mono text-[10px] uppercase text-gray-400">Members</span>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Hero;
