const Experience = () => {
  return (
    <section className="py-32 relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-8 grid grid-cols-1 md:grid-cols-2 gap-16 items-center">
        <div>
          <h2 className="text-4xl md:text-6xl font-display font-light leading-tight mb-8">
            BEYOND <br/><span className="font-semibold italic text-primary">DRIVING</span>
          </h2>
          <p className="text-gray-400 text-lg mb-8 max-w-md leading-relaxed">
            From seamless airport transfers to bespoke city tours, our concierge service ensures every aspect of your journey is extraordinary. We don't just rent cars; we curate experiences.
          </p>
          <ul className="space-y-4 mb-12">
            {['Chauffeur Services Available', '24/7 Roadside Assistance', 'Customized Delivery Options'].map((item, i) => (
              <li key={i} className="flex items-center text-sm uppercase tracking-wider text-gray-300">
                <div className="w-1.5 h-1.5 bg-primary rounded-full mr-4" />
                {item}
              </li>
            ))}
          </ul>
        </div>
        <div className="relative h-[600px]">
          <div className="absolute inset-0 rounded-2xl overflow-hidden">
            <img src="https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?q=80&w=1000&auto=format&fit=crop" className="w-full h-full object-cover" alt="Luxury Lifestyle" />
          </div>
        </div>
      </div>
    </section>
  );
};

export default Experience;
