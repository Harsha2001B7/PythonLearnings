// @ts-nocheck — Legacy component replaced by src/sections/FleetExplorer.tsx
import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Vehicle } from '../../types';

interface FleetExplorerProps {
  wishlist: number[];
  toggleWishlist: (id: number) => void;
  compareList: number[];
  toggleCompare: (id: number) => void;
  openBookingModal: (name: string) => void;
}

const FLEET_DATA: Vehicle[] = [
  {id:1,name:"Vantage GT",cat:"coupe",trans:"auto",fuel:"electric",seats:2,price:420,img:"https://images.pexels.com/photos/20131973/pexels-photo-20131973.jpeg?auto=compress&cs=tinysrgb&w=900",specs:["2 Seats","Auto","Electric","3.1s 0-60"]},
  {id:2,name:"Continental S",cat:"sedan",trans:"auto",fuel:"petrol",seats:4,price:310,img:"https://images.pexels.com/photos/29566862/pexels-photo-29566862.jpeg?auto=compress&cs=tinysrgb&w=900",specs:["4 Seats","Auto","Petrol V8"]},
  {id:3,name:"Ridgeline Sport",cat:"suv",trans:"auto",fuel:"hybrid",seats:5,price:280,img:"https://images.pexels.com/photos/5288744/pexels-photo-5288744.jpeg?auto=compress&cs=tinysrgb&w=900",specs:["5 Seats","Auto","Hybrid"]},
  {id:4,name:"Nocturne Coupe",cat:"coupe",trans:"manual",fuel:"petrol",seats:2,price:390,img:"https://images.pexels.com/photos/29851075/pexels-photo-29851075.jpeg?auto=compress&cs=tinysrgb&w=900",specs:["2 Seats","Manual","Petrol"]},
  {id:5,name:"Meridian EV",cat:"ev",trans:"auto",fuel:"electric",seats:5,price:340,img:"https://images.pexels.com/photos/26954166/pexels-photo-26954166.jpeg?auto=compress&cs=tinysrgb&w=900",specs:["5 Seats","Auto","Electric","410mi"]},
  {id:6,name:"Overland X7",cat:"suv",trans:"auto",fuel:"petrol",seats:7,price:260,img:"https://images.pexels.com/photos/32500672/pexels-photo-32500672.jpeg?auto=compress&cs=tinysrgb&w=900",specs:["7 Seats","Auto","Petrol"]},
  {id:7,name:"Aria Sedan",cat:"sedan",trans:"auto",fuel:"electric",seats:5,price:230,img:"https://images.pexels.com/photos/4141962/pexels-photo-4141962.jpeg?auto=compress&cs=tinysrgb&w=900",specs:["5 Seats","Auto","Electric"]},
  {id:8,name:"Solstice Roadster",cat:"coupe",trans:"manual",fuel:"petrol",seats:2,price:450,img:"https://images.pexels.com/photos/19240616/pexels-photo-19240616.jpeg?auto=compress&cs=tinysrgb&w=900",specs:["2 Seats","Manual","Petrol"]},
  {id:9,name:"Halcyon SUV",cat:"suv",trans:"auto",fuel:"hybrid",seats:5,price:245,img:"https://images.pexels.com/photos/9890972/pexels-photo-9890972.jpeg?auto=compress&cs=tinysrgb&w=900",specs:["5 Seats","Auto","Hybrid"]},
];

const FleetExplorer: React.FC<FleetExplorerProps> = ({
  wishlist,
  toggleWishlist,
  compareList,
  toggleCompare,
  openBookingModal
}) => {
  const [selectedCat, setSelectedCat] = useState('all');
  const [maxPrice, setMaxPrice] = useState(500);
  const [selectedTrans, setSelectedTrans] = useState('all');
  const [selectedSeats, setSelectedSeats] = useState('all');

  const filteredVehicles = FLEET_DATA.filter(v => {
    return (selectedCat === 'all' || v.cat === selectedCat) &&
           (selectedTrans === 'all' || v.trans === selectedTrans) &&
           (selectedSeats === 'all' || (selectedSeats === '5' ? v.seats >= 5 : v.seats === parseInt(selectedSeats))) &&
           v.price <= maxPrice;
  });

  return (
    <section id="fleet" className="py-24 px-8 max-w-7xl mx-auto flex flex-col gap-12">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-6">
        <div>
          <span className="eyebrow mb-3">Signature Collection</span>
          <h2 className="text-3xl sm:text-5xl font-display font-light">Featured Fleet. <span className="font-semibold text-primary">Zero compromise.</span></h2>
          <p className="text-text-muted mt-3 max-w-md">Every vehicle is inspected, detailed, and calibrated before it reaches you.</p>
        </div>
      </div>

      {/* HORIZONTAL CAROUSEL SHOWCASE */}
      <div className="overflow-x-auto no-scrollbar flex gap-6 pb-6 scroll-smooth">
        {FLEET_DATA.slice(0, 6).map((v) => (
          <div key={v.id} className="min-w-[320px] sm:min-w-[380px] bg-panel border border-border rounded-l overflow-hidden shadow-sm group hover:shadow-md transition-all duration-300">
            <div className="h-[220px] relative overflow-hidden bg-background">
              <img src={v.img} alt={v.name} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
              <button 
                onClick={() => toggleWishlist(v.id)} 
                className={`absolute top-4 right-4 w-9 h-9 rounded-full bg-white/80 flex items-center justify-center shadow-md transition-all ${wishlist.includes(v.id) ? 'text-danger' : 'text-gray-400 hover:text-text-heading'}`}
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill={wishlist.includes(v.id) ? 'currentColor' : 'none'} stroke="currentColor" strokeWidth="2"><path d="M12 21s-7-4.5-9.5-9C.7 8 2 4 6 4c2 0 3.5 1.2 4 2 .5-.8 2-2 4-2 4 0 5.3 4 3.5 8-2.5 4.5-9.5 9-9.5 9z"/></svg>
              </button>
            </div>
            <div className="p-6 flex flex-col gap-4">
              <div className="flex justify-between items-start">
                <h3 className="font-display font-bold text-xl text-text-heading">{v.name}</h3>
                <span className="font-mono text-xs px-2.5 py-1 bg-border rounded-md text-text-muted uppercase">{v.cat}</span>
              </div>
              <div className="flex flex-wrap gap-2">
                {v.specs.map((s, idx) => (
                  <span key={idx} className="font-mono text-[10px] text-text-muted border border-border px-2 py-0.5 rounded-md">{s}</span>
                ))}
              </div>
              <div className="flex items-center justify-between mt-2">
                <div>
                  <span className="font-display font-bold text-2xl text-text-heading">AED {v.price * 3.67 | 0}</span>
                  <span className="text-[11px] text-text-muted">/day</span>
                </div>
                <button 
                  onClick={() => openBookingModal(v.name)}
                  className="bg-primary hover:bg-primary-dim text-white text-xs font-semibold px-5 py-2.5 rounded-full shadow-sm transition-colors"
                >
                  Book Now
                </button>
              </div>

              {/* Compare toggle */}
              <label className="flex items-center gap-2 font-mono text-[11px] text-text-muted mt-2 cursor-pointer">
                <input 
                  type="checkbox" 
                  checked={compareList.includes(v.id)} 
                  onChange={() => toggleCompare(v.id)}
                  className="accent-primary" 
                />
                Add to compare
              </label>
            </div>
          </div>
        ))}
      </div>

      {/* FILTER PANEL */}
      <div className="bg-panel border border-border p-8 rounded-l flex flex-col gap-8 shadow-sm">
        <h3 className="font-display font-semibold text-lg text-text-heading">Interactive Explorer</h3>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 items-end">
          {/* CATEGORIES */}
          <div className="flex flex-col gap-2">
            <label className="font-mono text-[10px] uppercase text-text-muted">Category</label>
            <div className="flex flex-wrap gap-1.5">
              {['all', 'coupe', 'sedan', 'suv', 'ev'].map(c => (
                <button 
                  key={c} 
                  onClick={() => setSelectedCat(c)}
                  className={`px-3 py-1.5 rounded-full text-xs font-medium transition-all ${selectedCat === c ? 'bg-primary text-white' : 'border border-border text-text-muted hover:border-text-heading'}`}
                >
                  {c.toUpperCase()}
                </button>
              ))}
            </div>
          </div>

          {/* PRICE SLIDER */}
          <div className="flex flex-col gap-2">
            <div className="flex justify-between font-mono text-[10px] text-text-muted">
              <span>MAX PRICE</span>
              <span className="text-text-heading font-semibold">AED {(maxPrice * 3.67) | 0}</span>
            </div>
            <input 
              type="range" 
              min="150" 
              max="500" 
              value={maxPrice} 
              onChange={e => setMaxPrice(parseInt(e.target.value))}
              className="accent-primary w-full" 
            />
          </div>

          {/* SEATS */}
          <div className="flex flex-col gap-2">
            <label className="font-mono text-[10px] uppercase text-text-muted">Seats</label>
            <div className="flex flex-wrap gap-1.5">
              {['all', '2', '4', '5'].map(s => (
                <button 
                  key={s} 
                  onClick={() => setSelectedSeats(s)}
                  className={`px-3 py-1.5 rounded-full text-xs font-medium transition-all ${selectedSeats === s ? 'bg-primary text-white' : 'border border-border text-text-muted hover:border-text-heading'}`}
                >
                  {s === 'all' ? 'ANY' : s}
                </button>
              ))}
            </div>
          </div>

          {/* TRANSMISSION */}
          <div className="flex flex-col gap-2">
            <label className="font-mono text-[10px] uppercase text-text-muted">Transmission</label>
            <div className="flex flex-wrap gap-1.5">
              {['all', 'auto', 'manual'].map(t => (
                <button 
                  key={t} 
                  onClick={() => setSelectedTrans(t)}
                  className={`px-3 py-1.5 rounded-full text-xs font-medium transition-all ${selectedTrans === t ? 'bg-primary text-white' : 'border border-border text-text-muted hover:border-text-heading'}`}
                >
                  {t.toUpperCase()}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* RESULTS GRID */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <AnimatePresence>
            {filteredVehicles.map(v => (
              <motion.div 
                layout
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.95 }}
                transition={{ duration: 0.3 }}
                key={v.id} 
                className="bg-panel-hover border border-border rounded-m overflow-hidden shadow-sm flex flex-col hover:border-primary/45 transition-colors"
              >
                <div className="h-[150px] relative overflow-hidden bg-background">
                  <img src={v.img} alt={v.name} className="w-full h-full object-cover" />
                </div>
                <div className="p-4 flex justify-between items-center">
                  <div>
                    <h4 className="font-display font-bold text-[15px] text-text-heading">{v.name}</h4>
                    <span className="font-mono text-[10px] text-text-muted">{v.seats} seats · {v.trans}</span>
                  </div>
                  <span className="font-display font-semibold text-primary">AED {v.price * 3.67 | 0}/day</span>
                </div>
              </motion.div>
            ))}
          </AnimatePresence>
        </div>
      </div>
    </section>
  );
};

export default FleetExplorer;
