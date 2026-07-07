import React, { useState } from 'react';

const swatches = [
  { color: '#2f6bff', name: 'Onyx Blue' },
  { color: '#c9cdd3', name: 'Luxury Silver' },
  { color: '#0b0b0b', name: 'Deep Black' },
  { color: '#7a1f1f', name: 'Garnet Red' }
];

const viewImgs = {
  exterior: "https://images.pexels.com/photos/20131973/pexels-photo-20131973.jpeg?auto=compress&cs=tinysrgb&w=900",
  interior: "https://images.pexels.com/photos/5158160/pexels-photo-5158160.jpeg?auto=compress&cs=tinysrgb&w=900",
  wheels: "https://images.pexels.com/photos/32726107/pexels-photo-32726107.jpeg?auto=compress&cs=tinysrgb&w=900"
};

const VehicleDetail360 = () => {
  const [selectedColor, setSelectedColor] = useState(swatches[0]);
  const [selectedView, setSelectedView] = useState<'exterior' | 'interior' | 'wheels'>('exterior');

  return (
    <section className="py-24 px-8 max-w-7xl mx-auto flex flex-col gap-12">
      <div className="text-center">
        <span className="eyebrow mb-3 justify-center">Vehicle Experience</span>
        <h2 className="text-3xl sm:text-5xl font-display font-light">Inside the Vantage GT.</h2>
        <p className="text-text-muted mt-3">Switch the finish, explore the cabin, and preview the fine craft.</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
        <div className="relative aspect-[4/3] rounded-l overflow-hidden bg-panel border border-border shadow-sm">
          <img src={viewImgs[selectedView]} alt="Vantage GT" className="w-full h-full object-cover transition-opacity duration-300" />
          <div className="absolute bottom-4 left-4 bg-black/60 backdrop-blur-md border border-white/10 text-white text-xs px-3 py-1.5 rounded-full">
            {selectedView.toUpperCase()} — {selectedColor.name}
          </div>
        </div>

        <div className="flex flex-col gap-6">
          <span className="eyebrow">Vantage GT · Electric</span>
          <h3 className="font-display font-bold text-2xl text-text-heading">Choose your finish</h3>

          <div className="flex gap-3">
            {swatches.map((sw, idx) => (
              <button 
                key={idx}
                onClick={() => setSelectedColor(sw)}
                className={`w-9 h-9 rounded-full border-2 transition-transform duration-300 ${selectedColor.name === sw.name ? 'border-primary scale-110' : 'border-transparent'}`}
                style={{ backgroundColor: sw.color }}
                aria-label={sw.name}
              />
            ))}
          </div>

          <div className="flex gap-2">
            {(['exterior', 'interior', 'wheels'] as const).map(view => (
              <button 
                key={view}
                onClick={() => setSelectedView(view)}
                className={`px-4 py-2 rounded-full text-xs font-semibold uppercase tracking-wider transition-all ${selectedView === view ? 'bg-primary text-white shadow-sm' : 'border border-border text-text-muted hover:border-text-heading'}`}
              >
                {view}
              </button>
            ))}
          </div>

          <ul className="flex flex-col gap-3 mt-4 text-sm text-text-muted">
            <li className="flex items-center gap-3">
              <svg className="text-primary flex-shrink-0" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4"><path d="M20 6L9 17l-5-5"/></svg>
              420 mi range on a single charge
            </li>
            <li className="flex items-center gap-3">
              <svg className="text-primary flex-shrink-0" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4"><path d="M20 6L9 17l-5-5"/></svg>
              0–60 mph in 3.1 seconds
            </li>
            <li className="flex items-center gap-3">
              <svg className="text-primary flex-shrink-0" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4"><path d="M20 6L9 17l-5-5"/></svg>
              Hand-stitched leather interior detailing
            </li>
          </ul>
        </div>
      </div>
    </section>
  );
};

export default VehicleDetail360;
