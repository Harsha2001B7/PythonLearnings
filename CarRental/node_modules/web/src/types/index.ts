// ─────────────────────────────────────────────────────────────────
// VANTA — Shared TypeScript Interfaces
// Structured as if they came from an API — swapping in real
// endpoints later is a single-file change in src/data/*.ts.
// All types are named exports — no default export.
// ─────────────────────────────────────────────────────────────────

export type VehicleCategory = 'coupe' | 'sedan' | 'suv' | 'ev' | 'van' | 'roadster' | 'hatchback' | '7seater';
export type TransmissionType = 'auto' | 'manual';
export type FuelType = 'electric' | 'petrol' | 'hybrid' | 'diesel';

export interface VehicleSpecs {
  engine?: string;
  power?: string;
  torque?: string;
  range?: string;         // EV range in km
  zeroToSixty?: string;   // 0–60 mph in seconds
  topSpeed?: string;
  seats: number;
  transmission: TransmissionType;
  fuel: FuelType;
  year?: number;
  doors?: number;
}

export interface VehicleImages {
  exterior: string[];   // Array of image URLs (CDN)
  interior: string[];
  thumbnail: string;    // Hero card image
}

export interface Vehicle {
  id: number;
  slug: string;
  name: string;
  tagline: string;
  category: VehicleCategory;
  pricePerDay: number;    // in AED
  pricePerWeek?: number;
  specs: VehicleSpecs;
  images: VehicleImages;
  colors: VehicleColor[];
  features: string[];     // short feature list for cards
  featured: boolean;
  available: boolean;
  badge?: string;         // e.g. "New Arrival", "Most Popular", "Editor's Pick"

  // Legacy flat fields — kept so existing components don't break
  /** @deprecated use category */ cat: VehicleCategory;
  /** @deprecated use specs.transmission */ trans: TransmissionType;
  /** @deprecated use specs.fuel */ fuel: FuelType;
  /** @deprecated use specs.seats */ seats: number;
  /** @deprecated use pricePerDay */ price: number;
  /** @deprecated use images.thumbnail */ img: string;
  /** @deprecated use features */ specs_legacy: string[];
}

export interface VehicleColor {
  name: string;
  hex: string;
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
  pricePerMonth: number;     // AED — 0 for free tiers
  pricePerYear?: number;
  features: MembershipFeature[];
  highlighted: boolean;      // "featured" card
  badge?: string;
  ctaLabel: string;
  accentColor?: string;
}

// ─────────────────────────────────────────────────────────────────

export interface Testimonial {
  id: number;
  authorName: string;
  authorInitials: string;   // 1-2 chars for initials avatar
  avatarColor: string;      // hex — unique per author
  role: string;
  company?: string;
  rating: number;           // 1–5
  text: string;
  date: string;             // ISO date string
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

export interface BookingState {
  pickup: string;
  dropoff: string;
  pickupDate: string;       // ISO date string
  returnDate: string;
  vehicleCategory: string;
  selectedVehicleName: string | null;
}

export type ChatRole = 'user' | 'assistant';

export interface ChatMessage {
  id: string;
  role: ChatRole;
  text: string;
  timestamp: number;
  isTyping?: boolean;       // true = show typing indicator instead of text
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
}

// ─────────────────────────────────────────────────────────────────
// Legacy alias (keeps src/types.ts consumers working)
// ─────────────────────────────────────────────────────────────────
export interface Toast extends ToastItem {}
