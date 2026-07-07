import React, { useState } from 'react';

const faqs = [
  {
    q: "What do I need to rent a vehicle in Dubai?",
    a: "You'll need a valid UAE driving license (or international license for visitors), your passport, and to be at least 21 years old. Identity verification resolves via the app in minutes."
  },
  {
    q: "Is luxury insurance coverage included?",
    a: "Yes. Comprehensive, zero-excess insurance coverage is bundled natively into the daily rental rate shown at checkout."
  },
  {
    q: "Can I extend or end my rental early?",
    a: "Both actions can be triggered with one tap from the mobile dashboard. Early returns are automatically pro-rated instantly."
  },
  {
    q: "Where does VANTA deliver inside the UAE?",
    a: "We deliver directly to DXB Airport, BKC studios, luxury hotels, or your private residence. Delivery is complimentary for Vanguard and Founders."
  }
];

const Faq = () => {
  const [openIdx, setOpenIdx] = useState<number | null>(0);

  const toggle = (idx: number) => {
    setOpenIdx(prev => prev === idx ? null : idx);
  };

  return (
    <section id="faq" className="py-24 bg-panel border-t border-border">
      <div className="max-w-3xl mx-auto px-8 flex flex-col gap-12">
        <div className="text-center">
          <span className="eyebrow mb-3 justify-center">Questions</span>
          <h2 className="text-3xl sm:text-5xl font-display font-light">Everything you are wondering.</h2>
        </div>

        <div className="flex flex-col border-t border-border">
          {faqs.map((faq, idx) => (
            <div key={idx} className="border-b border-border">
              <button 
                onClick={() => toggle(idx)}
                className="w-full flex justify-between items-center py-6 text-left font-display font-medium text-base sm:text-lg text-text-heading hover:text-primary transition-colors"
              >
                {faq.q}
                <span className={`w-5 h-5 relative flex-shrink-0 transition-transform duration-300 ${openIdx === idx ? 'rotate-45' : ''}`}>
                  <span className="absolute top-1/2 left-0 w-full h-[1.5px] bg-text-muted -translate-y-1/2" />
                  <span className="absolute left-1/2 top-0 h-full w-[1.5px] bg-text-muted -translate-x-1/2" />
                </span>
              </button>
              {openIdx === idx && (
                <div className="pb-6 text-sm text-text-muted leading-relaxed max-w-2xl animate-[fadeIn_0.3s_ease]">
                  {faq.a}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Faq;
