// ─────────────────────────────────────────────────────────────────
// Falcon View Car Rentals — Shared TypeScript Interfaces
// ─────────────────────────────────────────────────────────────────

export type VehicleCategory = 'coupe' | 'sedan' | 'suv' | 'ev' | 'van' | 'roadster' | 'hatchback' | '7seater';
export type TransmissionType = 'auto' | 'manual';
export type FuelType = 'electric' | 'petrol' | 'hybrid' | 'diesel';

export interface VehicleSpecs {
  engine?: string;
  power?: string;
  torque?: string;
  range?: string;
  zeroToSixty?: string;
  topSpeed?: string;
  seats: number;
  doors?: number;
  luggage?: number; // litres
  transmission: TransmissionType;
  fuel: FuelType;
  year?: number;
}

export interface VehiclePricing {
  daily: number;        // AED — 1-6 days
  weekly: number;       // AED — 7-29 days
  monthly: number;      // AED — 30+ days
  excessPerKm: number;  // AED per km over limit
  kmsDaily: number;     // km allowed per day rental
  kmsWeekly: number;    // km allowed per week rental
  kmsMonthly: number;   // km allowed per month rental
  deposit?: number;     // AED refundable deposit
  salikSurcharge: number; // AED per toll
  vatRate: number;      // percentage e.g. 5
  deliveryFee?: number; // AED per delivery, 0 = free
}

export interface VehicleImages {
  exterior: string[];
  interior: string[];
  thumbnail: string;
}

export interface VehicleColor {
  name: string;
  hex: string;
}

export interface RentalInclude {
  icon: string;
  label: string;
}

export interface VehicleFAQ {
  question: string;
  answer: string;
}

export interface Vehicle {
  id: number;
  slug: string;
  name: string;
  brand: string;
  model: string;
  tagline: string;
  description: string;
  category: VehicleCategory;
  year?: number;
  specs: VehicleSpecs;
  pricing: VehiclePricing;
  images: VehicleImages;
  colors: VehicleColor[];
  features: string[];
  rentalIncludes: string[];
  faqs?: VehicleFAQ[];
  featured: boolean;
  isNewArrival?: boolean;
  isPopular?: boolean;
  available: boolean;
  badge?: string;
  rating: number;
  reviewCount: number;
  minDriverAge: number;
  licenceRequired: string[];
  deliveryAvailable: boolean;
  relatedVehicles?: string[]; // slugs
  seoTitle: string;
  seoDescription: string;
  keywords: string[];

  // Computed convenience fields (pricePerDay === pricing.daily)
  pricePerDay: number;
  pricePerWeek: number;

  // Legacy flat fields — kept so existing components don't break
  /** @deprecated use category */ cat: VehicleCategory;
  /** @deprecated use specs.transmission */ trans: TransmissionType;
  /** @deprecated use specs.fuel */ fuel: FuelType;
  /** @deprecated use specs.seats */ seats: number;
  /** @deprecated use pricePerDay */ price: number;
  /** @deprecated use images.thumbnail */ img: string;
  /** @deprecated use features */ specs_legacy: string[];
}

// ─────────────────────────────────────────────────────────────────

export type MembershipTierName = 'Scout' | 'Vantage' | 'Apex';

export interface MembershipFeature {
  text: string;
  included: boolean;
}

export interface MembershipTier {
  id: number;
  name: MembershipTierName;
  tagline: string;
  pricePerMonth: number;
  pricePerYear?: number;
  features: MembershipFeature[];
  highlighted: boolean;
  badge?: string;
  ctaLabel: string;
  accentColor?: string;
}

// ─────────────────────────────────────────────────────────────────

export interface Testimonial {
  id: number;
  authorName: string;
  authorInitials: string;
  avatarColor: string;
  role: string;
  company?: string;
  rating: number;
  text: string;
  date: string;
  membershipTier?: MembershipTierName;
}

// ─────────────────────────────────────────────────────────────────

export type FAQCategory = 'booking' | 'insurance' | 'delivery' | 'pricing' | 'membership' | 'fleet';

export interface FAQItem {
  id: number;
  question: string;
  answer: string;
  category: FAQCategory;
}

// ─────────────────────────────────────────────────────────────────
// Booking & UI State
// ─────────────────────────────────────────────────────────────────

export interface BookingFormState {
  deliveryLocation: string;
  returnLocation: string;
  returnLocationSame: boolean;
  pickupDate: Date | null;
  returnDate: Date | null;
  carType: string;
  driverAge: string;
  licence: string;
  promoCode: string;
  extras: string[];
}

export type ChatRole = 'user' | 'assistant';

export interface ChatMessage {
  id: string;
  role: ChatRole;
  text: string;
  timestamp: number;
  isTyping?: boolean;
}

export interface ToastItem {
  id: number;
  message: string;
  type?: 'success' | 'info' | 'error';
}

export interface FilterState {
  category: string;
  maxPrice: number;
  transmission: string;
  fuel: string;
  seats: string;
  search: string;
  deliveryOnly: boolean;
  sortBy: 'price_asc' | 'price_desc' | 'name' | 'featured';
}

// Legacy alias
export interface Toast extends ToastItem {}

// Booking store type
export interface BookingState {
  pickup: string;
  dropoff: string;
  pickupDate: string;
  returnDate: string;
  vehicleCategory: string;
  selectedVehicleName: string | null;
}
