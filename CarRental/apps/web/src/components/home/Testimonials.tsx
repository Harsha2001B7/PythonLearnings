import React, { useState, useEffect } from 'react';

const reviews = [
  {
    stars: "★★★★★",
    text: "The Mercedes-AMG was waiting at the gate before my flight landed in Dubai. Seamless concierge service.",
    name: "Marcus D.",
    role: "Founders Member, Dubai"
  },
  {
    stars: "★★★★★",
    text: "Booked a Vantage GT for a client weekend. Every detail — the clean scent, the preferences — was already set.",
    name: "Priya S.",
    role: "Vanguard Member, Mumbai"
  },
  {
    stars: "★★★★★",
    text: "Switched our regional luxury corporate fleet to VANTA. The detailed utilization dashboard is a game-changer.",
    name: "Ananya R.",
    role: "Corporate Client, Hyderabad"
  }
];

const Testimonials = () => {
  const [index, setIndex] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setIndex(prev => (prev + 1) % reviews.length);
    }, 5000);
    return () => clearInterval(timer);
  }, []);

  return (
    <section className="py-24 px-8 max-w-7xl mx-auto flex flex-col gap-12">
      <div className="text-center">
        <span className="eyebrow mb-3 justify-center">Member Stories</span>
        <h2 className="text-3xl sm:text-5xl font-display font-light">Trusted by drivers globally.</h2>
      </div>

      <div className="relative overflow-hidden w-full max-w-2xl mx-auto bg-panel border border-border p-12 rounded-l shadow-sm text-center">
        <div className="text-primary text-sm tracking-widest mb-6">{reviews[index].stars}</div>
        <p className="font-display font-medium text-lg sm:text-xl text-text-heading leading-relaxed mb-8">
          "{reviews[index].text}"
        </p>
        <div className="flex flex-col items-center">
          <span className="font-bold text-sm text-text-heading">{reviews[index].name}</span>
          <span className="text-xs text-text-muted mt-1">{reviews[index].role}</span>
        </div>

        <div className="flex justify-center gap-2 mt-8">
          {reviews.map((_, idx) => (
            <button 
              key={idx}
              onClick={() => setIndex(idx)}
              className={`h-2 rounded-full transition-all ${index === idx ? 'bg-primary w-6' : 'bg-border w-2'}`}
              aria-label={`Slide ${idx + 1}`}
            />
          ))}
        </div>
      </div>
    </section>
  );
};

export default Testimonials;
