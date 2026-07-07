import React from 'react';

interface MembershipProps {
  openBookingModal: (name: string) => void;
}

const Membership: React.FC<MembershipProps> = ({ openBookingModal }) => {
  const tiers = [
    {
      name: "Voyager",
      price: "0",
      features: [
        "Standard fleet access",
        "Pay-per-rental pricing",
        "Standard digital support"
      ],
      featured: false,
      btnText: "Start Free"
    },
    {
      name: "Vanguard",
      price: "290",
      features: [
        "Priority booking window",
        "15% off every rental",
        "Free delivery, always",
        "24/7 concierge line"
      ],
      featured: true,
      btnText: "Join Vanguard"
    },
    {
      name: "Founders",
      price: "910",
      features: [
        "Exclusive Founders fleet",
        "30% off every rental",
        "Dedicated relationship manager",
        "First access to fresh arrivals"
      ],
      featured: false,
      btnText: "Request Invite"
    }
  ];

  return (
    <section id="membership" className="py-24 bg-panel border-t border-border">
      <div className="max-w-7xl mx-auto px-8 flex flex-col gap-16">
        <div className="text-center max-w-xl mx-auto">
          <span className="eyebrow mb-3 justify-center">Membership</span>
          <h2 className="text-3xl sm:text-5xl font-display font-light">Belong to the fleet.</h2>
          <p className="text-text-muted mt-3">Three tiers, one promise — priority access to the vehicles everyone else is waiting on.</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {tiers.map((tier, idx) => (
            <div 
              key={idx}
              className={`border rounded-l p-8 flex flex-col gap-6 relative transition-all duration-300 ${tier.featured ? 'bg-gradient-to-b from-primary/10 to-panel border-primary shadow-lg scale-105' : 'bg-panel-hover border-border hover:border-text-muted shadow-sm'}`}
            >
              {tier.featured && (
                <span className="absolute top-0 right-8 -translate-y-1/2 bg-primary text-white text-[10px] font-mono font-semibold px-3 py-1 rounded-full uppercase tracking-wider">
                  Most Chosen
                </span>
              )}
              <h3 className="font-display font-bold text-2xl text-text-heading">{tier.name}</h3>
              <div>
                <span className="font-display font-bold text-4xl text-text-heading">AED {tier.price}</span>
                <span className="text-sm text-text-muted">/month</span>
              </div>
              <ul className="flex flex-col gap-3 my-4 flex-1">
                {tier.features.map((f, i) => (
                  <li key={i} className="flex items-center gap-3 text-sm text-text-muted">
                    <svg className="text-primary flex-shrink-0" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4"><path d="M20 6L9 17l-5-5"/></svg>
                    {f}
                  </li>
                ))}
              </ul>
              <button 
                onClick={() => openBookingModal(`${tier.name} Membership`)}
                className={`w-full py-3.5 rounded-full text-sm font-semibold transition-all ${tier.featured ? 'bg-primary text-white hover:bg-primary-dim shadow-sm' : 'border border-border text-text-heading hover:border-text-heading'}`}
              >
                {tier.btnText}
              </button>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Membership;
