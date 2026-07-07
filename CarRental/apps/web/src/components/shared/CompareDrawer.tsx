// @ts-nocheck — Legacy component replaced by inline CompareDrawer in src/pages/Home.tsx
import React from 'react';
import { Vehicle } from '../../types';

interface CompareDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  compareList: number[];
  setCompareList: React.Dispatch<React.SetStateAction<number[]>>;
}

const ALL_CARS: Vehicle[] = [
  {id:1,name:"Vantage GT",cat:"coupe",trans:"auto",fuel:"electric",seats:2,price:420,img:"https://images.pexels.com/photos/20131973/pexels-photo-20131973.jpeg?auto=compress&cs=tinysrgb&w=500",specs:["2 Seats","Auto","Electric"]},
  {id:2,name:"Continental S",cat:"sedan",trans:"auto",fuel:"petrol",seats:4,price:310,img:"https://images.pexels.com/photos/29566862/pexels-photo-29566862.jpeg?auto=compress&cs=tinysrgb&w=500",specs:["4 Seats","Auto","Petrol V8"]},
  {id:3,name:"Ridgeline Sport",cat:"suv",trans:"auto",fuel:"hybrid",seats:5,price:280,img:"https://images.pexels.com/photos/5288744/pexels-photo-5288744.jpeg?auto=compress&cs=tinysrgb&w=500",specs:["5 Seats","Auto","Hybrid"]},
  {id:4,name:"Nocturne Coupe",cat:"coupe",trans:"manual",fuel:"petrol",seats:2,price:390,img:"https://images.pexels.com/photos/29851075/pexels-photo-29851075.jpeg?auto=compress&cs=tinysrgb&w=500",specs:["2 Seats","Manual","Petrol"]},
  {id:5,name:"Meridian EV",cat:"ev",trans:"auto",fuel:"electric",seats:5,price:340,img:"https://images.pexels.com/photos/26954166/pexels-photo-26954166.jpeg?auto=compress&cs=tinysrgb&w=500",specs:["5 Seats","Auto","Electric"]},
  {id:6,name:"Overland X7",cat:"suv",trans:"auto",fuel:"petrol",seats:7,price:260,img:"https://images.pexels.com/photos/32500672/pexels-photo-32500672.jpeg?auto=compress&cs=tinysrgb&w=500",specs:["7 Seats","Auto","Petrol"]},
];

const CompareDrawer: React.FC<CompareDrawerProps> = ({ isOpen, onClose, compareList, setCompareList }) => {
  if (!isOpen) return null;

  const compareItems = ALL_CARS.filter(c => compareList.includes(c.id));

  return (
    <>
      <div onClick={onClose} className="fixed inset-0 bg-black/50 backdrop-blur-sm z-[940] transition-opacity" />
      <aside className="fixed top-0 right-0 h-full w-[420px] max-w-[90vw] bg-panel border-l border-border z-[950] flex flex-col shadow-2xl animate-[slideIn_0.3s_ease]">
        <div className="p-6 border-b border-border flex justify-between items-center">
          <h3 className="font-display font-semibold text-lg text-text-heading">Compare ({compareList.length})</h3>
          <button onClick={onClose} className="w-8 h-8 rounded-full border border-border flex items-center justify-center text-text-muted hover:border-text-heading hover:text-text-heading">✕</button>
        </div>

        <div className="p-6 flex-1 overflow-y-auto flex flex-col gap-4">
          {compareItems.length === 0 ? (
            <div className="text-center text-text-muted py-24">
              Add vehicles to compare specifications side by side.
            </div>
          ) : (
            compareItems.map(car => (
              <div key={car.id} className="border border-border p-4 rounded-m bg-panel-hover flex gap-4 items-center relative">
                <img src={car.img} alt={car.name} className="w-[80px] h-[60px] object-cover rounded-md" />
                <div className="flex-1 text-left">
                  <b className="text-sm text-text-heading block">{car.name}</b>
                  <span className="text-[11px] text-text-muted block">{car.specs.join(' · ')}</span>
                  <span className="text-xs text-primary font-bold block mt-1">AED {car.price * 3.67 | 0}/day</span>
                </div>
                <button 
                  onClick={() => setCompareList(prev => prev.filter(id => id !== car.id))}
                  className="text-text-muted hover:text-danger text-sm"
                  aria-label="Remove comparison"
                >
                  ✕
                </button>
              </div>
            ))
          )}
        </div>
      </aside>
    </>
  );
};

export default CompareDrawer;
