import React from 'react';

const Corporate = () => {
  return (
    <section id="corporate" className="py-24 bg-panel border-y border-border">
      <div className="max-w-7xl mx-auto px-8">
        <div className="bg-panel border border-border rounded-l overflow-hidden grid grid-cols-1 lg:grid-cols-2 shadow-sm">
          <div className="p-12 sm:p-16 flex flex-col gap-6 justify-center">
            <span className="eyebrow">Corporate Fleet</span>
            <h2 className="text-3xl sm:text-4xl font-display font-light">Mobility, managed for your whole team.</h2>
            <p className="text-text-muted text-sm leading-relaxed">
              One unified dashboard for bookings, detailed billing, and real-time vehicle tracking across every market you operate.
            </p>
            <div className="grid grid-cols-2 gap-6 mt-4">
              <div>
                <span className="font-display font-bold text-3xl text-primary">1,200</span>
                <span className="block font-mono text-[10px] text-text-muted uppercase mt-1">Corporate Accounts</span>
              </div>
              <div>
                <span className="font-display font-bold text-3xl text-primary">38</span>
                <span className="block font-mono text-[10px] text-text-muted uppercase mt-1">Countries Served</span>
              </div>
              <div>
                <span className="font-display font-bold text-3xl text-primary">97%</span>
                <span className="block font-mono text-[10px] text-text-muted uppercase mt-1">Renewal Rate</span>
              </div>
              <div>
                <span className="font-display font-bold text-3xl text-primary">24h</span>
                <span className="block font-mono text-[10px] text-text-muted uppercase mt-1">Direct Fleet Support</span>
              </div>
            </div>
            <button className="bg-primary hover:bg-primary-dim text-white text-xs font-semibold px-6 py-3 rounded-full mt-6 w-fit transition-colors shadow-sm">
              Talk to Fleet Sales
            </button>
          </div>
          <div className="min-h-[300px] relative">
            <img src="https://images.pexels.com/photos/32500672/pexels-photo-32500672.jpeg?auto=compress&cs=tinysrgb&w=900" alt="Corporate" className="w-full h-full object-cover" />
          </div>
        </div>
      </div>
    </section>
  );
};

export default Corporate;
