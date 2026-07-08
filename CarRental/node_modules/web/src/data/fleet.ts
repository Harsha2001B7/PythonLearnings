// ─────────────────────────────────────────────────────────────────
// Falcon View Car Rentals — Fleet Data
// Pricing source: B2B Vehicle Price List (client-provided)
// All prices in AED, excluded from VAT
// KMS Allowed: 300/day (1-6d), 200/day (7-29d), 4000/mo (30+d)
// Salik surcharge: AED 1 per toll
// ─────────────────────────────────────────────────────────────────
import type { Vehicle } from '../types/index';

import imgAttrage from '../../assets/cars/Mirage-Attrage.jpg';
import imgSunny from '../../assets/cars/Nissan-Sunny.jpg';
import imgMg3 from '../../assets/cars/MG-3.jpg';
import imgPegas from '../../assets/cars/Kia-Pages.jpg';
import imgBaleno from '../../assets/cars/Suzuki-Baleno.jpg';
import imgCiaz from '../../assets/cars/Suzuki-Ciaz.jpg';
import imgMg5 from '../../assets/cars/MG-5.jpg';
import imgMgGt from '../../assets/cars/MG-gt.jpg';
import imgMazda6 from '../../assets/cars/Mazda-6.jpg';
import imgKicks from '../../assets/cars/Nissan-Kicks.jpg';
import imgKaiyix3 from '../../assets/cars/KAIYI-X3-PRO.jpg';
import imgSeltos from '../../assets/cars/Kia-seltos.jpg';
import imgCreta from '../../assets/cars/Hyndai-Creta.jpg';
import imgRush from '../../assets/cars/Toyota-Rush.jpg';
import imgXpander from '../../assets/cars/mitsubishi-xpander.jpg';
import imgXpanderCross from '../../assets/cars/mitsubishi-xpander-cross.jpg';
import imgDestinator from '../../assets/cars/mitsubishi-destinator.jpg';
import imgXterra from '../../assets/cars/Nissan-Xterra.jpg';
import imgChallenger from '../../assets/cars/dodge challenger.jpg';
import imgPatrol from '../../assets/cars/nissan-patrol.jpg';

// Shared pricing constants from B2B price sheet
const KMS_DAILY = 300;
const KMS_WEEKLY = 200; // per day equiv tracked as per-day in weekly tier
const KMS_MONTHLY = 4000;
const SALIK = 1;
const VAT = 5;

const STANDARD_INCLUDES = [
  'Comprehensive insurance',
  'Free delivery across Dubai',
  'Free 24/7 roadside assistance',
  'Salik tag included',
  'Regular servicing & maintenance',
  'No hidden fees',
  'Clean & sanitised vehicle',
];

const STANDARD_FAQS = [
  {
    question: 'What documents do I need?',
    answer: 'A valid driving licence (UAE, GCC, International, or select national licences), your passport or Emirates ID, and a credit card for the security deposit.',
  },
  {
    question: 'Is there a minimum rental period?',
    answer: 'Our minimum rental period is 1 day (24 hours). Weekly and monthly rates apply automatically based on your rental duration.',
  },
  {
    question: 'How does free delivery work?',
    answer: 'We deliver your car to any location across Dubai at no extra charge. Simply provide your address and preferred time, and our team will bring the keys to you.',
  },
  {
    question: 'What happens if I exceed the included kilometres?',
    answer: 'Each extra kilometre over your included allowance is charged at the stated excess rate (AED 0.50 or AED 1.00 depending on the vehicle). We always notify you before any excess charges apply.',
  },
  {
    question: 'Is the deposit refundable?',
    answer: 'Yes. The security deposit is 100% refundable within 3–5 business days after the vehicle is returned in its original condition.',
  },
];

export const FLEET_DATA: Vehicle[] = [
  // ── 1. Mitsubishi Attrage ──────────────────────────────────────
  {
    id: 1, slug: 'mitsubishi-attrage', brand: 'Mitsubishi', model: 'Attrage',
    name: 'Mitsubishi Attrage',
    tagline: 'Reliable Daily Sedan — Fuel-efficient & Comfortable',
    description: 'The Mitsubishi Attrage is the ideal companion for daily commutes and weekend getaways across Dubai. Its fuel-efficient 1.2L MIVEC engine keeps running costs minimal while the spacious interior ensures a comfortable ride for up to 5 passengers. Perfect for both city driving and highway trips.',
    category: 'sedan', year: 2023,
    specs: { engine: '1.2L MIVEC', power: '78 hp', torque: '100 Nm', seats: 5, doors: 4, luggage: 450, transmission: 'auto', fuel: 'petrol', year: 2023 },
    pricing: { daily: 65, weekly: 60, monthly: 1550, excessPerKm: 0.50, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 1000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgAttrage, exterior: [imgAttrage], interior: [imgAttrage] },
    colors: [{ name: 'Pearl White', hex: '#F5F5F0' }, { name: 'Silver', hex: '#C0C0C0' }],
    features: ['5 Seats', 'Automatic', 'Petrol', 'A/C', 'Bluetooth', 'USB Charging', 'Reverse Camera'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: false, isPopular: false, isNewArrival: false, available: true, badge: 'Best Value',
    rating: 4.6, reviewCount: 38, minDriverAge: 21, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['nissan-sunny', 'kia-pegas', 'suzuki-ciaz'],
    seoTitle: 'Rent Mitsubishi Attrage Dubai | AED 65/day | Falcon View',
    seoDescription: 'Rent the Mitsubishi Attrage in Dubai for AED 65/day. Free delivery, 24/7 support, comprehensive insurance included. Book now via WhatsApp.',
    keywords: ['mitsubishi attrage rental dubai', 'cheap sedan rental dubai', 'economy car rental uae'],
    pricePerDay: 65, pricePerWeek: 60 * 7,
    cat: 'sedan', trans: 'auto', fuel: 'petrol', seats: 5, price: 65, img: imgAttrage, specs_legacy: ['5 Seats', 'Auto', 'AED 65/day'],
  },

  // ── 2. Nissan Sunny ───────────────────────────────────────────
  {
    id: 2, slug: 'nissan-sunny', brand: 'Nissan', model: 'Sunny',
    name: 'Nissan Sunny',
    tagline: 'Spacious Sedan — Perfect for City & Highway',
    description: 'The Nissan Sunny delivers excellent value with its roomy cabin and proven reliability. A favourite among expats and long-term renters in Dubai, the Sunny\'s 1.5L DOHC engine provides effortless power for both stop-start traffic and open highway cruising.',
    category: 'sedan', year: 2023,
    specs: { engine: '1.5L DOHC', power: '99 hp', torque: '134 Nm', seats: 5, doors: 4, luggage: 475, transmission: 'auto', fuel: 'petrol', year: 2023 },
    pricing: { daily: 65, weekly: 60, monthly: 1550, excessPerKm: 0.50, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 1000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgSunny, exterior: [imgSunny], interior: [imgSunny] },
    colors: [{ name: 'Brilliant Silver', hex: '#C8C8C8' }, { name: 'Super Black', hex: '#1A1A1A' }],
    features: ['5 Seats', 'Automatic', 'Petrol', 'A/C', 'Bluetooth', 'USB Charging', 'Keyless Entry'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: false, isPopular: true, isNewArrival: false, available: true,
    rating: 4.5, reviewCount: 52, minDriverAge: 21, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['mitsubishi-attrage', 'kia-pegas', 'suzuki-ciaz'],
    seoTitle: 'Rent Nissan Sunny Dubai | AED 65/day | Falcon View',
    seoDescription: 'Rent the Nissan Sunny in Dubai for AED 65/day. Spacious 5-seater, free delivery, comprehensive insurance. Book instantly via WhatsApp.',
    keywords: ['nissan sunny rental dubai', 'sedan rental dubai', 'family car rental uae'],
    pricePerDay: 65, pricePerWeek: 60 * 7,
    cat: 'sedan', trans: 'auto', fuel: 'petrol', seats: 5, price: 65, img: imgSunny, specs_legacy: ['5 Seats', 'Auto', 'AED 65/day'],
  },

  // ── 3. MG3 ───────────────────────────────────────────────────
  {
    id: 3, slug: 'mg3', brand: 'MG', model: 'MG3',
    name: 'MG3',
    tagline: 'Stylish Hatchback — Fun, Nimble & Affordable',
    description: 'The MG3 brings a dash of European flair to Dubai\'s streets. Its 1.5L engine delivers punchy acceleration, while the sporty exterior and well-appointed interior punch well above the entry-level price point. Great for solo or couple adventures around the city.',
    category: 'hatchback', year: 2023,
    specs: { engine: '1.5L VTi', power: '109 hp', torque: '150 Nm', seats: 5, doors: 5, luggage: 270, transmission: 'auto', fuel: 'petrol', year: 2023 },
    pricing: { daily: 70, weekly: 65, monthly: 1650, excessPerKm: 0.50, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 1000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgMg3, exterior: [imgMg3], interior: [imgMg3] },
    colors: [{ name: 'Flag Red', hex: '#C0392B' }, { name: 'Lunar White', hex: '#F8F8F8' }],
    features: ['5 Seats', 'Automatic', 'Hatchback', 'A/C', 'Bluetooth', 'Touchscreen', 'Parking Sensors'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: false, isPopular: false, isNewArrival: false, available: true,
    rating: 4.4, reviewCount: 29, minDriverAge: 21, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['suzuki-baleno', 'kia-pegas', 'mg5'],
    seoTitle: 'Rent MG3 Dubai | AED 70/day | Falcon View Car Rentals',
    seoDescription: 'Rent the MG3 hatchback in Dubai for AED 70/day. Sporty, fuel-efficient, free delivery across Dubai. Book via WhatsApp now.',
    keywords: ['mg3 rental dubai', 'hatchback rental dubai', 'compact car rental uae'],
    pricePerDay: 70, pricePerWeek: 65 * 7,
    cat: 'hatchback', trans: 'auto', fuel: 'petrol', seats: 5, price: 70, img: imgMg3, specs_legacy: ['5 Seats', 'Hatchback', 'AED 70/day'],
  },

  // ── 4. Kia Pegas ─────────────────────────────────────────────
  {
    id: 4, slug: 'kia-pegas', brand: 'Kia', model: 'Pegas',
    name: 'Kia Pegas',
    tagline: 'Modern Sedan — Tech-Loaded & Affordable',
    description: 'The Kia Pegas combines Korean build quality with modern technology at an accessible price. Its clean lines, comfortable cabin, and generous feature list — including a large touchscreen and multiple connectivity options — make it a smart choice for business and leisure travellers alike.',
    category: 'sedan', year: 2023,
    specs: { engine: '1.4L MPI', power: '100 hp', torque: '133 Nm', seats: 5, doors: 4, luggage: 502, transmission: 'auto', fuel: 'petrol', year: 2023 },
    pricing: { daily: 70, weekly: 65, monthly: 1650, excessPerKm: 0.50, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 1000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgPegas, exterior: [imgPegas], interior: [imgPegas] },
    colors: [{ name: 'Snow White Pearl', hex: '#F0EDE8' }, { name: 'Aurora Black', hex: '#111111' }],
    features: ['5 Seats', 'Automatic', 'Petrol', 'A/C', '8" Touchscreen', 'Apple CarPlay', 'Lane Assist'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: false, isPopular: false, isNewArrival: false, available: true,
    rating: 4.5, reviewCount: 24, minDriverAge: 21, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['mitsubishi-attrage', 'nissan-sunny', 'suzuki-ciaz'],
    seoTitle: 'Rent Kia Pegas Dubai | AED 70/day | Falcon View',
    seoDescription: 'Rent the Kia Pegas in Dubai from AED 70/day. Modern sedan with Apple CarPlay, free delivery, full insurance. Book now.',
    keywords: ['kia pegas rental dubai', 'kia rental dubai', 'sedan rental uae'],
    pricePerDay: 70, pricePerWeek: 65 * 7,
    cat: 'sedan', trans: 'auto', fuel: 'petrol', seats: 5, price: 70, img: imgPegas, specs_legacy: ['5 Seats', 'Auto', 'AED 70/day'],
  },

  // ── 5. Suzuki Baleno ─────────────────────────────────────────
  {
    id: 5, slug: 'suzuki-baleno', brand: 'Suzuki', model: 'Baleno',
    name: 'Suzuki Baleno',
    tagline: 'Agile Hatchback — Great Fuel Economy',
    description: 'The Suzuki Baleno is a refined premium hatchback that offers an elevated driving experience without the premium price. Its lightweight construction and efficient 1.5L K15B engine deliver excellent fuel economy, making it the smart choice for frequent city driving.',
    category: 'hatchback', year: 2023,
    specs: { engine: '1.5L K15B', power: '103 hp', torque: '138 Nm', seats: 5, doors: 5, luggage: 320, transmission: 'auto', fuel: 'petrol', year: 2023 },
    pricing: { daily: 75, weekly: 70, monthly: 1650, excessPerKm: 0.50, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 1000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgBaleno, exterior: [imgBaleno], interior: [imgBaleno] },
    colors: [{ name: 'Arctic White', hex: '#F2F0EC' }, { name: 'Graphite Grey', hex: '#4A4A4A' }],
    features: ['5 Seats', 'Automatic', 'Hatchback', 'A/C', 'Bluetooth', 'Keyless Entry', 'Rear Parking Aid'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: false, isPopular: false, isNewArrival: false, available: true,
    rating: 4.4, reviewCount: 18, minDriverAge: 21, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['mg3', 'kia-pegas', 'suzuki-ciaz'],
    seoTitle: 'Rent Suzuki Baleno Dubai | AED 75/day | Falcon View',
    seoDescription: 'Rent the Suzuki Baleno hatchback in Dubai for AED 75/day. Efficient, comfortable, free delivery. Book via WhatsApp.',
    keywords: ['suzuki baleno rental dubai', 'hatchback rental uae', 'fuel efficient rental dubai'],
    pricePerDay: 75, pricePerWeek: 70 * 7,
    cat: 'hatchback', trans: 'auto', fuel: 'petrol', seats: 5, price: 75, img: imgBaleno, specs_legacy: ['5 Seats', 'Hatchback', 'AED 75/day'],
  },

  // ── 6. Suzuki Ciaz ───────────────────────────────────────────
  {
    id: 6, slug: 'suzuki-ciaz', brand: 'Suzuki', model: 'Ciaz',
    name: 'Suzuki Ciaz',
    tagline: 'Elegant Sedan — Premium Ride on a Budget',
    description: 'The Suzuki Ciaz stands out with its elegant, long-body silhouette and premium interior feel. Offering one of the most spacious cabins in its class, it\'s ideal for families, business trips, or anyone wanting a comfortable, stress-free drive across Dubai.',
    category: 'sedan', year: 2023,
    specs: { engine: '1.5L K15B', power: '103 hp', torque: '138 Nm', seats: 5, doors: 4, luggage: 510, transmission: 'auto', fuel: 'petrol', year: 2023 },
    pricing: { daily: 75, weekly: 70, monthly: 1675, excessPerKm: 0.50, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 1000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgCiaz, exterior: [imgCiaz], interior: [imgCiaz] },
    colors: [{ name: 'Pearl White', hex: '#F8F6F2' }, { name: 'Premium Silver', hex: '#BBBAB5' }],
    features: ['5 Seats', 'Automatic', 'Petrol', 'A/C', 'Premium Audio', 'Cruise Control', 'Rear Camera'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: false, isPopular: false, isNewArrival: false, available: true,
    rating: 4.6, reviewCount: 31, minDriverAge: 21, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['nissan-sunny', 'mitsubishi-attrage', 'mg5'],
    seoTitle: 'Rent Suzuki Ciaz Dubai | AED 75/day | Falcon View',
    seoDescription: 'Rent the Suzuki Ciaz in Dubai for AED 75/day. Spacious premium sedan, free delivery, insurance included. Book now.',
    keywords: ['suzuki ciaz rental dubai', 'premium sedan rental uae', 'spacious car rental dubai'],
    pricePerDay: 75, pricePerWeek: 70 * 7,
    cat: 'sedan', trans: 'auto', fuel: 'petrol', seats: 5, price: 75, img: imgCiaz, specs_legacy: ['5 Seats', 'Auto', 'AED 75/day'],
  },

  // ── 7. MG 5 ──────────────────────────────────────────────────
  {
    id: 7, slug: 'mg5', brand: 'MG', model: 'MG5',
    name: 'MG 5',
    tagline: 'Bold Sedan — Sport-Inspired Design with Turbo Power',
    description: 'The MG 5 is Dubai\'s best-kept secret in the mid-range sedan segment. Its 1.5L turbocharged engine produces 169 hp — rivalling cars twice its price — while the sporty exterior design and driver-focused cockpit make every journey feel special.',
    category: 'sedan', year: 2023,
    specs: { engine: '1.5L Turbo', power: '169 hp', torque: '250 Nm', seats: 5, doors: 4, luggage: 450, transmission: 'auto', fuel: 'petrol', year: 2023 },
    pricing: { daily: 75, weekly: 70, monthly: 1700, excessPerKm: 0.50, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 1000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgMg5, exterior: [imgMg5], interior: [imgMg5] },
    colors: [{ name: 'Starry Black', hex: '#1A1A22' }, { name: 'Gallant Red', hex: '#C0392B' }],
    features: ['5 Seats', 'Automatic', '1.5T Petrol', '10" Touchscreen', 'ADAS', 'Panoramic Sunroof', 'LED Headlights'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: true, isPopular: true, isNewArrival: false, available: true, badge: 'Popular',
    rating: 4.7, reviewCount: 67, minDriverAge: 21, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['mg-gt', 'mazda6', 'suzuki-ciaz'],
    seoTitle: 'Rent MG5 Dubai | AED 75/day | Turbocharged Sedan | Falcon View',
    seoDescription: 'Rent the MG5 turbo sedan in Dubai for AED 75/day. 169 hp, panoramic roof, free delivery. The most popular sedan in our fleet.',
    keywords: ['mg5 rental dubai', 'turbo sedan rental dubai', 'sporty car rental uae'],
    pricePerDay: 75, pricePerWeek: 70 * 7,
    cat: 'sedan', trans: 'auto', fuel: 'petrol', seats: 5, price: 75, img: imgMg5, specs_legacy: ['5 Seats', '1.5 Turbo', 'AED 75/day'],
  },

  // ── 8. MG GT — ESTIMATED PRICING (not in client price sheet) ──
  {
    id: 8, slug: 'mg-gt', brand: 'MG', model: 'GT',
    name: 'MG GT',
    tagline: 'Sporty Fastback Sedan — Sleek, Fast & Connected',
    description: 'The MG GT is a fastback sedan that brings genuine sports-car drama to the Dubai roads. Its turbocharged 1.5L engine and sharp, sloping roofline make it a head-turner at every traffic light. Perfect for those who want style and performance without compromising practicality.',
    category: 'sedan', year: 2023,
    // ESTIMATED: Between MG5 (75) and Mazda 6 (110) — closest peer is MG5 at 75, slight premium for sportier profile
    specs: { engine: '1.5L Turbo', power: '173 hp', torque: '250 Nm', seats: 5, doors: 4, luggage: 380, transmission: 'auto', fuel: 'petrol', year: 2023 },
    pricing: { daily: 85, weekly: 80, monthly: 1900, excessPerKm: 0.50, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 1000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgMgGt, exterior: [imgMgGt], interior: [imgMgGt] },
    colors: [{ name: 'Solar Yellow', hex: '#F1C40F' }, { name: 'Midnight Black', hex: '#111111' }],
    features: ['5 Seats', 'Automatic', '1.5T Petrol', 'Fastback Design', '10.1" Touchscreen', 'LED DRL', 'Sporty Alloys'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: false, isPopular: false, isNewArrival: true, available: true, badge: 'New',
    rating: 4.6, reviewCount: 12, minDriverAge: 21, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['mg5', 'mazda6', 'kia-seltos'],
    seoTitle: 'Rent MG GT Dubai | AED 85/day | Sports Fastback | Falcon View',
    seoDescription: 'Rent the MG GT fastback sedan in Dubai for AED 85/day. Sporty, turbocharged, free delivery. Book via WhatsApp.',
    keywords: ['mg gt rental dubai', 'sports sedan rental dubai', 'fastback rental uae'],
    pricePerDay: 85, pricePerWeek: 80 * 7,
    cat: 'sedan', trans: 'auto', fuel: 'petrol', seats: 5, price: 85, img: imgMgGt, specs_legacy: ['5 Seats', 'Auto', 'AED 85/day'],
  },

  // ── 9. Mazda 6 ───────────────────────────────────────────────
  {
    id: 9, slug: 'mazda6', brand: 'Mazda', model: '6',
    name: 'Mazda 6',
    tagline: 'Executive Sedan — Japanese Craftsmanship, European Soul',
    description: 'The Mazda 6 is the executive choice that refuses to be ordinary. KODO design, a premium leather interior, and the spirited 2.5L SKYACTIV-G engine combine to create a driving experience that rivals European sedans at a fraction of the price. The ultimate business sedan in Dubai.',
    category: 'sedan', year: 2023,
    specs: { engine: '2.5L SKYACTIV-G', power: '192 hp', torque: '252 Nm', seats: 5, doors: 4, luggage: 480, transmission: 'auto', fuel: 'petrol', year: 2023 },
    pricing: { daily: 110, weekly: 100, monthly: 2400, excessPerKm: 0.50, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 2000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgMazda6, exterior: [imgMazda6], interior: [imgMazda6] },
    colors: [{ name: 'Machine Grey', hex: '#565C60' }, { name: 'Snowflake White', hex: '#F4F4F4' }],
    features: ['5 Seats', 'Automatic', '2.5L Petrol', 'Leather Seats', 'BOSE Audio', 'Head-Up Display', 'i-ACTIVSENSE'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: true, isPopular: false, isNewArrival: false, available: true, badge: 'Executive',
    rating: 4.8, reviewCount: 44, minDriverAge: 25, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['mg5', 'mg-gt', 'nissan-kicks'],
    seoTitle: 'Rent Mazda 6 Dubai | AED 110/day | Executive Sedan | Falcon View',
    seoDescription: 'Rent the Mazda 6 executive sedan in Dubai for AED 110/day. Leather interior, BOSE audio, free delivery. Book via WhatsApp.',
    keywords: ['mazda 6 rental dubai', 'executive sedan rental dubai', 'business car rental uae'],
    pricePerDay: 110, pricePerWeek: 100 * 7,
    cat: 'sedan', trans: 'auto', fuel: 'petrol', seats: 5, price: 110, img: imgMazda6, specs_legacy: ['5 Seats', '2.5L', 'Leather'],
  },

  // ── 10. Nissan Kicks ─────────────────────────────────────────
  {
    id: 10, slug: 'nissan-kicks', brand: 'Nissan', model: 'Kicks',
    name: 'Nissan Kicks',
    tagline: 'Crossover SUV — Urban Style & Elevated Space',
    description: 'The Nissan Kicks brings crossover practicality to Dubai\'s urban landscape. Its elevated ride height, spacious interior, and modern technology suite make it perfect for city explorations and weekend desert escapes alike. Comfortable for 5 adults with generous boot space.',
    category: 'suv', year: 2023,
    specs: { engine: '1.6L DOHC', power: '122 hp', torque: '156 Nm', seats: 5, doors: 5, luggage: 432, transmission: 'auto', fuel: 'petrol', year: 2023 },
    pricing: { daily: 120, weekly: 110, monthly: 2400, excessPerKm: 0.50, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 2000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgKicks, exterior: [imgKicks], interior: [imgKicks] },
    colors: [{ name: 'Deep Blue', hex: '#1A3A5C' }, { name: 'Ivory Pearl', hex: '#EDE8DC' }],
    features: ['5 Seats', 'Automatic', 'Crossover SUV', 'ProPilot Assist', '8" Touchscreen', 'Apple CarPlay', 'Dual-Zone A/C'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: false, isPopular: true, isNewArrival: false, available: true,
    rating: 4.6, reviewCount: 55, minDriverAge: 21, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['kaiyi-x3-pro', 'kia-seltos', 'hyundai-creta'],
    seoTitle: 'Rent Nissan Kicks Dubai | AED 120/day | Crossover SUV | Falcon View',
    seoDescription: 'Rent the Nissan Kicks crossover SUV in Dubai for AED 120/day. ProPilot assist, free delivery. Book via WhatsApp.',
    keywords: ['nissan kicks rental dubai', 'crossover rental dubai', 'suv rental uae'],
    pricePerDay: 120, pricePerWeek: 110 * 7,
    cat: 'suv', trans: 'auto', fuel: 'petrol', seats: 5, price: 120, img: imgKicks, specs_legacy: ['5 Seats', 'Crossover', 'AED 120/day'],
  },

  // ── 11. Kaiyi X3 Pro ─────────────────────────────────────────
  {
    id: 11, slug: 'kaiyi-x3-pro', brand: 'Kaiyi', model: 'X3 Pro',
    name: 'Kaiyi X3 Pro',
    tagline: 'Feature-Rich SUV — Premium Tech, Exceptional Value',
    description: 'The Kaiyi X3 Pro is Dubai\'s best-kept SUV secret. Its 1.5L turbocharged engine delivers an impressive 177 hp while the panoramic sunroof, 12" infotainment screen, and advanced driver assistance systems rival cars costing significantly more. Outstanding value in the compact SUV segment.',
    category: 'suv', year: 2024,
    specs: { engine: '1.5L Turbo', power: '177 hp', torque: '270 Nm', seats: 5, doors: 5, luggage: 395, transmission: 'auto', fuel: 'petrol', year: 2024 },
    pricing: { daily: 120, weekly: 110, monthly: 2400, excessPerKm: 0.50, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 2000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgKaiyix3, exterior: [imgKaiyix3], interior: [imgKaiyix3] },
    colors: [{ name: 'Arctic White', hex: '#F5F5F0' }, { name: 'Galaxy Black', hex: '#101010' }],
    features: ['5 Seats', 'Automatic', '1.5T Petrol', 'Panoramic Sunroof', '12" Touchscreen', 'ADAS Suite', '360° Camera'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: false, isPopular: false, isNewArrival: true, available: true, badge: 'New 2024',
    rating: 4.7, reviewCount: 21, minDriverAge: 21, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['nissan-kicks', 'kia-seltos', 'hyundai-creta'],
    seoTitle: 'Rent Kaiyi X3 Pro Dubai | AED 120/day | 2024 Turbo SUV | Falcon View',
    seoDescription: 'Rent the 2024 Kaiyi X3 Pro SUV in Dubai for AED 120/day. 177 hp, panoramic roof, 360° camera, free delivery.',
    keywords: ['kaiyi x3 pro rental dubai', 'suv rental dubai 2024', 'compact suv rental uae'],
    pricePerDay: 120, pricePerWeek: 110 * 7,
    cat: 'suv', trans: 'auto', fuel: 'petrol', seats: 5, price: 120, img: imgKaiyix3, specs_legacy: ['5 Seats', '1.5 Turbo', 'Panoroof'],
  },

  // ── 12. Kia Seltos ───────────────────────────────────────────
  {
    id: 12, slug: 'kia-seltos', brand: 'Kia', model: 'Seltos',
    name: 'Kia Seltos',
    tagline: 'Premium Compact SUV — Bold, Capable & Connected',
    description: 'The Kia Seltos raises the bar in the compact SUV segment with its assertive styling, turbocharged performance, and comprehensive safety suite. Whether navigating Dubai\'s downtown grid or heading to the mountains, the Seltos delivers confidence and comfort in equal measure.',
    category: 'suv', year: 2024,
    specs: { engine: '1.5L Turbo GDi', power: '158 hp', torque: '253 Nm', seats: 5, doors: 5, luggage: 433, transmission: 'auto', fuel: 'petrol', year: 2024 },
    pricing: { daily: 130, weekly: 120, monthly: 2450, excessPerKm: 0.50, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 2000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgSeltos, exterior: [imgSeltos], interior: [imgSeltos] },
    colors: [{ name: 'Intense Blue', hex: '#1A3A8A' }, { name: 'Gravity Grey', hex: '#3D3D3D' }],
    features: ['5 Seats', 'Automatic', '1.5T GDi', 'Lane Keeping', 'Blind Spot', '10.25" Display', 'Wireless CarPlay'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: true, isPopular: true, isNewArrival: false, available: true, badge: 'Trending',
    rating: 4.8, reviewCount: 73, minDriverAge: 21, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['hyundai-creta', 'nissan-kicks', 'kaiyi-x3-pro'],
    seoTitle: 'Rent Kia Seltos Dubai | AED 130/day | Premium SUV | Falcon View',
    seoDescription: 'Rent the 2024 Kia Seltos in Dubai for AED 130/day. Turbocharged, fully loaded, free delivery. Our most sought-after SUV.',
    keywords: ['kia seltos rental dubai', 'premium suv rental dubai', 'kia rental uae'],
    pricePerDay: 130, pricePerWeek: 120 * 7,
    cat: 'suv', trans: 'auto', fuel: 'petrol', seats: 5, price: 130, img: imgSeltos, specs_legacy: ['5 Seats', '1.5 Turbo', 'ADAS'],
  },

  // ── 13. Hyundai Creta ────────────────────────────────────────
  {
    id: 13, slug: 'hyundai-creta', brand: 'Hyundai', model: 'Creta',
    name: 'Hyundai Creta',
    tagline: 'Family SUV — Space, Comfort & Safety First',
    description: 'The Hyundai Creta has earned its reputation as the most trusted family SUV in the UAE. Spacious enough for the whole family, tech-rich enough for the daily commute, and comfortable enough for long highway drives. Its BlueLink connected car tech keeps you in control, always.',
    category: 'suv', year: 2024,
    specs: { engine: '1.5L MPi', power: '113 hp', torque: '144 Nm', seats: 5, doors: 5, luggage: 433, transmission: 'auto', fuel: 'petrol', year: 2024 },
    pricing: { daily: 130, weekly: 120, monthly: 2450, excessPerKm: 0.50, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 2000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgCreta, exterior: [imgCreta], interior: [imgCreta] },
    colors: [{ name: 'Typhoon Silver', hex: '#9A9EA0' }, { name: 'Abyss Black', hex: '#131315' }],
    features: ['5 Seats', 'Automatic', 'Petrol', 'BlueLink Connected', 'Sunroof', 'Ventilated Seats', '360° Camera'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: false, isPopular: true, isNewArrival: false, available: true,
    rating: 4.7, reviewCount: 88, minDriverAge: 21, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['kia-seltos', 'nissan-kicks', 'toyota-rush'],
    seoTitle: 'Rent Hyundai Creta Dubai | AED 130/day | Family SUV | Falcon View',
    seoDescription: 'Rent the 2024 Hyundai Creta in Dubai for AED 130/day. Family-friendly SUV, BlueLink connected, free delivery. Book now.',
    keywords: ['hyundai creta rental dubai', 'family suv rental dubai', 'hyundai rental uae'],
    pricePerDay: 130, pricePerWeek: 120 * 7,
    cat: 'suv', trans: 'auto', fuel: 'petrol', seats: 5, price: 130, img: imgCreta, specs_legacy: ['5 Seats', 'SUV', 'BlueLink'],
  },

  // ── 14. Toyota Rush ──────────────────────────────────────────
  {
    id: 14, slug: 'toyota-rush', brand: 'Toyota', model: 'Rush',
    name: 'Toyota Rush',
    tagline: '7-Seat SUV — Adventure Ready, Family Approved',
    description: 'The Toyota Rush proves that adventure and family comfort need not be a compromise. Its 7-seat configuration, commanding ride height, and Toyota\'s legendary reliability make it the go-to choice for group travel across Dubai and weekend excursions to Hatta or Fujairah.',
    category: '7seater', year: 2023,
    specs: { engine: '1.5L Dual VVT-i', power: '103 hp', torque: '136 Nm', seats: 7, doors: 5, luggage: 200, transmission: 'auto', fuel: 'petrol', year: 2023 },
    pricing: { daily: 140, weekly: 125, monthly: 2600, excessPerKm: 0.50, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 2000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgRush, exterior: [imgRush], interior: [imgRush] },
    colors: [{ name: 'Super White', hex: '#F8F8F8' }, { name: 'Dark Red Mica', hex: '#7A1A1A' }],
    features: ['7 Seats', 'Automatic', 'Petrol', '220mm Ground Clearance', 'Dual Row Seating', 'Fold-flat 3rd Row', 'Rear A/C'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: true, isPopular: true, isNewArrival: false, available: true, badge: 'Family Choice',
    rating: 4.7, reviewCount: 62, minDriverAge: 21, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['mitsubishi-xpander', 'hyundai-creta', 'mitsubishi-xpander-cross'],
    seoTitle: 'Rent Toyota Rush Dubai | AED 140/day | 7-Seater SUV | Falcon View',
    seoDescription: 'Rent the Toyota Rush 7-seater SUV in Dubai for AED 140/day. Reliable, spacious, free delivery. Perfect for groups.',
    keywords: ['toyota rush rental dubai', '7 seater rental dubai', 'group car rental uae'],
    pricePerDay: 140, pricePerWeek: 125 * 7,
    cat: '7seater', trans: 'auto', fuel: 'petrol', seats: 7, price: 140, img: imgRush, specs_legacy: ['7 Seats', '4x2', '220mm clearance'],
  },

  // ── 15. Mitsubishi Xpander ───────────────────────────────────
  {
    id: 15, slug: 'mitsubishi-xpander', brand: 'Mitsubishi', model: 'Xpander',
    name: 'Mitsubishi Xpander',
    tagline: '7-Seat MPV — Refined, Spacious People-Mover',
    description: 'The Mitsubishi Xpander redefines the people-mover category. Unlike traditional MPVs, it combines car-like styling with van-like space — offering 7 adult seats, sliding rear doors, and a beautifully appointed interior. Perfect for families and larger groups exploring Dubai in style.',
    category: '7seater', year: 2024,
    specs: { engine: '1.5L MIVEC', power: '103 hp', torque: '141 Nm', seats: 7, doors: 5, luggage: 180, transmission: 'auto', fuel: 'petrol', year: 2024 },
    pricing: { daily: 150, weekly: 130, monthly: 2600, excessPerKm: 0.50, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 2000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgXpander, exterior: [imgXpander], interior: [imgXpander] },
    colors: [{ name: 'Sterling Silver', hex: '#BBBAB5' }, { name: 'Quartz Black', hex: '#141414' }],
    features: ['7 Seats', 'Automatic', 'MPV', 'One-Touch Sliding Doors', 'Captain Seats Option', 'Rear Entertainment', 'Tri-Zone A/C'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: false, isPopular: false, isNewArrival: false, available: true,
    rating: 4.6, reviewCount: 41, minDriverAge: 21, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['mitsubishi-xpander-cross', 'toyota-rush', 'mitsubishi-destinator'],
    seoTitle: 'Rent Mitsubishi Xpander Dubai | AED 150/day | 7-Seat MPV | Falcon View',
    seoDescription: 'Rent the Mitsubishi Xpander 7-seat MPV in Dubai for AED 150/day. Spacious, comfortable, free delivery. Book now.',
    keywords: ['mitsubishi xpander rental dubai', '7 seat mpv rental dubai', 'minivan rental uae'],
    pricePerDay: 150, pricePerWeek: 130 * 7,
    cat: '7seater', trans: 'auto', fuel: 'petrol', seats: 7, price: 150, img: imgXpander, specs_legacy: ['7 Seats', 'MPV', 'Sliding Doors'],
  },

  // ── 16. Mitsubishi Xpander Cross — ESTIMATED PRICING ─────────
  {
    id: 16, slug: 'mitsubishi-xpander-cross', brand: 'Mitsubishi', model: 'Xpander Cross',
    name: 'Mitsubishi Xpander Cross',
    tagline: 'Rugged 7-Seat MPV — Off-Road Capability Meets Family Space',
    description: 'The Mitsubishi Xpander Cross takes the versatile Xpander platform and elevates it with enhanced ground clearance, rugged body cladding, and all-terrain capability. Ideal for families who want the practicality of a 7-seat MPV with the confidence to tackle desert terrain and mountain roads.',
    category: '7seater', year: 2024,
    // ESTIMATED: Premium over Xpander (150), estimated at 160/day based on rugged variant premium
    specs: { engine: '1.5L MIVEC', power: '103 hp', torque: '141 Nm', seats: 7, doors: 5, luggage: 200, transmission: 'auto', fuel: 'petrol', year: 2024 },
    pricing: { daily: 160, weekly: 140, monthly: 2800, excessPerKm: 0.50, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 2000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgXpanderCross, exterior: [imgXpanderCross], interior: [imgXpanderCross] },
    colors: [{ name: 'Sterling Silver', hex: '#BBBAB5' }, { name: 'Diamond White', hex: '#F0F0F0' }],
    features: ['7 Seats', 'Automatic', 'All-Terrain', 'Higher Ground Clearance', 'Rugged Body Kit', 'Off-Road Mode', 'AWD Ready'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: false, isPopular: false, isNewArrival: true, available: true, badge: 'New',
    rating: 4.7, reviewCount: 16, minDriverAge: 21, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['mitsubishi-xpander', 'toyota-rush', 'nissan-xterra'],
    seoTitle: 'Rent Mitsubishi Xpander Cross Dubai | AED 160/day | 7-Seat Off-Road MPV',
    seoDescription: 'Rent the Mitsubishi Xpander Cross 7-seater in Dubai for AED 160/day. Off-road capable, spacious, free delivery.',
    keywords: ['xpander cross rental dubai', '7 seat suv rental dubai', 'off road mpv rental uae'],
    pricePerDay: 160, pricePerWeek: 140 * 7,
    cat: '7seater', trans: 'auto', fuel: 'petrol', seats: 7, price: 160, img: imgXpanderCross, specs_legacy: ['7 Seats', 'All-Terrain', 'AED 160/day'],
  },

  // ── 17. Mitsubishi Destinator ────────────────────────────────
  {
    id: 17, slug: 'mitsubishi-destinator', brand: 'Mitsubishi', model: 'Destinator',
    name: 'Mitsubishi Destinator',
    tagline: '7-Seat Premium MPV — Long-Journey Luxury for Families',
    description: 'The Mitsubishi Destinator is a premium large MPV designed for maximum comfort on long journeys. Its 2.4L MIVEC engine provides effortless power, while captain seats, tri-zone climate control, and an entertainment system ensure every passenger arrives refreshed. The premium choice for airport transfers and family road trips.',
    category: '7seater', year: 2024,
    specs: { engine: '2.4L MIVEC', power: '128 hp', torque: '199 Nm', seats: 7, doors: 5, luggage: 220, transmission: 'auto', fuel: 'petrol', year: 2024 },
    pricing: { daily: 180, weekly: 160, monthly: 3000, excessPerKm: 0.50, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 2000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgDestinator, exterior: [imgDestinator], interior: [imgDestinator] },
    colors: [{ name: 'Pitch Black', hex: '#111111' }, { name: 'Ivory White', hex: '#F0EDE5' }],
    features: ['7 Seats', 'Automatic', '2.4L Petrol', 'Captain Seats', 'Tri-Zone A/C', 'Rear Entertainment', 'Power Sliding Doors'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: true, isPopular: false, isNewArrival: false, available: true, badge: 'Premium MPV',
    rating: 4.8, reviewCount: 34, minDriverAge: 25, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['mitsubishi-xpander', 'nissan-xterra', 'nissan-patrol-2026'],
    seoTitle: 'Rent Mitsubishi Destinator Dubai | AED 180/day | Premium 7-Seat MPV',
    seoDescription: 'Rent the Mitsubishi Destinator premium MPV in Dubai for AED 180/day. 7 captain seats, tri-zone A/C, free delivery.',
    keywords: ['mitsubishi destinator rental dubai', 'premium mpv rental dubai', 'large family car rental uae'],
    pricePerDay: 180, pricePerWeek: 160 * 7,
    cat: '7seater', trans: 'auto', fuel: 'petrol', seats: 7, price: 180, img: imgDestinator, specs_legacy: ['7 Seats', '2.4L', 'Captain Seats'],
  },

  // ── 18. Nissan Xterra ────────────────────────────────────────
  {
    id: 18, slug: 'nissan-xterra', brand: 'Nissan', model: 'Xterra',
    name: 'Nissan Xterra',
    tagline: '7-Seat Off-Road SUV — Desert & Dune Ready',
    description: 'The Nissan Xterra is built for those who demand more from their SUV. Its powerful 4.0L V6 engine, proper 4WD system, and substantial ground clearance make it equally capable in Dubai\'s concrete jungle as on Liwa\'s towering dunes. A true off-road machine with 7-seat practicality.',
    category: '7seater', year: 2023,
    specs: { engine: '4.0L V6', power: '261 hp', torque: '385 Nm', seats: 7, doors: 5, luggage: 350, transmission: 'auto', fuel: 'petrol', year: 2023 },
    pricing: { daily: 220, weekly: 200, monthly: 3500, excessPerKm: 1.00, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 3000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgXterra, exterior: [imgXterra], interior: [imgXterra] },
    colors: [{ name: 'Super Black', hex: '#0A0A0A' }, { name: 'Sahara Bronze', hex: '#8C6A30' }],
    features: ['7 Seats', 'Automatic', '4.0L V6', '4WD', 'Off-Road Mode', 'Skid Plates', 'High Ground Clearance'],
    rentalIncludes: STANDARD_INCLUDES,
    faqs: STANDARD_FAQS,
    featured: true, isPopular: false, isNewArrival: false, available: true, badge: 'Off-Road',
    rating: 4.9, reviewCount: 28, minDriverAge: 25, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['mitsubishi-destinator', 'nissan-patrol-2026', 'toyota-rush'],
    seoTitle: 'Rent Nissan Xterra Dubai | AED 220/day | 4WD Off-Road 7-Seater | Falcon View',
    seoDescription: 'Rent the Nissan Xterra 4WD 7-seater in Dubai for AED 220/day. V6 engine, true 4WD, dune-ready. Book via WhatsApp.',
    keywords: ['nissan xterra rental dubai', 'off road rental dubai', '4wd rental uae'],
    pricePerDay: 220, pricePerWeek: 200 * 7,
    cat: '7seater', trans: 'auto', fuel: 'petrol', seats: 7, price: 220, img: imgXterra, specs_legacy: ['7 Seats', '4.0L V6', '4WD'],
  },

  // ── 19. Dodge Challenger ─────────────────────────────────────
  {
    id: 19, slug: 'dodge-challenger', brand: 'Dodge', model: 'Challenger',
    name: 'Dodge Challenger',
    tagline: 'American Muscle Coupe — Pure Power, Iconic Presence',
    description: 'Driving a Dodge Challenger in Dubai is an experience unlike any other. The thundering 3.6L Pentastar V6 exhaust note, the wide muscular stance, and the heads-turning presence on Sheikh Zayed Road create an unforgettable memory. This is not just a car — it\'s a statement.',
    category: 'coupe', year: 2024,
    specs: { engine: '3.6L Pentastar V6', power: '305 hp', torque: '363 Nm', seats: 4, doors: 2, luggage: 323, transmission: 'auto', fuel: 'petrol', year: 2024 },
    pricing: { daily: 250, weekly: 220, monthly: 4000, excessPerKm: 5.00, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 5000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgChallenger, exterior: [imgChallenger], interior: [imgChallenger] },
    colors: [{ name: 'Pitch Black', hex: '#0A0A0A' }, { name: 'TorRed', hex: '#CC0000' }],
    features: ['4 Seats', 'Automatic', '3.6L V6 305hp', 'Muscle Car', 'Harman Kardon Audio', 'Heated Seats', 'Performance Brakes'],
    rentalIncludes: [...STANDARD_INCLUDES, 'Professional handover briefing', 'Performance driving tips'],
    faqs: [
      ...STANDARD_FAQS,
      {
        question: 'Is there a special licence requirement for the Dodge Challenger?',
        answer: 'Yes. Due to the performance nature of this vehicle, the minimum driver age is 25 years and a valid licence held for at least 2 years is required.',
      },
    ],
    featured: true, isPopular: true, isNewArrival: false, available: true, badge: 'Muscle Icon',
    rating: 4.9, reviewCount: 91, minDriverAge: 25, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['nissan-xterra', 'nissan-patrol-2026', 'mazda6'],
    seoTitle: 'Rent Dodge Challenger Dubai | AED 250/day | American Muscle | Falcon View',
    seoDescription: 'Rent the Dodge Challenger V6 muscle car in Dubai for AED 250/day. 305 hp, iconic presence, free delivery. Book via WhatsApp.',
    keywords: ['dodge challenger rental dubai', 'muscle car rental dubai', 'coupe rental uae', 'american car rental dubai'],
    pricePerDay: 250, pricePerWeek: 220 * 7,
    cat: 'coupe', trans: 'auto', fuel: 'petrol', seats: 4, price: 250, img: imgChallenger, specs_legacy: ['4 Seats', '3.6L V6', '305 hp'],
  },

  // ── 20. 2026 Nissan Patrol ───────────────────────────────────
  {
    id: 20, slug: 'nissan-patrol-2026', brand: 'Nissan', model: 'Patrol 2026',
    name: '2026 Nissan Patrol',
    tagline: 'Flagship 7-Seat SUV — The Ultimate UAE Status Symbol',
    description: 'The 2026 Nissan Patrol is the undisputed king of UAE roads. A full-size luxury SUV with a 5.6L V8 producing 400 hp, it combines supreme off-road capability with a sumptuous interior fit for heads of state. Whether for VIP airport transfers, desert convoys, or making an impression — the Patrol delivers on every front.',
    category: '7seater', year: 2026,
    specs: { engine: '5.6L V8', power: '400 hp', torque: '560 Nm', seats: 7, doors: 5, luggage: 396, transmission: 'auto', fuel: 'petrol', year: 2026, zeroToSixty: '6.2s', topSpeed: '210 km/h' },
    pricing: { daily: 550, weekly: 500, monthly: 13000, excessPerKm: 5.00, kmsDaily: KMS_DAILY, kmsWeekly: KMS_WEEKLY, kmsMonthly: KMS_MONTHLY, deposit: 10000, salikSurcharge: SALIK, vatRate: VAT, deliveryFee: 0 },
    images: { thumbnail: imgPatrol, exterior: [imgPatrol], interior: [imgPatrol] },
    colors: [{ name: 'Royal Black', hex: '#060608' }, { name: 'Pearl White', hex: '#F5F3EE' }],
    features: ['7 Seats', 'Automatic', '5.6L V8 400hp', '4WD CRAWL', 'Nappa Leather', 'Bose Premium Audio', 'Massage Seats', 'Night Vision'],
    rentalIncludes: [...STANDARD_INCLUDES, 'Concierge delivery & pickup', 'Premium detailing before handover', 'Dedicated 24/7 VIP support line'],
    faqs: [
      ...STANDARD_FAQS,
      {
        question: 'Is the Patrol available for Oman border crossings?',
        answer: 'Yes, subject to availability. Please request the Oman border pass add-on when booking. Additional fees apply for Oman border documentation.',
      },
    ],
    featured: true, isPopular: true, isNewArrival: true, available: true, badge: '⭐ Flagship',
    rating: 5.0, reviewCount: 47, minDriverAge: 25, licenceRequired: ['UAE', 'GCC', 'International'],
    deliveryAvailable: true, relatedVehicles: ['nissan-xterra', 'mitsubishi-destinator', 'dodge-challenger'],
    seoTitle: 'Rent 2026 Nissan Patrol Dubai | AED 550/day | V8 Flagship SUV | Falcon View',
    seoDescription: 'Rent the 2026 Nissan Patrol V8 in Dubai for AED 550/day. 400 hp, full luxury, concierge delivery. The ultimate UAE experience.',
    keywords: ['nissan patrol rental dubai', 'v8 suv rental dubai', 'luxury suv rental uae', '2026 patrol rent'],
    pricePerDay: 550, pricePerWeek: 500 * 7,
    cat: '7seater', trans: 'auto', fuel: 'petrol', seats: 7, price: 550, img: imgPatrol, specs_legacy: ['7 Seats', '5.6L V8', 'Full Luxury'],
  },
];
