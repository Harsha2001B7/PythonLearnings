import React from 'react';

interface AppShowcaseProps {
  showToast: (msg: string) => void;
}

const AppShowcase: React.FC<AppShowcaseProps> = ({ showToast }) => {
  return (
    <section className="py-24 px-8 max-w-7xl mx-auto">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
        {/* Floating Mobile Phone Mock */}
        <div className="flex justify-center">
          <div className="w-[260px] h-[520px] rounded-[44px] border-[8px] border-text-heading bg-panel overflow-hidden shadow-2xl relative animate-[bounce_5s_infinite_ease-in-out]">
            <img src="https://images.pexels.com/photos/20131973/pexels-photo-20131973.jpeg?auto=compress&cs=tinysrgb&w=500" alt="Mobile Screen" className="w-full h-full object-cover" />
            <div className="absolute top-3.5 left-1/2 -translate-x-1/2 w-[80px] h-[18px] bg-text-heading rounded-full z-10" />
          </div>
        </div>

        <div className="flex flex-col gap-6">
          <span className="eyebrow">Mobile App</span>
          <h2 className="text-3xl sm:text-5xl font-display font-light">Your garage, <span className="font-semibold text-primary">in your pocket.</span></h2>
          <p className="text-text-muted text-sm leading-relaxed">
            Unlock, track active range, check charging profiles, and extend any rental directly from your phone — no counter queues required.
          </p>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-6 mt-4">
            <div className="flex items-start gap-4">
              <svg className="text-primary mt-1 flex-shrink-0" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="3" y="11" width="18" height="10" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
              <div>
                <span className="font-bold text-sm text-text-heading block">Digital Key</span>
                <span className="text-xs text-text-muted">Unlock straight from your smartphone</span>
              </div>
            </div>
            <div className="flex items-start gap-4">
              <svg className="text-primary mt-1 flex-shrink-0" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M3 3v18h18"/><path d="M7 15l4-4 3 3 5-6"/></svg>
              <div>
                <span className="font-bold text-sm text-text-heading block">Live Tracking</span>
                <span className="text-xs text-text-muted">Mileage and battery tracking in real-time</span>
              </div>
            </div>
            <div className="flex items-start gap-4">
              <svg className="text-primary mt-1 flex-shrink-0" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 3"/></svg>
              <div>
                <span className="font-bold text-sm text-text-heading block">One-tap Extend</span>
                <span className="text-xs text-text-muted">Instantly add a day before check-out</span>
              </div>
            </div>
            <div className="flex items-start gap-4">
              <svg className="text-primary mt-1 flex-shrink-0" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
              <div>
                <span className="font-bold text-sm text-text-heading block">Concierge Chat</span>
                <span className="text-xs text-text-muted">Reach a human support lead in seconds</span>
              </div>
            </div>
          </div>

          <div className="flex gap-4 mt-6">
            <button onClick={() => showToast("App Store launch coming Q4")} className="flex items-center gap-3 border border-border px-5 py-2.5 rounded-[12px] hover:border-primary transition-colors">
              <svg className="text-text-heading" width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M17.5 12.3c0-2.9 2.4-4.3 2.5-4.4-1.4-2-3.5-2.3-4.2-2.3-1.8-.2-3.5 1-4.4 1-.9 0-2.3-1-3.8-1-2 0-3.8 1.1-4.8 2.9-2 3.6-.5 8.9 1.5 11.8 1 1.4 2.1 3 3.7 2.9 1.5-.1 2-1 3.8-1s2.2.9 3.8.9c1.6 0 2.6-1.4 3.5-2.9.9-1.4 1.3-2.8 1.3-2.9-.1-.1-2.9-1.1-2.9-4.4z"/></svg>
              <div className="text-left leading-tight">
                <span className="block text-[9px] text-text-muted">Download on the</span>
                <span className="block text-xs font-bold text-text-heading">App Store</span>
              </div>
            </button>
            <button onClick={() => showToast("Play Store launch coming Q4")} className="flex items-center gap-3 border border-border px-5 py-2.5 rounded-[12px] hover:border-primary transition-colors">
              <svg className="text-text-heading" width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M3 3l11 9-11 9V3zM14.5 12l3.5-2 3 2-3 2-3.5-2z"/></svg>
              <div className="text-left leading-tight">
                <span className="block text-[9px] text-text-muted">Get it on</span>
                <span className="block text-xs font-bold text-text-heading">Google Play</span>
              </div>
            </button>
          </div>
        </div>
      </div>
    </section>
  );
};

export default AppShowcase;
