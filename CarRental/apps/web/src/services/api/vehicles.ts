import api from './axios';
import { Vehicle } from '../../types';
import { API_BASE } from '../../config/api';

// Helper to transform backend vehicle to frontend Vehicle type
const transformVehicle = (v: any): Vehicle => ({
  ...v,
  quantity: v.quantity ?? 1,
  pricePerDay: v.pricing?.daily || 0,
  pricePerWeek: v.pricing?.weekly || 0,
  pricing: v.pricing ? {
    daily: v.pricing.daily,
    weekly: v.pricing.weekly,
    monthly: v.pricing.monthly,
    excessPerKm: v.pricing.excess_per_km,
    kmsDaily: v.pricing.kms_daily,
    kmsWeekly: v.pricing.kms_weekly,
    kmsMonthly: v.pricing.kms_monthly,
    deposit: v.pricing.deposit,
    salikSurcharge: v.pricing.salik_surcharge,
    vatRate: v.pricing.vat_rate,
    deliveryFee: v.pricing.delivery_fee,
  } : null,
  images: (() => {
    const getFullUrl = (url: string) => {
      if (!url) return '';
      if (url.startsWith('http://') || url.startsWith('https://')) return url;
      return `${API_BASE}${url}`;
    };
    const explicitThumbnail = v.images?.find((img: any) => img.image_type === 'thumbnail')?.image_url;
    const fallbackImage = explicitThumbnail || v.images?.[0]?.image_url || '';
    return {
      thumbnail: getFullUrl(fallbackImage),
      exterior: v.images?.filter((img: any) => img.image_type === 'exterior').map((img: any) => getFullUrl(img.image_url)) || [],
      interior: v.images?.filter((img: any) => img.image_type === 'interior').map((img: any) => getFullUrl(img.image_url)) || [],
    };
  })(),
  specs: {
    ...v.specifications,
    zeroToSixty: v.specifications?.zero_to_sixty,
    topSpeed: v.specifications?.top_speed,
  },
  category: v.category_rel?.slug || 'sedan',
  brand: v.brand_rel?.name || 'Brand',
  features: v.features?.map((f: any) => f.feature_name) || [],
  colors: v.colors || [],
  rentalIncludes: v.rental_includes || [],
  faqs: v.faqs || [],
  licenceRequired: v.licence_required || [],
  relatedVehicles: v.related_vehicles || [],
});

export const vehicleService = {
  getVehicles: async (skip = 0, limit = 100): Promise<Vehicle[]> => {
    const { data } = await api.get('/vehicles/', { params: { skip, limit } });
    return data.map(transformVehicle);
  },
  
  getFeaturedVehicles: async (): Promise<Vehicle[]> => {
    const { data } = await api.get('/vehicles/featured');
    return data.map(transformVehicle);
  },

  getPopularVehicles: async (): Promise<Vehicle[]> => {
    const { data } = await api.get('/vehicles/popular');
    return data.map(transformVehicle);
  },

  getVehicleById: async (id: number): Promise<Vehicle> => {
    const { data } = await api.get(`/vehicles/${id}`);
    return transformVehicle(data);
  },
};
