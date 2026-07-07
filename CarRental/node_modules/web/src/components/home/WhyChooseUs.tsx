import React from 'react';

const WhyChooseUs = () => {
  const points = [
    {
      title: "Curated, not generic",
      desc: "Every vehicle earns its place through a rigorous 40-point inspection — no filler models, no fleet padding.",
      icon: (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
          <path d="M12 2l3 7h7l-5.5 4.5L18 21l-6-4-6 4 1.5-7.5L2 9h7z"/>
        </svg>
      )
    },
    {
      title: "90-second confirmation",
      desc: "Search, select, sign — our booking engine clears identity verification while you are still choosing trim.",
      icon: (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
          <circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 3"/>
        </svg>
      )
    },
    {
      title: "Delivered, detailed",
      desc: "Your car arrives charged, cleaned, and set to your preferences — wherever you're standing in Dubai.",
      icon: (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
          <path d="M3 12l2-6h14l2 6M5 12h14v6H5z"/><circle cx="7.5" cy="18" r="1.2"/><circle cx="16.5" cy="18" r="1.2"/>
        </svg>
      )
    },
    {
      title: "Flat rate pricing",
      desc: "No hidden charges, zero surprises. The rate you see at checkout includes complete luxury cover.",
      icon: (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
          <rect x="2" y="4" width="20" height="16" rx="2"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/>
        </svg>
      )
    }
  ];

  return (
    <section id="experience" className="py-24 bg-panel border-y border-border">
      <div className="max-w-7xl mx-auto px-8 flex flex-col gap-16">
        <div className="text-center max-w-xl mx-auto">
          <span className="eyebrow mb-3 justify-center">Why VANTA</span>
          <h2 className="text-3xl sm:text-5xl font-display font-light">Built for people who drive on their <span className="font-semibold text-primary">own terms.</span></h2>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 border border-border rounded-l overflow-hidden bg-border gap-[1px]">
          {points.map((p, i) => (
            <div key={i} className="bg-panel p-8 hover:bg-panel-hover transition-colors flex flex-col gap-4">
              <div className="w-[44px] h-[44px] rounded-[12px] bg-primary/10 text-primary flex items-center justify-center mb-2">
                {p.icon}
              </div>
              <h4 className="font-display font-bold text-lg text-text-heading">{p.title}</h4>
              <p className="text-sm text-text-muted leading-relaxed">{p.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default WhyChooseUs;
