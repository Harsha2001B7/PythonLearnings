import React, { useState } from 'react';

interface BookingModalProps {
  vehicleName: string;
  onClose: () => void;
  showToast: (msg: string) => void;
}

const BookingModal: React.FC<BookingModalProps> = ({ vehicleName, onClose, showToast }) => {
  const [step, setStep] = useState(1);
  const [delivery, setDelivery] = useState('Dubai Airport — DXB Terminal 3');

  const handleNext = () => {
    if (step < 3) {
      setStep(prev => prev + 1);
    } else {
      showToast(`Booking Confirmed for your ${vehicleName}!`);
      onClose();
    }
  };

  return (
    <div className="fixed inset-0 bg-black/60 z-[970] flex items-center justify-center p-4">
      <div className="bg-panel border border-border rounded-l max-w-[480px] w-full p-8 text-center shadow-2xl relative">
        <button onClick={onClose} className="absolute top-4 right-4 text-text-muted hover:text-text-heading text-lg">✕</button>

        <div className="w-[60px] h-[60px] rounded-full bg-primary/10 text-primary flex items-center justify-center mx-auto mb-6">
          <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="9"/><path d="M9 12l2 2 4-4"/></svg>
        </div>

        {step === 1 && (
          <>
            <h3 className="font-display font-semibold text-2xl text-text-heading mb-3">Confirm your {vehicleName}</h3>
            <p className="text-text-muted text-sm leading-relaxed mb-6">
              Reserving this vehicle for your selected dates. No charges are processed until hand-off verification is completed.
            </p>
          </>
        )}

        {step === 2 && (
          <>
            <h3 className="font-display font-semibold text-2xl text-text-heading mb-3">Delivery details</h3>
            <p className="text-text-muted text-sm leading-relaxed mb-4">Choose where you'd like your driver to hand over the vehicle keys.</p>
            <select 
              value={delivery}
              onChange={e => setDelivery(e.target.value)}
              className="w-full bg-panel-hover border border-border p-3 rounded-m text-text-heading text-sm focus:outline-none mb-6 cursor-pointer"
            >
              <option value="Dubai Airport — DXB Terminal 3">Dubai Airport — DXB Terminal 3</option>
              <option value="Downtown BKC Studio Hub">Downtown BKC Studio Hub</option>
              <option value="Mayfair garage partner">Mayfair garage partner</option>
            </select>
          </>
        )}

        {step === 3 && (
          <>
            <h3 className="font-display font-semibold text-2xl text-text-heading mb-3">Review & confirm</h3>
            <p className="text-text-muted text-sm leading-relaxed mb-6">Everything looks complete. Confirm to book your lock-in rate with zero deposit required.</p>
          </>
        )}

        {/* PROGRESS */}
        <div className="flex justify-between items-center relative my-6 max-w-[200px] mx-auto">
          <div className="absolute top-1/2 left-0 w-full h-[2px] bg-border -translate-y-1/2" />
          <div className="absolute top-1/2 left-0 h-[2px] bg-primary -translate-y-1/2 transition-all duration-300" style={{ width: `${(step - 1) * 50}%` }} />
          {[1, 2, 3].map(i => (
            <span key={i} className={`w-[26px] h-[26px] rounded-full text-xs font-mono font-bold flex items-center justify-center relative z-10 transition-colors ${step >= i ? 'bg-primary text-white' : 'bg-panel border border-border text-text-muted'}`}>
              {i}
            </span>
          ))}
        </div>

        <button 
          onClick={handleNext}
          className="w-full bg-primary hover:bg-primary-dim text-white font-semibold py-3.5 rounded-full shadow-sm transition-colors mt-2"
        >
          {step === 3 ? 'Confirm Booking' : 'Continue'}
        </button>
      </div>
    </div>
  );
};

export default BookingModal;
