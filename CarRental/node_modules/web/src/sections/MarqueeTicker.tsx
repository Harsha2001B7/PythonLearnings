import React from 'react';

const ITEMS = [
  'FREE DUBAI DELIVERY',
  'DAILY · WEEKLY · MONTHLY',
  'ZERO DEPOSIT OPTION',
  'ALL EMIRATES ALLOWED',
  '24/7 SUPPORT',
  'BOOK ON WHATSAPP',
  'AIRPORT PICK-UP',
  'NO HIDDEN FEES',
  'FREE DUBAI DELIVERY',
  'DAILY · WEEKLY · MONTHLY',
  'ZERO DEPOSIT OPTION',
  'ALL EMIRATES ALLOWED',
  '24/7 SUPPORT',
  'BOOK ON WHATSAPP',
  'AIRPORT PICK-UP',
  'NO HIDDEN FEES',
];

const MarqueeTicker: React.FC = () => (
  <div
    className="overflow-hidden border-y border-gray-200 bg-white py-3"
    aria-label="Features banner"
    style={{ userSelect: 'none' }}
  >
    {/* Inline style so animation always runs (no Tailwind purge issue) */}
    <div
      className="flex whitespace-nowrap"
      style={{ animation: 'marquee 28s linear infinite', willChange: 'transform' }}
    >
      {ITEMS.map((item, i) => (
        <React.Fragment key={i}>
          <span className="font-mono text-[11px] font-semibold tracking-[0.22em] uppercase text-gray-400 px-1">
            {item}
          </span>
          <span
            className="inline-block mx-4 text-orange-500 font-bold text-[14px]"
            aria-hidden
            style={{ transform: 'rotate(0deg)', lineHeight: 1 }}
          >
            ◆
          </span>
        </React.Fragment>
      ))}
    </div>
  </div>
);

export default MarqueeTicker;
