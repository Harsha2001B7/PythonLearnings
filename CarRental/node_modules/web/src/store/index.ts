// ─────────────────────────────────────────────────────────────────
// VANTA — Zustand Stores
// Typed, sliced into logical domains.
// ─────────────────────────────────────────────────────────────────
import { create } from 'zustand';
import type { ToastItem, ChatMessage, FilterState } from '../types/index';

// ── Toast Store ───────────────────────────────────────────────────
interface ToastStore {
  toasts: ToastItem[];
  addToast: (message: string, type?: ToastItem['type']) => void;
  removeToast: (id: number) => void;
}

export const useToastStore = create<ToastStore>((set) => ({
  toasts: [],
  addToast: (message, type = 'success') => {
    const id = Date.now();
    set((state) => ({ toasts: [...state.toasts, { id, message, type }] }));
    setTimeout(() => {
      set((state) => ({ toasts: state.toasts.filter((t) => t.id !== id) }));
    }, 3500);
  },
  removeToast: (id) =>
    set((state) => ({ toasts: state.toasts.filter((t) => t.id !== id) })),
}));

// ── Wishlist + Compare Store ──────────────────────────────────────
interface AppStore {
  wishlist: number[];
  compareList: number[];
  toggleWishlist: (id: number) => void;
  toggleCompare: (id: number) => void;
  clearCompare: () => void;
  isCompareOpen: boolean;
  setCompareOpen: (open: boolean) => void;
  isCmdkOpen: boolean;
  setCmdkOpen: (open: boolean) => void;
}

export const useAppStore = create<AppStore>((set) => ({
  wishlist: [],
  compareList: [],
  toggleWishlist: (id) =>
    set((state) => ({
      wishlist: state.wishlist.includes(id)
        ? state.wishlist.filter((x) => x !== id)
        : [...state.wishlist, id],
    })),
  toggleCompare: (id) =>
    set((state) => {
      if (state.compareList.includes(id)) {
        return { compareList: state.compareList.filter((x) => x !== id) };
      }
      if (state.compareList.length >= 3) return state; // max 3
      return { compareList: [...state.compareList, id] };
    }),
  clearCompare: () => set({ compareList: [] }),
  isCompareOpen: false,
  setCompareOpen: (open) => set({ isCompareOpen: open }),
  isCmdkOpen: false,
  setCmdkOpen: (open) => set({ isCmdkOpen: open }),
}));

// ── Booking Store ─────────────────────────────────────────────────
interface BookingStore {
  pickup: string;
  dropoff: string;
  pickupDate: string;
  returnDate: string;
  vehicleCategory: string;
  selectedVehicleName: string | null;
  setPickup: (val: string) => void;
  setDropoff: (val: string) => void;
  setPickupDate: (val: string) => void;
  setReturnDate: (val: string) => void;
  setVehicleCategory: (val: string) => void;
  setSelectedVehicle: (name: string | null) => void;
}

export const useBookingStore = create<BookingStore>((set) => ({
  pickup: 'Dubai — Downtown Hub',
  dropoff: '',
  pickupDate: new Date().toISOString().split('T')[0],
  returnDate: new Date(Date.now() + 3 * 86400000).toISOString().split('T')[0],
  vehicleCategory: 'Sport Coupe',
  selectedVehicleName: null,
  setPickup: (val) => set({ pickup: val }),
  setDropoff: (val) => set({ dropoff: val }),
  setPickupDate: (val) => set({ pickupDate: val }),
  setReturnDate: (val) => set({ returnDate: val }),
  setVehicleCategory: (val) => set({ vehicleCategory: val }),
  setSelectedVehicle: (name) => set({ selectedVehicleName: name }),
}));

// ── Chat Store ────────────────────────────────────────────────────
interface ChatStore {
  isOpen: boolean;
  messages: ChatMessage[];
  isTyping: boolean;
  setOpen: (open: boolean) => void;
  addMessage: (msg: Omit<ChatMessage, 'id' | 'timestamp'>) => void;
  setTyping: (typing: boolean) => void;
  clearHistory: () => void;
}

export const useChatStore = create<ChatStore>((set) => ({
  isOpen: false,
  messages: [],
  isTyping: false,
  setOpen: (open) => set({ isOpen: open }),
  addMessage: (msg) =>
    set((state) => ({
      messages: [
        ...state.messages,
        { ...msg, id: `msg-${Date.now()}-${Math.random()}`, timestamp: Date.now() },
      ],
    })),
  setTyping: (typing) => set({ isTyping: typing }),
  clearHistory: () => set({ messages: [] }),
}));

// ── Fleet Filter Store ────────────────────────────────────────────
interface FilterStore {
  category: string;
  maxPrice: number;
  transmission: string;
  fuel: string;
  seats: string;
  setCategory: (val: string) => void;
  setMaxPrice: (val: number) => void;
  setTransmission: (val: string) => void;
  setFuel: (val: string) => void;
  setSeats: (val: string) => void;
  resetFilters: () => void;
}

export const useFilterStore = create<FilterStore>((set) => ({
  category: 'all',
  maxPrice: 2000,
  transmission: 'all',
  fuel: 'all',
  seats: 'all',
  setCategory: (val) => set({ category: val }),
  setMaxPrice: (val) => set({ maxPrice: val }),
  setTransmission: (val) => set({ transmission: val }),
  setFuel: (val) => set({ fuel: val }),
  setSeats: (val) => set({ seats: val }),
  resetFilters: () => set({ category: 'all', maxPrice: 2000, transmission: 'all', fuel: 'all', seats: 'all' }),
}));

