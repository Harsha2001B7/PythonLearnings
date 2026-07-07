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

export const FLEET_DATA: Vehicle[] = [
  {
    id: 1, slug: 'mitsubishi-attrage', name: 'Mitsubishi Attrage', tagline: 'Reliable Daily Sedan — Fuel-efficient & Comfortable',
    category: 'sedan', pricePerDay: 65, pricePerWeek: 60 * 7,
    specs: { engine: '1.2L MIVEC', power: '78 hp', torque: '100 Nm', seats: 5, transmission: 'auto', fuel: 'petrol', year: 2023, doors: 4 },
    images: { thumbnail: imgAttrage, exterior: [imgAttrage], interior: [imgAttrage] },
    colors: [{ name: 'White', hex: '#F5F5F0' }], features: ['5 Seats', 'Auto', 'AED 65/day', 'AED 1550/mo'],
    featured: false, available: true, badge: 'Best Value', cat: 'sedan', trans: 'auto', fuel: 'petrol', seats: 5, price: 65,
    img: imgAttrage, specs_legacy: ['5 Seats', 'Auto', 'AED 65/day'],
  },
  {
    id: 2, slug: 'nissan-sunny', name: 'Nissan Sunny', tagline: 'Spacious Sedan — Perfect for City & Highway',
    category: 'sedan', pricePerDay: 65, pricePerWeek: 60 * 7,
    specs: { engine: '1.5L DOHC', power: '99 hp', torque: '134 Nm', seats: 5, transmission: 'auto', fuel: 'petrol', year: 2023, doors: 4 },
    images: { thumbnail: imgSunny, exterior: [imgSunny], interior: [imgSunny] },
    colors: [{ name: 'Silver', hex: '#C8C8C8' }], features: ['5 Seats', 'Auto', 'AED 65/day', 'AED 1550/mo'],
    featured: false, available: true, cat: 'sedan', trans: 'auto', fuel: 'petrol', seats: 5, price: 65,
    img: imgSunny, specs_legacy: ['5 Seats', 'Auto', 'AED 65/day'],
  },
  {
    id: 3, slug: 'mg3', name: 'MG3', tagline: 'Stylish Hatchback — Fun, Nimble & Affordable',
    category: 'hatchback', pricePerDay: 70, pricePerWeek: 65 * 7,
    specs: { engine: '1.5L VTi', power: '109 hp', torque: '150 Nm', seats: 5, transmission: 'auto', fuel: 'petrol', year: 2023, doors: 5 },
    images: { thumbnail: imgMg3, exterior: [imgMg3], interior: [imgMg3] },
    colors: [{ name: 'Red', hex: '#C0392B' }], features: ['5 Seats', 'Auto', 'AED 70/day', 'AED 1650/mo'],
    featured: false, available: true, cat: 'hatchback', trans: 'auto', fuel: 'petrol', seats: 5, price: 70,
    img: imgMg3, specs_legacy: ['5 Seats', 'Auto', 'AED 70/day'],
  },
  {
    id: 4, slug: 'kia-pegas', name: 'Kia Pegas', tagline: 'Modern Sedan — Tech-Loaded Entry Package',
    category: 'sedan', pricePerDay: 70, pricePerWeek: 65 * 7,
    specs: { engine: '1.4L MPI', power: '100 hp', torque: '133 Nm', seats: 5, transmission: 'auto', fuel: 'petrol', year: 2023, doors: 4 },
    images: { thumbnail: imgPegas, exterior: [imgPegas], interior: [imgPegas] },
    colors: [{ name: 'White', hex: '#F0EDE8' }], features: ['5 Seats', 'Auto', 'AED 70/day', 'AED 1650/mo'],
    featured: false, available: true, cat: 'sedan', trans: 'auto', fuel: 'petrol', seats: 5, price: 70,
    img: imgPegas, specs_legacy: ['5 Seats', 'Auto', 'AED 70/day'],
  },
  {
    id: 5, slug: 'suzuki-baleno', name: 'Suzuki Baleno', tagline: 'Agile Hatchback — Great Fuel Economy',
    category: 'hatchback', pricePerDay: 75, pricePerWeek: 70 * 7,
    specs: { engine: '1.5L K15B', power: '103 hp', torque: '138 Nm', seats: 5, transmission: 'auto', fuel: 'petrol', year: 2023, doors: 5 },
    images: { thumbnail: imgBaleno, exterior: [imgBaleno], interior: [imgBaleno] },
    colors: [{ name: 'White', hex: '#F2F0EC' }], features: ['5 Seats', 'Auto', 'AED 75/day', 'AED 1650/mo'],
    featured: false, available: true, cat: 'hatchback', trans: 'auto', fuel: 'petrol', seats: 5, price: 75,
    img: imgBaleno, specs_legacy: ['5 Seats', 'Auto', 'AED 75/day'],
  },
  {
    id: 6, slug: 'suzuki-ciaz', name: 'Suzuki Ciaz', tagline: 'Elegant Sedan — Premium Ride on a Budget',
    category: 'sedan', pricePerDay: 75, pricePerWeek: 70 * 7,
    specs: { engine: '1.5L K15B', power: '103 hp', torque: '138 Nm', seats: 5, transmission: 'auto', fuel: 'petrol', year: 2023, doors: 4 },
    images: { thumbnail: imgCiaz, exterior: [imgCiaz], interior: [imgCiaz] },
    colors: [{ name: 'White', hex: '#F8F6F2' }], features: ['5 Seats', 'Auto', 'AED 75/day', 'AED 1675/mo'],
    featured: false, available: true, cat: 'sedan', trans: 'auto', fuel: 'petrol', seats: 5, price: 75,
    img: imgCiaz, specs_legacy: ['5 Seats', 'Auto', 'AED 75/day'],
  },
  {
    id: 7, slug: 'mg5', name: 'MG 5', tagline: 'Bold Sedan — Sport-Inspired Design',
    category: 'sedan', pricePerDay: 75, pricePerWeek: 70 * 7,
    specs: { engine: '1.5L Turbo', power: '169 hp', torque: '250 Nm', seats: 5, transmission: 'auto', fuel: 'petrol', year: 2023, doors: 4 },
    images: { thumbnail: imgMg5, exterior: [imgMg5], interior: [imgMg5] },
    colors: [{ name: 'Black', hex: '#1A1A22' }], features: ['5 Seats', 'Auto', 'AED 75/day', 'AED 1700/mo'],
    featured: true, available: true, badge: 'Popular', cat: 'sedan', trans: 'auto', fuel: 'petrol', seats: 5, price: 75,
    img: imgMg5, specs_legacy: ['5 Seats', 'Auto', 'AED 75/day'],
  },
  {
    id: 8, slug: 'mg-gt', name: 'MG GT', tagline: 'Sporty Sedan — Sleek & Fast',
    category: 'sedan', pricePerDay: 85, pricePerWeek: 80 * 7,
    specs: { engine: '1.5L Turbo', power: '173 hp', torque: '250 Nm', seats: 5, transmission: 'auto', fuel: 'petrol', year: 2023, doors: 4 },
    images: { thumbnail: imgMgGt, exterior: [imgMgGt], interior: [imgMgGt] },
    colors: [{ name: 'Yellow', hex: '#F1C40F' }], features: ['5 Seats', 'Auto', 'AED 85/day', 'AED 1900/mo'],
    featured: false, available: true, cat: 'sedan', trans: 'auto', fuel: 'petrol', seats: 5, price: 85,
    img: imgMgGt, specs_legacy: ['5 Seats', 'Auto', 'AED 85/day'],
  },
  {
    id: 9, slug: 'mazda6', name: 'Mazda 6', tagline: 'Executive Sedan — Premium Craftsmanship',
    category: 'sedan', pricePerDay: 110, pricePerWeek: 100 * 7,
    specs: { engine: '2.5L SKYACTIV-G', power: '192 hp', torque: '252 Nm', seats: 5, transmission: 'auto', fuel: 'petrol', year: 2023, doors: 4 },
    images: { thumbnail: imgMazda6, exterior: [imgMazda6], interior: [imgMazda6] },
    colors: [{ name: 'Grey', hex: '#565C60' }], features: ['5 Seats', 'Auto', 'AED 110/day', 'AED 2400/mo'],
    featured: true, available: true, badge: 'Executive', cat: 'sedan', trans: 'auto', fuel: 'petrol', seats: 5, price: 110,
    img: imgMazda6, specs_legacy: ['5 Seats', 'Auto', 'AED 110/day'],
  },
  {
    id: 10, slug: 'nissan-kicks', name: 'Nissan Kicks', tagline: 'Crossover SUV — Urban Style & Space',
    category: 'suv', pricePerDay: 120, pricePerWeek: 110 * 7,
    specs: { engine: '1.6L DOHC', power: '122 hp', torque: '156 Nm', seats: 5, transmission: 'auto', fuel: 'petrol', year: 2023, doors: 5 },
    images: { thumbnail: imgKicks, exterior: [imgKicks], interior: [imgKicks] },
    colors: [{ name: 'Blue', hex: '#1A3A5C' }], features: ['5 Seats', 'Auto', 'AED 120/day', 'AED 2400/mo'],
    featured: false, available: true, cat: 'suv', trans: 'auto', fuel: 'petrol', seats: 5, price: 120,
    img: imgKicks, specs_legacy: ['5 Seats', 'Auto', 'AED 120/day'],
  },
  {
    id: 11, slug: 'kaiyi-x3-pro', name: 'Kaiyi X3 Pro', tagline: 'Feature-Rich SUV — Value Packed',
    category: 'suv', pricePerDay: 120, pricePerWeek: 110 * 7,
    specs: { engine: '1.5L Turbo', power: '177 hp', torque: '270 Nm', seats: 5, transmission: 'auto', fuel: 'petrol', year: 2024, doors: 5 },
    images: { thumbnail: imgKaiyix3, exterior: [imgKaiyix3], interior: [imgKaiyix3] },
    colors: [{ name: 'White', hex: '#F5F5F0' }], features: ['5 Seats', 'Auto', 'AED 120/day', 'AED 2400/mo'],
    featured: false, available: true, cat: 'suv', trans: 'auto', fuel: 'petrol', seats: 5, price: 120,
    img: imgKaiyix3, specs_legacy: ['5 Seats', 'Auto', 'AED 120/day'],
  },
  {
    id: 12, slug: 'kia-seltos', name: 'Kia Seltos', tagline: 'Premium Compact SUV — Bold & Capable',
    category: 'suv', pricePerDay: 130, pricePerWeek: 120 * 7,
    specs: { engine: '1.5L Turbo GDi', power: '158 hp', torque: '253 Nm', seats: 5, transmission: 'auto', fuel: 'petrol', year: 2024, doors: 5 },
    images: { thumbnail: imgSeltos, exterior: [imgSeltos], interior: [imgSeltos] },
    colors: [{ name: 'Blue', hex: '#1A3A8A' }], features: ['5 Seats', 'Auto', 'AED 130/day', 'AED 2450/mo'],
    featured: true, available: true, badge: 'Trending', cat: 'suv', trans: 'auto', fuel: 'petrol', seats: 5, price: 130,
    img: imgSeltos, specs_legacy: ['5 Seats', 'Auto', 'AED 130/day'],
  },
  {
    id: 13, slug: 'hyundai-creta', name: 'Hyundai Creta', tagline: 'Family SUV — Space, Comfort & Safety',
    category: 'suv', pricePerDay: 130, pricePerWeek: 120 * 7,
    specs: { engine: '1.5L MPi', power: '113 hp', torque: '144 Nm', seats: 5, transmission: 'auto', fuel: 'petrol', year: 2024, doors: 5 },
    images: { thumbnail: imgCreta, exterior: [imgCreta], interior: [imgCreta] },
    colors: [{ name: 'Silver', hex: '#9A9EA0' }], features: ['5 Seats', 'Auto', 'AED 130/day', 'AED 2450/mo'],
    featured: false, available: true, cat: 'suv', trans: 'auto', fuel: 'petrol', seats: 5, price: 130,
    img: imgCreta, specs_legacy: ['5 Seats', 'Auto', 'AED 130/day'],
  },
  {
    id: 14, slug: 'toyota-rush', name: 'Toyota Rush', tagline: '7-Seat SUV — Adventure Ready Family Car',
    category: '7seater', pricePerDay: 140, pricePerWeek: 125 * 7,
    specs: { engine: '1.5L Dual VVT-i', power: '103 hp', torque: '136 Nm', seats: 7, transmission: 'auto', fuel: 'petrol', year: 2023, doors: 5 },
    images: { thumbnail: imgRush, exterior: [imgRush], interior: [imgRush] },
    colors: [{ name: 'White', hex: '#F8F8F8' }], features: ['7 Seats', 'Auto', 'AED 140/day', 'AED 2600/mo'],
    featured: true, available: true, badge: 'Family Choice', cat: '7seater', trans: 'auto', fuel: 'petrol', seats: 7, price: 140,
    img: imgRush, specs_legacy: ['7 Seats', 'Auto', 'AED 140/day'],
  },
  {
    id: 15, slug: 'mitsubishi-xpander', name: 'Mitsubishi Xpander', tagline: '7-Seat MPV — Refined Family People-Mover',
    category: '7seater', pricePerDay: 150, pricePerWeek: 130 * 7,
    specs: { engine: '1.5L MIVEC', power: '103 hp', torque: '141 Nm', seats: 7, transmission: 'auto', fuel: 'petrol', year: 2024, doors: 5 },
    images: { thumbnail: imgXpander, exterior: [imgXpander], interior: [imgXpander] },
    colors: [{ name: 'Silver', hex: '#BBBAB5' }], features: ['7 Seats', 'Auto', 'AED 150/day', 'AED 2600/mo'],
    featured: false, available: true, cat: '7seater', trans: 'auto', fuel: 'petrol', seats: 7, price: 150,
    img: imgXpander, specs_legacy: ['7 Seats', 'Auto', 'AED 150/day'],
  },
  {
    id: 16, slug: 'mitsubishi-xpander-cross', name: 'Mitsubishi Xpander Cross', tagline: 'Rugged 7-Seat MPV — Higher Ground Clearance',
    category: '7seater', pricePerDay: 160, pricePerWeek: 140 * 7,
    specs: { engine: '1.5L MIVEC', power: '103 hp', torque: '141 Nm', seats: 7, transmission: 'auto', fuel: 'petrol', year: 2024, doors: 5 },
    images: { thumbnail: imgXpanderCross, exterior: [imgXpanderCross], interior: [imgXpanderCross] },
    colors: [{ name: 'Silver', hex: '#BBBAB5' }], features: ['7 Seats', 'Auto', 'AED 160/day', 'AED 2800/mo'],
    featured: false, available: true, cat: '7seater', trans: 'auto', fuel: 'petrol', seats: 7, price: 160,
    img: imgXpanderCross, specs_legacy: ['7 Seats', 'Auto', 'AED 160/day'],
  },
  {
    id: 17, slug: 'mitsubishi-destinator', name: 'Mitsubishi Destinator', tagline: '7-Seat Premium MPV — Long Journey Comfort',
    category: '7seater', pricePerDay: 180, pricePerWeek: 160 * 7,
    specs: { engine: '2.4L MIVEC', power: '128 hp', torque: '199 Nm', seats: 7, transmission: 'auto', fuel: 'petrol', year: 2024, doors: 5 },
    images: { thumbnail: imgDestinator, exterior: [imgDestinator], interior: [imgDestinator] },
    colors: [{ name: 'Black', hex: '#111111' }], features: ['7 Seats', 'Auto', 'AED 180/day', 'AED 3000/mo'],
    featured: true, available: true, badge: 'Premium MPV', cat: '7seater', trans: 'auto', fuel: 'petrol', seats: 7, price: 180,
    img: imgDestinator, specs_legacy: ['7 Seats', 'Auto', 'AED 180/day'],
  },
  {
    id: 18, slug: 'nissan-xterra', name: 'Nissan Xterra', tagline: '7-Seat Off-Road SUV — Desert & Dune Ready',
    category: '7seater', pricePerDay: 220, pricePerWeek: 200 * 7,
    specs: { engine: '4.0L V6', power: '261 hp', torque: '385 Nm', seats: 7, transmission: 'auto', fuel: 'petrol', year: 2023, doors: 5 },
    images: { thumbnail: imgXterra, exterior: [imgXterra], interior: [imgXterra] },
    colors: [{ name: 'Black', hex: '#0A0A0A' }], features: ['7 Seats', 'Auto', 'AED 220/day', 'AED 3500/mo'],
    featured: true, available: true, badge: 'Off-Road', cat: '7seater', trans: 'auto', fuel: 'petrol', seats: 7, price: 220,
    img: imgXterra, specs_legacy: ['7 Seats', 'Auto', 'AED 220/day'],
  },
  {
    id: 19, slug: 'dodge-challenger', name: 'Dodge Challenger', tagline: 'American Muscle Coupe — Pure Power & Presence',
    category: 'coupe', pricePerDay: 250, pricePerWeek: 220 * 7,
    specs: { engine: '3.6L Pentastar V6', power: '305 hp', torque: '363 Nm', seats: 4, transmission: 'auto', fuel: 'petrol', year: 2024, doors: 2 },
    images: { thumbnail: imgChallenger, exterior: [imgChallenger], interior: [imgChallenger] },
    colors: [{ name: 'Black', hex: '#0A0A0A' }], features: ['4 Seats', 'Auto', 'AED 250/day', 'AED 4000/mo'],
    featured: true, available: true, badge: 'Muscle Icon', cat: 'coupe', trans: 'auto', fuel: 'petrol', seats: 4, price: 250,
    img: imgChallenger, specs_legacy: ['4 Seats', 'Auto', 'AED 250/day'],
  },
  {
    id: 20, slug: 'nissan-patrol-2026', name: '2026 Nissan Patrol', tagline: 'Flagship 7-Seat SUV — Ultimate UAE Status Symbol',
    category: '7seater', pricePerDay: 550, pricePerWeek: 500 * 7,
    specs: { engine: '5.6L V8', power: '400 hp', torque: '560 Nm', seats: 7, transmission: 'auto', fuel: 'petrol', year: 2026, doors: 5 },
    images: { thumbnail: imgPatrol, exterior: [imgPatrol], interior: [imgPatrol] },
    colors: [{ name: 'Black', hex: '#060608' }], features: ['7 Seats', 'Auto', 'AED 550/day', 'AED 13000/mo'],
    featured: true, available: true, badge: '⭐ Flagship', cat: '7seater', trans: 'auto', fuel: 'petrol', seats: 7, price: 550,
    img: imgPatrol, specs_legacy: ['7 Seats', 'Auto', 'AED 550/day'],
  },
];
