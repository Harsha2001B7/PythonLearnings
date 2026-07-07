import { motion } from 'framer-motion';

const vehicles = [
  { id: 1, name: "Rolls-Royce Ghost", price: "2,500", image: "https://images.unsplash.com/photo-1631295868223-63265b40d9e4?q=80&w=1000&auto=format&fit=crop" },
  { id: 2, name: "Lamborghini Urus", price: "3,000", image: "https://images.unsplash.com/photo-1544829099-b9a0c07fad1a?q=80&w=1000&auto=format&fit=crop" },
  { id: 3, name: "Porsche 911 GT3", price: "2,200", image: "https://images.unsplash.com/photo-1503376766858-6cd551066fd7?q=80&w=1000&auto=format&fit=crop" },
];

const FeaturedVehicles = () => {
  return (
    <section className="py-32 px-8 max-w-7xl mx-auto">
      <div className="flex justify-between items-end mb-16">
        <div>
          <h2 className="text-4xl md:text-5xl font-display font-light mb-4">Our Signature <span className="font-semibold">Fleet</span></h2>
          <p className="text-gray-400">Meticulously maintained. Exquisitely presented.</p>
        </div>
        <a href="#" className="hidden md:block text-sm uppercase tracking-widest border-b border-primary text-primary pb-1">View All Models</a>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        {vehicles.map((car, i) => (
          <motion.div 
            key={car.id}
            initial={{ opacity: 0, y: 50 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, delay: i * 0.2 }}
            className="group cursor-pointer"
          >
            <div className="relative h-[400px] overflow-hidden rounded-lg mb-6 bg-card">
              <div className="absolute inset-0 bg-black/20 group-hover:bg-transparent transition-colors duration-500 z-10" />
              <img src={car.image} alt={car.name} className="w-full h-full object-cover transform group-hover:scale-105 transition-transform duration-700 ease-out" />
            </div>
            <div className="flex justify-between items-center">
              <h3 className="text-xl font-display">{car.name}</h3>
              <p className="text-primary font-medium">AED {car.price} <span className="text-gray-500 text-sm font-light">/day</span></p>
            </div>
          </motion.div>
        ))}
      </div>
    </section>
  );
};

export default FeaturedVehicles;
