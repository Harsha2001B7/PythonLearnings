import React from 'react';

const LuxuryBrands = () => {
  const brands = ['Rolls-Royce', 'Bentley', 'Lamborghini', 'Ferrari', 'Porsche', 'McLaren'];
  
  return (
    <div className="py-12 border-y border-border bg-panel">
      <div className="max-w-7xl mx-auto px-8">
        <div className="flex flex-wrap justify-between items-center gap-8 md:gap-12 opacity-50">
          {brands.map((brand, i) => (
            <div key={i} className="text-xl md:text-2xl font-display uppercase tracking-widest text-text-heading font-semibold hover:opacity-100 transition-opacity duration-300 cursor-pointer">
              {brand}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default LuxuryBrands;
