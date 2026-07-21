import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useNavigate, Link } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  LayoutDashboard, Car, Calendar, Users, Settings, FileText, 
  ArrowLeft, Plus, Edit2, Trash2, Power, Check, X, ShieldAlert,
  Loader2, Sparkles, Image as ImageIcon, Search, Upload, RefreshCw
} from 'lucide-react';

import { useAuthStore } from '../../store/authStore';
import { useToastStore } from '../../store';
import api from '../../services/api/axios';
import { vehicleService } from '../../services/api/vehicles';
import { brandService } from '../../services/api/brands';
import { categoryService } from '../../services/api/categories';
import { Toggle } from '../../components/ui/Toggle';
import { ease, duration } from '../../lib/easing';
import { formatAED } from '../../lib/formatters';
import { cn } from '../../lib/cn';
import Navbar from '../../components/layout/Navbar';

interface VehicleInput {
  name: string;
  brand: string;
  model: string;
  slug: string;
  year: number;
  tagline: string;
  description: string;
  category_id: number;
  brand_id: number;
  pricing: {
    daily: number;
    weekly: number;
    monthly: number;
  };
  specifications: {
    engine: string;
    power: string;
    torque: string;
    seats: number;
    doors: number;
    luggage: number;
    transmission: string;
    fuel: string;
    year: number;
  };
  featured: boolean;
  is_popular: boolean;
  is_new_arrival: boolean;
  available: boolean;
  quantity?: number;
}


const AdminDashboard: React.FC = () => {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { user } = useAuthStore();
  const { addToast } = useToastStore();
  const [activeTab, setActiveTab] = useState<'overview' | 'vehicles' | 'bookings' | 'users' | 'activity' | 'settings'>('overview');

  // Dynamic Brands & Categories mapping
  const { data: brandsList = [] } = useQuery({
    queryKey: ['brands'],
    queryFn: brandService.getBrands
  });
  
  const { data: categoriesList = [] } = useQuery({
    queryKey: ['categories'],
    queryFn: categoryService.getCategories
  });

  const BRAND_NAMES = React.useMemo(() => {
    const map: Record<number, string> = {};
    brandsList.forEach((b: any) => {
      map[b.id] = b.name;
    });
    return map;
  }, [brandsList]);

  const CATEGORY_NAMES = React.useMemo(() => {
    const map: Record<number, string> = {};
    categoriesList.forEach((c: any) => {
      map[c.id] = c.name;
    });
    return map;
  }, [categoriesList]);

  // Soft-delete Status Toggle Mutation
  const toggleStatusMutation = useMutation({
    mutationFn: async ({ id, available }: { id: number, available: boolean }) => {
      const { data: car } = await api.get(`/vehicles/${id}`);
      const payload = {
        slug: car.slug,
        brand_id: car.brand_id,
        category_id: car.category_id,
        model: car.model,
        name: car.name,
        year: car.year,
        tagline: car.tagline,
        description: car.description,
        featured: car.featured,
        is_popular: car.is_popular,
        is_new_arrival: car.is_new_arrival,
        available: available,
        quantity: car.quantity ?? 1,
        badge: car.badge,
        rating: car.rating,
        review_count: car.review_count,
        min_driver_age: car.min_driver_age,
        delivery_available: car.delivery_available,
        licence_required: car.licence_required,
        related_vehicles: car.related_vehicles,
        keywords: car.keywords,
        rental_includes: car.rental_includes,
        seo_title: car.seo_title,
        seo_description: car.seo_description,
        pricing: car.pricing ? {
          daily: car.pricing.daily,
          weekly: car.pricing.weekly,
          monthly: car.pricing.monthly,
          excess_per_km: car.pricing.excess_per_km || 0,
          kms_daily: car.pricing.kms_daily || 300,
          kms_weekly: car.pricing.kms_weekly || 200,
          kms_monthly: car.pricing.kms_monthly || 4000,
          deposit: car.pricing.deposit || 0,
          salik_surcharge: car.pricing.salik_surcharge || 1,
          vat_rate: car.pricing.vat_rate || 5,
          delivery_fee: car.pricing.delivery_fee || 0
        } : undefined,
        specifications: car.specifications ? {
          engine: car.specifications.engine,
          power: car.specifications.power,
          torque: car.specifications.torque,
          seats: car.specifications.seats,
          doors: car.specifications.doors,
          luggage: car.specifications.luggage,
          transmission: car.specifications.transmission,
          fuel: car.specifications.fuel,
          year: car.specifications.year
        } : undefined
      };
      await api.put(`/vehicles/${id}`, payload);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin-vehicles'] });
      queryClient.invalidateQueries({ queryKey: ['admin-stats'] });
      addToast("Vehicle status updated successfully", "success");
    },
    onError: () => {
      addToast("Failed to update vehicle status", "error");
    }
  });

  // Modals & Forms State
  const [vehicleModalOpen, setVehicleModalOpen] = useState(false);
  const [editingVehicleId, setEditingVehicleId] = useState<number | null>(null);
  const [uploadingVehicleId, setUploadingVehicleId] = useState<number | null>(null);
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
  const [vehicleToDeleteId, setVehicleToDeleteId] = useState<number | null>(null);
  const [vehicleSearch, setVehicleSearch] = useState('');
  const [userSearch, setUserSearch] = useState('');
  const [modalUploadType, setModalUploadType] = useState<'thumbnail' | 'exterior' | 'interior'>('thumbnail');
  const [selectedFiles, setSelectedFiles] = useState<{file: File, previewUrl: string, type: 'thumbnail' | 'exterior' | 'interior'}[]>([]);

  // Form State
  const [vehicleForm, setVehicleForm] = useState<VehicleInput>({
    name: '', brand: '', model: '', slug: '', year: 2024, tagline: '', description: '',
    category_id: 2, brand_id: 10,
    pricing: { daily: 150, weekly: 1000, monthly: 3500 },
    specifications: { engine: '1.5L', power: '100 hp', torque: '150 Nm', seats: 5, doors: 4, luggage: 350, transmission: 'auto', fuel: 'petrol', year: 2024 },
    featured: false, is_popular: false, is_new_arrival: false, available: true, quantity: 1
  });

  React.useEffect(() => {
    if (vehicleModalOpen || uploadingVehicleId !== null) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => {
      document.body.style.overflow = '';
    };
  }, [vehicleModalOpen, uploadingVehicleId]);

  // Query Stats
  const { data: stats = {} as any, isLoading: statsLoading } = useQuery({
    queryKey: ['admin-stats'],
    queryFn: async () => {
      const { data } = await api.get('/dashboard/stats');
      return data;
    }
  });

  // Query Activity Logs
  const { data: logs = [], isLoading: logsLoading } = useQuery({
    queryKey: ['admin-logs'],
    queryFn: async () => {
      const { data } = await api.get('/admin/activity-logs');
      return data;
    },
    enabled: activeTab === 'activity' || activeTab === 'overview',
  });

  // Query Bookings
  const { data: bookings = [], isLoading: bookingsLoading } = useQuery({
    queryKey: ['admin-bookings'],
    queryFn: async () => {
      const { data } = await api.get('/admin/bookings');
      return data;
    },
    enabled: activeTab === 'bookings' || activeTab === 'overview',
  });

  // Query Users
  const { data: users = [], isLoading: usersLoading } = useQuery({
    queryKey: ['admin-users'],
    queryFn: async () => {
      const { data } = await api.get('/admin/users');
      return data;
    },
    enabled: activeTab === 'users',
  });

  // Query Vehicles (all)
  const { data: fleet = [], isLoading: fleetLoading } = useQuery({
    queryKey: ['admin-vehicles'],
    queryFn: () => vehicleService.getVehicles(),
    enabled: activeTab === 'vehicles' || activeTab === 'overview',
  });

  // Filtered lists
  const filteredVehicles = fleet.filter(v => 
    v.name.toLowerCase().includes(vehicleSearch.toLowerCase()) || 
    v.brand.toLowerCase().includes(vehicleSearch.toLowerCase())
  );
  const filteredUsers = users.filter((u: any) => 
    u.email.toLowerCase().includes(userSearch.toLowerCase()) ||
    (u.first_name || '').toLowerCase().includes(userSearch.toLowerCase()) ||
    (u.last_name || '').toLowerCase().includes(userSearch.toLowerCase())
  );

  // Mutations
  const bookingMutation = useMutation({
    mutationFn: async ({ id, status }: { id: number; status: string }) => {
      await api.put(`/admin/bookings/${id}/status`, { status });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin-bookings'] });
      queryClient.invalidateQueries({ queryKey: ['admin-stats'] });
      addToast("Booking status updated", "success");
    }
  });

  const userStatusMutation = useMutation({
    mutationFn: async ({ id, status }: { id: number; status: string }) => {
      await api.put(`/admin/users/${id}/status`, { status });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin-users'] });
      addToast("User status updated", "success");
    }
  });

  const saveVehicleMutation = useMutation({
    mutationFn: async () => {
      let vehicleId = editingVehicleId;
      if (editingVehicleId) {
        const { data } = await api.put(`/vehicles/${editingVehicleId}`, vehicleForm);
        vehicleId = data.id;
      } else {
        const { data } = await api.post('/vehicles/', vehicleForm);
        vehicleId = data.id;
      }
      
      // Upload selected files if any
      if (selectedFiles.length > 0 && vehicleId) {
        for (const item of selectedFiles) {
          const formData = new FormData();
          formData.append("file", item.file);
          formData.append("image_type", item.type);
          await api.post(`/vehicles/${vehicleId}/upload-image`, formData, {
            headers: { "Content-Type": "multipart/form-data" }
          });
        }
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin-vehicles'] });
      queryClient.invalidateQueries({ queryKey: ['admin-stats'] });
      setVehicleModalOpen(false);
      setEditingVehicleId(null);
      setSelectedFiles([]);
      addToast(editingVehicleId ? "Vehicle updated successfully" : "Vehicle created successfully", "success");
    },
    onError: (err: any) => {
      addToast(err.response?.data?.detail || "Failed to save vehicle", "error");
    }
  });

  const deleteVehicleMutation = useMutation({
    mutationFn: async (id: number) => {
      await api.delete(`/vehicles/${id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin-vehicles'] });
      queryClient.invalidateQueries({ queryKey: ['admin-stats'] });
      addToast("Vehicle deleted successfully", "success");
    }
  });

  const handleEditVehicle = (car: any) => {
    setEditingVehicleId(car.id);
    setVehicleForm({
      name: car.name,
      brand: car.brand,
      model: car.model || '',
      slug: car.slug,
      year: car.year || 2024,
      tagline: car.tagline || '',
      description: car.description || '',
      category_id: car.category_id || 2,
      brand_id: car.brand_id || 2,
      pricing: {
        daily: car.pricing?.daily || 150,
        weekly: car.pricing?.weekly || 1000,
        monthly: car.pricing?.monthly || 3500
      },
      specifications: {
        engine: car.specs?.engine || '',
        power: car.specs?.power || '',
        torque: car.specs?.torque || '',
        seats: car.specs?.seats || 5,
        doors: car.specs?.doors || 4,
        luggage: car.specs?.luggage || 350,
        transmission: car.specs?.transmission || 'auto',
        fuel: car.specs?.fuel || 'petrol',
        year: car.specs?.year || car.year || 2024
      },
      featured: car.featured || false,
      is_popular: car.isPopular || false,
      is_new_arrival: car.isNewArrival || false,
      available: car.available || true,
      quantity: car.quantity ?? 1
    });
    setVehicleModalOpen(true);
  };

  const handleOpenAddVehicle = () => {
    setEditingVehicleId(null);
    setVehicleForm({
      name: '', brand: '', model: '', slug: '', year: 2024, tagline: '', description: '',
      category_id: 2, brand_id: 10,
      pricing: { daily: 150, weekly: 1000, monthly: 3500 },
      specifications: { engine: '1.5L', power: '100 hp', torque: '150 Nm', seats: 5, doors: 4, luggage: 350, transmission: 'auto', fuel: 'petrol', year: 2024 },
      featured: false, is_popular: false, is_new_arrival: false, available: true, quantity: 1
    });
    setVehicleModalOpen(true);
  };

  // Image Upload Action
  const handleUploadImage = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || !uploadingVehicleId) return;

    const formData = new FormData();
    formData.append("file", file);
    formData.append("image_type", "exterior"); // default

    try {
      addToast("Uploading image...", "info");
      await api.post(`/vehicles/${uploadingVehicleId}/upload-image`, formData, {
        headers: { "Content-Type": "multipart/form-data" }
      });
      queryClient.invalidateQueries({ queryKey: ['admin-vehicles'] });
      addToast("Image uploaded successfully", "success");
    } catch {
      addToast("Failed to upload image", "error");
    }
  };

  return (
    <div className="min-h-screen bg-vanta-paper text-vanta-ink">
      <Navbar />

      <div className="section-container pt-36 pb-24">
        {/* Layout header */}
        <div className="flex flex-col md:flex-row md:items-center justify-between border-b border-vanta-border pb-8 mb-12">
          <div>
            <Link to="/" className="inline-flex items-center gap-2 text-xs font-mono uppercase tracking-wider text-vanta-amber hover:underline mb-3">
              <ArrowLeft size={12} /> Public Portal
            </Link>
            <h1 className="font-grotesk text-2xl sm:text-3xl lg:text-4xl font-extrabold text-white flex flex-wrap items-center gap-3">
              Admin Portal <span className="bg-vanta-amber/10 border border-vanta-amber/30 text-vanta-amber text-xs font-mono px-3 py-1 rounded-full uppercase tracking-wider">Vault Control</span>
            </h1>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-5 gap-8">
          {/* Dashboard Sidebar */}
          <div className="lg:col-span-1 flex flex-row lg:flex-col overflow-x-auto lg:overflow-visible gap-1.5 border-b lg:border-b-0 border-vanta-border pb-4 lg:pb-0">
            <button
              onClick={() => setActiveTab('overview')}
              className={`flex items-center gap-3 px-4 py-3 rounded-xl font-grotesk font-semibold text-xs uppercase tracking-wider transition-all whitespace-nowrap ${
                activeTab === 'overview' ? 'bg-vanta-amber text-white shadow-amber-sm' : 'text-vanta-ink-muted hover:text-white hover:bg-vanta-panel'
              }`}
            >
              <LayoutDashboard size={14} /> Overview
            </button>
            <button
              onClick={() => setActiveTab('vehicles')}
              className={`flex items-center gap-3 px-4 py-3 rounded-xl font-grotesk font-semibold text-xs uppercase tracking-wider transition-all whitespace-nowrap ${
                activeTab === 'vehicles' ? 'bg-vanta-amber text-white shadow-amber-sm' : 'text-vanta-ink-muted hover:text-white hover:bg-vanta-panel'
              }`}
            >
              <Car size={14} /> Vehicles
            </button>
            <button
              onClick={() => setActiveTab('bookings')}
              className={`flex items-center gap-3 px-4 py-3 rounded-xl font-grotesk font-semibold text-xs uppercase tracking-wider transition-all whitespace-nowrap ${
                activeTab === 'bookings' ? 'bg-vanta-amber text-white shadow-amber-sm' : 'text-vanta-ink-muted hover:text-white hover:bg-vanta-panel'
              }`}
            >
              <Calendar size={14} /> Bookings
            </button>
            <button
              onClick={() => setActiveTab('users')}
              className={`flex items-center gap-3 px-4 py-3 rounded-xl font-grotesk font-semibold text-xs uppercase tracking-wider transition-all whitespace-nowrap ${
                activeTab === 'users' ? 'bg-vanta-amber text-white shadow-amber-sm' : 'text-vanta-ink-muted hover:text-white hover:bg-vanta-panel'
              }`}
            >
              <Users size={14} /> Users
            </button>
            <button
              onClick={() => setActiveTab('activity')}
              className={`flex items-center gap-3 px-4 py-3 rounded-xl font-grotesk font-semibold text-xs uppercase tracking-wider transition-all whitespace-nowrap ${
                activeTab === 'activity' ? 'bg-vanta-amber text-white shadow-amber-sm' : 'text-vanta-ink-muted hover:text-white hover:bg-vanta-panel'
              }`}
            >
              <FileText size={14} /> Logs
            </button>
            <button
              onClick={() => setActiveTab('settings')}
              className={`flex items-center gap-3 px-4 py-3 rounded-xl font-grotesk font-semibold text-xs uppercase tracking-wider transition-all whitespace-nowrap ${
                activeTab === 'settings' ? 'bg-vanta-amber text-white shadow-amber-sm' : 'text-vanta-ink-muted hover:text-white hover:bg-vanta-panel'
              }`}
            >
              <Settings size={14} /> Settings
            </button>
          </div>

          {/* Main Dashboard Section */}
          <div className="lg:col-span-4 bg-vanta-panel border border-vanta-border rounded-2xl p-4 sm:p-6 lg:p-8 relative overflow-hidden backdrop-blur-xl min-h-[500px]">
            
            {/* OVERVIEW PANEL */}
            {activeTab === 'overview' && (
              <div className="space-y-8">
                <h3 className="font-grotesk text-xl font-bold text-white border-b border-vanta-border pb-3 flex items-center gap-2">
                  <LayoutDashboard size={18} className="text-vanta-amber" /> Overview Analytics
                </h3>
                
                {statsLoading ? (
                  <div className="flex items-center justify-center py-20">
                    <Loader2 className="w-8 h-8 text-vanta-amber animate-spin" />
                  </div>
                ) : (
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <div className="border border-vanta-border rounded-xl p-5 bg-vanta-paper-soft">
                      <span className="text-[10px] font-mono uppercase text-vanta-ink-muted block mb-1">Total Fleet</span>
                      <span className="font-grotesk font-extrabold text-3xl text-white">{stats.totalVehicles}</span>
                    </div>
                    <div className="border border-vanta-border rounded-xl p-5 bg-vanta-paper-soft">
                      <span className="text-[10px] font-mono uppercase text-vanta-amber block mb-1">Available Fleet</span>
                      <span className="font-grotesk font-extrabold text-3xl text-white">{stats.availableVehicles}</span>
                    </div>
                    <div className="border border-vanta-border rounded-xl p-5 bg-vanta-paper-soft">
                      <span className="text-[10px] font-mono uppercase text-vanta-ink-muted block mb-1">Booked Vehicles</span>
                      <span className="font-grotesk font-extrabold text-3xl text-white">{stats.bookedVehicles}</span>
                    </div>
                    <div className="border border-vanta-border rounded-xl p-5 bg-vanta-paper-soft">
                      <span className="text-[10px] font-mono uppercase text-vanta-ink-muted block mb-1">Total Revenue</span>
                      <span className="font-grotesk font-extrabold text-2xl text-vanta-amber">{formatAED(stats.monthlyRevenue || 0)}</span>
                    </div>
                  </div>
                )}

                {/* Grid for Recent Bookings & Activities */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                  {/* Recent Bookings */}
                  <div className="border border-vanta-border rounded-xl p-6 bg-vanta-paper-soft">
                    <h4 className="font-grotesk font-bold text-white mb-4 border-b border-vanta-border pb-2 text-sm uppercase tracking-wider">Recent Lease Bookings</h4>
                    {bookingsLoading ? (
                      <Loader2 className="w-5 h-5 animate-spin mx-auto text-vanta-amber" />
                    ) : bookings.length === 0 ? (
                      <p className="text-xs text-vanta-ink-subtle font-mono uppercase text-center py-8">No bookings on lease</p>
                    ) : (
                      <div className="space-y-3">
                        {bookings.slice(0, 4).map((b: any) => (
                          <div key={b.id} className="flex justify-between items-center bg-vanta-paper p-3 rounded-lg border border-vanta-border">
                            <div>
                              <p className="font-grotesk font-bold text-white text-xs">{b.vehicle?.name}</p>
                              <p className="text-[10px] text-vanta-ink-muted font-mono">{b.user?.email}</p>
                            </div>
                            <span className={`text-[9px] font-mono px-2 py-0.5 rounded uppercase border ${b.status === 'confirmed' ? 'text-green-400 border-green-500/20' : 'text-amber-400 border-amber-500/20'}`}>
                              {b.status}
                            </span>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>

                  {/* Recent Activity Log */}
                  <div className="border border-vanta-border rounded-xl p-6 bg-vanta-paper-soft">
                    <h4 className="font-grotesk font-bold text-white mb-4 border-b border-vanta-border pb-2 text-sm uppercase tracking-wider">Vault Log History</h4>
                    {logsLoading ? (
                      <Loader2 className="w-5 h-5 animate-spin mx-auto text-vanta-amber" />
                    ) : logs.length === 0 ? (
                      <p className="text-xs text-vanta-ink-subtle font-mono uppercase text-center py-8">Vault log is empty</p>
                    ) : (
                      <div className="space-y-3">
                        {logs.slice(0, 4).map((log: any) => (
                          <div key={log.id} className="bg-vanta-paper p-3 rounded-lg border border-vanta-border text-[11px]">
                            <p className="font-mono text-vanta-amber font-bold">{log.action}</p>
                            <p className="text-white/80 mt-0.5">{log.details}</p>
                            <span className="text-[9px] text-vanta-ink-subtle font-mono mt-1 block">{log.created_at.replace('T', ' ').split('.')[0]}</span>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )}

            {/* VEHICLES PANEL */}
            {activeTab === 'vehicles' && (
              <div className="space-y-6">
                <div className="flex flex-col sm:flex-row justify-between sm:items-center gap-4 border-b border-vanta-border pb-4">
                  <h3 className="font-grotesk text-xl font-bold text-white flex items-center gap-2">
                    <Car size={18} className="text-vanta-amber" /> Fleet Inventory
                  </h3>
                  <button
                    onClick={handleOpenAddVehicle}
                    className="bg-vanta-amber hover:bg-orange-500 text-white font-grotesk font-semibold text-xs px-5 py-3 rounded-xl transition-all shadow-amber-sm flex items-center gap-2 self-start"
                  >
                    <Plus size={14} /> Add Luxury Car
                  </button>
                </div>

                {/* Search */}
                <div className="relative max-w-md">
                  <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle">
                    <Search size={14} />
                  </span>
                  <input
                    type="text"
                    placeholder="Search by brand or name..."
                    value={vehicleSearch}
                    onChange={(e) => setVehicleSearch(e.target.value)}
                    className="w-full bg-vanta-paper-soft border border-vanta-border rounded-xl py-2.5 pl-9 pr-4 text-xs text-white focus:outline-none focus:border-vanta-amber transition-all"
                  />
                </div>

                {fleetLoading ? (
                  <div className="flex items-center justify-center py-20">
                    <Loader2 className="w-8 h-8 text-vanta-amber animate-spin" />
                  </div>
                ) : (
                  <>
                    <div className="hidden md:block">
                      <div className="overflow-x-auto">
                        <table className="w-full border-collapse text-left text-xs text-vanta-ink-muted">
                          <thead>
                            <tr className="border-b border-vanta-border font-mono text-[10px] uppercase tracking-wider">
                              <th className="py-3 px-4">Car Details</th>
                              <th className="py-3 px-4">Category</th>
                              <th className="py-3 px-4">Daily pricing</th>
                              <th className="py-3 px-4">Lease State</th>
                              <th className="py-3 px-4 text-right">Actions</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-vanta-border">
                            {filteredVehicles.map((car) => (
                              <tr key={car.id} className="hover:bg-white/[0.02] transition-colors">
                                <td className="py-4 px-4 flex items-center gap-3">
                                  <img src={car.images.thumbnail} alt={car.name} className="w-12 h-9 rounded object-cover bg-vanta-paper border border-vanta-border" />
                                  <div>
                                    <p className="font-grotesk font-bold text-white">{car.name}</p>
                                    <span className="text-[10px] text-vanta-amber font-mono">{car.brand}</span>
                                  </div>
                                </td>
                                <td className="py-4 px-4 font-mono uppercase text-[10px]">{car.category}</td>
                                <td className="py-4 px-4 font-mono font-semibold text-white">{formatAED(car.pricePerDay)}</td>
                                <td className="py-4 px-4">
                                  <span className={`px-2 py-0.5 rounded text-[10px] font-mono border ${
                                    car.available && (car.quantity ?? 1) > 0 ? 'text-green-400 bg-green-500/10 border-green-500/20' : 'text-red-400 bg-red-500/10 border-red-500/20'
                                  }`}>
                                    {car.available && (car.quantity ?? 1) > 0 ? `AVAILABLE (Qty: ${car.quantity ?? 1})` : 'UNAVAILABLE'}
                                  </span>
                                </td>
                                <td className="py-4 px-4 text-right space-x-2 whitespace-nowrap flex items-center justify-end">
                                  {/* Sliding Toggle Switch */}
                                  <Toggle
                                    isSelected={car.available}
                                    onChange={(selected) => toggleStatusMutation.mutate({ id: car.id, available: selected })}
                                    size="sm"
                                  />
                                  
                                  <button
                                    onClick={() => handleEditVehicle(car)}
                                    className="p-2 border border-vanta-border rounded-lg bg-vanta-paper hover:border-vanta-amber text-vanta-ink hover:text-vanta-amber transition-all"
                                    title="Edit specs"
                                  >
                                    <Edit2 size={12} />
                                  </button>
                                  
                                  <button
                                    onClick={() => {
                                      setVehicleToDeleteId(car.id);
                                      setDeleteConfirmOpen(true);
                                    }}
                                    className="p-2 border border-vanta-border rounded-lg bg-vanta-paper hover:border-red-500/60 text-vanta-ink hover:text-red-400 transition-all"
                                    title="Delete Vehicle"
                                  >
                                    <Trash2 size={12} />
                                  </button>
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                    <div className="flex flex-col gap-4 md:hidden">
                      {filteredVehicles.map((car) => (
                        <div key={car.id} className="bg-vanta-paper border border-vanta-border rounded-xl p-4 flex flex-col gap-3">
                          <div className="flex items-center gap-3 border-b border-vanta-border pb-3">
                            <img src={car.images.thumbnail} alt={car.name} className="w-16 h-12 rounded object-cover bg-vanta-panel border border-vanta-border" />
                            <div className="flex-1">
                              <p className="font-grotesk font-bold text-white text-sm">{car.name}</p>
                              <span className="text-[10px] text-vanta-amber font-mono">{car.brand}</span>
                            </div>
                            <span className={`px-2 py-0.5 rounded text-[10px] font-mono border ${
                              car.available && (car.quantity ?? 1) > 0 ? 'text-green-400 bg-green-500/10 border-green-500/20' : 'text-red-400 bg-red-500/10 border-red-500/20'
                            }`}>
                              {car.available && (car.quantity ?? 1) > 0 ? `AVAILABLE (Qty: ${car.quantity ?? 1})` : 'UNAVAILABLE'}
                            </span>
                          </div>
                          <div className="grid grid-cols-2 gap-2 text-xs">
                            <div>
                              <span className="block text-[9px] font-mono text-vanta-ink-subtle uppercase">Category</span>
                              <span className="font-mono uppercase text-[10px] text-white">{car.category}</span>
                            </div>
                            <div>
                              <span className="block text-[9px] font-mono text-vanta-ink-subtle uppercase">Daily Rate</span>
                              <span className="font-mono font-semibold text-white">{formatAED(car.pricePerDay)}</span>
                            </div>
                          </div>
                          <div className="flex items-center justify-between pt-2 border-t border-vanta-border mt-1">
                            <div className="flex items-center gap-2">
                              <span className="text-[9px] font-mono uppercase text-vanta-ink-subtle">Status</span>
                              <Toggle
                                isSelected={car.available}
                                onChange={(selected) => toggleStatusMutation.mutate({ id: car.id, available: selected })}
                                size="sm"
                              />
                            </div>
                            <div className="flex gap-2">
                              <button
                                onClick={() => handleEditVehicle(car)}
                                className="p-2 border border-vanta-border rounded-lg bg-vanta-panel hover:border-vanta-amber text-vanta-ink hover:text-vanta-amber transition-all"
                                title="Edit specs"
                              >
                                <Edit2 size={12} />
                              </button>
                              
                              <button
                                onClick={() => {
                                  setVehicleToDeleteId(car.id);
                                  setDeleteConfirmOpen(true);
                                }}
                                className="p-2 border border-vanta-border rounded-lg bg-vanta-panel hover:border-red-500/60 text-vanta-ink hover:text-red-400 transition-all"
                                title="Delete Vehicle"
                              >
                                <Trash2 size={12} />
                              </button>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </>
                )}
              </div>
            )}

            {/* BOOKINGS PANEL */}
            {activeTab === 'bookings' && (
              <div className="space-y-6">
                <h3 className="font-grotesk text-xl font-bold text-white border-b border-vanta-border pb-4 flex items-center gap-2">
                  <Calendar size={18} className="text-vanta-amber" /> Lease Bookings
                </h3>

                {bookingsLoading ? (
                  <div className="flex items-center justify-center py-20">
                    <Loader2 className="w-8 h-8 text-vanta-amber animate-spin" />
                  </div>
                ) : bookings.length === 0 ? (
                  <p className="text-xs text-vanta-ink-subtle font-mono uppercase text-center py-16">No lease orders placed</p>
                ) : (
                  <>
                    <div className="hidden md:block">
                      <div className="overflow-x-auto">
                        <table className="w-full border-collapse text-left text-xs text-vanta-ink-muted">
                          <thead>
                            <tr className="border-b border-vanta-border font-mono text-[10px] uppercase tracking-wider">
                              <th className="py-3 px-4">Lease ID</th>
                              <th className="py-3 px-4">User</th>
                              <th className="py-3 px-4">Vehicle</th>
                              <th className="py-3 px-4">Booked On</th>
                              <th className="py-3 px-4">Lease Dates</th>
                              <th className="py-3 px-4">Total Fee</th>
                              <th className="py-3 px-4">State</th>
                              <th className="py-3 px-4 text-right">Actions</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-vanta-border">
                            {bookings.map((b: any) => (
                              <tr key={b.id} className="hover:bg-white/[0.02] transition-colors">
                                <td className="py-4 px-4 font-mono text-white">#{b.id}</td>
                                <td className="py-4 px-4">
                                  <p className="font-semibold text-white">{b.user?.firstName} {b.user?.lastName}</p>
                                  <span className="text-[10px] text-vanta-ink-subtle font-mono">{b.user?.email}</span>
                                </td>
                                <td className="py-4 px-4 font-semibold text-white">{b.vehicle?.name}</td>
                                <td className="py-4 px-4 font-mono text-vanta-amber text-[11px]">
                                  {b.createdAt ? b.createdAt.split('T')[0] : 'N/A'}
                                </td>
                                <td className="py-4 px-4 font-mono">
                                  {b.startDate ? b.startDate.split('T')[0] : 'N/A'} to {b.endDate ? b.endDate.split('T')[0] : 'N/A'}
                                </td>
                                <td className="py-4 px-4 font-mono font-semibold text-white">{formatAED(b.totalPrice)}</td>
                                <td className="py-4 px-4">
                                  <span className={`px-2 py-0.5 rounded text-[10px] font-mono border ${
                                    b.status === 'confirmed' ? 'text-green-400 border-green-500/20 bg-green-500/5' : 
                                    b.status === 'pending' ? 'text-amber-400 border-amber-500/20 bg-amber-500/5' :
                                    'text-red-400 border-red-500/20 bg-red-500/5'
                                  }`}>
                                    {b.status}
                                  </span>
                                </td>
                                <td className="py-4 px-4 text-right whitespace-nowrap space-x-1">
                                  {b.status === 'pending' && (
                                    <>
                                      <button
                                        onClick={() => bookingMutation.mutate({ id: b.id, status: 'confirmed' })}
                                        className="p-2 border border-vanta-border rounded-lg bg-vanta-paper hover:border-green-500 text-green-400 transition-all"
                                        title="Approve Lease"
                                      >
                                        <Check size={12} />
                                      </button>
                                      <button
                                        onClick={() => bookingMutation.mutate({ id: b.id, status: 'cancelled' })}
                                        className="p-2 border border-vanta-border rounded-lg bg-vanta-paper hover:border-red-500 text-red-400 transition-all"
                                        title="Reject Lease"
                                      >
                                        <X size={12} />
                                      </button>
                                    </>
                                  )}
                                  {b.status === 'confirmed' && (
                                    <button
                                      onClick={() => bookingMutation.mutate({ id: b.id, status: 'completed' })}
                                      className="px-3 py-1.5 border border-vanta-border rounded-lg bg-vanta-paper hover:border-green-500 text-white/90 text-[10px] font-mono hover:text-green-400 transition-all"
                                    >
                                      COMPLETE LEASE
                                    </button>
                                  )}
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                    <div className="flex flex-col gap-4 md:hidden">
                      {bookings.map((b: any) => (
                        <div key={b.id} className="bg-vanta-paper border border-vanta-border rounded-xl p-4 flex flex-col gap-3">
                          <div className="flex justify-between items-start border-b border-vanta-border pb-3">
                            <div>
                              <span className="text-[10px] font-mono text-vanta-ink-subtle">Lease #{b.id}</span>
                              <p className="font-semibold text-white">{b.vehicle?.name}</p>
                            </div>
                            <span className={`px-2 py-0.5 rounded text-[10px] font-mono border ${
                              b.status === 'confirmed' ? 'text-green-400 border-green-500/20 bg-green-500/5' : 
                              b.status === 'pending' ? 'text-amber-400 border-amber-500/20 bg-amber-500/5' :
                              'text-red-400 border-red-500/20 bg-red-500/5'
                            }`}>
                              {b.status}
                            </span>
                          </div>
                          
                          <div className="grid grid-cols-2 gap-2 text-xs">
                            <div>
                              <span className="block text-[9px] font-mono text-vanta-ink-subtle uppercase">User</span>
                              <p className="font-semibold text-white">{b.user?.firstName} {b.user?.lastName}</p>
                              <span className="text-[10px] text-vanta-ink-subtle font-mono truncate max-w-full block">{b.user?.email}</span>
                            </div>
                            <div>
                              <span className="block text-[9px] font-mono text-vanta-ink-subtle uppercase">Lease Dates</span>
                              <span className="font-mono text-white block">{b.startDate.split('T')[0]}</span>
                              <span className="font-mono text-white block">to {b.endDate.split('T')[0]}</span>
                            </div>
                          </div>
                          
                          <div className="flex justify-between items-center pt-3 border-t border-vanta-border">
                            <div>
                              <span className="block text-[9px] font-mono text-vanta-ink-subtle uppercase">Total Fee</span>
                              <span className="font-mono font-semibold text-white">{formatAED(b.totalPrice)}</span>
                            </div>
                            <div className="flex gap-2">
                              {b.status === 'pending' && (
                                <>
                                  <button
                                    onClick={() => bookingMutation.mutate({ id: b.id, status: 'confirmed' })}
                                    className="p-2 border border-vanta-border rounded-lg bg-vanta-panel hover:border-green-500 text-green-400 transition-all"
                                    title="Approve Lease"
                                  >
                                    <Check size={12} />
                                  </button>
                                  <button
                                    onClick={() => bookingMutation.mutate({ id: b.id, status: 'cancelled' })}
                                    className="p-2 border border-vanta-border rounded-lg bg-vanta-panel hover:border-red-500 text-red-400 transition-all"
                                    title="Reject Lease"
                                  >
                                    <X size={12} />
                                  </button>
                                </>
                              )}
                              {b.status === 'confirmed' && (
                                <button
                                  onClick={() => bookingMutation.mutate({ id: b.id, status: 'completed' })}
                                  className="px-3 py-1.5 border border-vanta-border rounded-lg bg-vanta-panel hover:border-green-500 text-white/90 text-[10px] font-mono hover:text-green-400 transition-all"
                                >
                                  COMPLETE
                                </button>
                              )}
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </>
                )}
              </div>
            )}

            {/* USERS PANEL */}
            {activeTab === 'users' && (
              <div className="space-y-6">
                <h3 className="font-grotesk text-xl font-bold text-white border-b border-vanta-border pb-4 flex items-center gap-2">
                  <Users size={18} className="text-vanta-amber" /> Vault Users
                </h3>

                {/* Search */}
                <div className="relative max-w-md">
                  <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle">
                    <Search size={14} />
                  </span>
                  <input
                    type="text"
                    placeholder="Search users..."
                    value={userSearch}
                    onChange={(e) => setUserSearch(e.target.value)}
                    className="w-full bg-vanta-paper-soft border border-vanta-border rounded-xl py-2.5 pl-9 pr-4 text-xs text-white focus:outline-none focus:border-vanta-amber transition-all"
                  />
                </div>

                {usersLoading ? (
                  <div className="flex items-center justify-center py-20">
                    <Loader2 className="w-8 h-8 text-vanta-amber animate-spin" />
                  </div>
                ) : (
                  <>
                    <div className="hidden md:block">
                      <div className="overflow-x-auto">
                        <table className="w-full border-collapse text-left text-xs text-vanta-ink-muted">
                          <thead>
                            <tr className="border-b border-vanta-border font-mono text-[10px] uppercase tracking-wider">
                              <th className="py-3 px-4">User Details</th>
                              <th className="py-3 px-4">Phone</th>
                              <th className="py-3 px-4">Role</th>
                              <th className="py-3 px-4">State</th>
                              <th className="py-3 px-4 text-right">Actions</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-vanta-border">
                            {filteredUsers.map((u: any) => (
                              <tr key={u.id} className="hover:bg-white/[0.02] transition-colors">
                                <td className="py-4 px-4">
                                  <p className="font-semibold text-white">{u.first_name} {u.last_name}</p>
                                  <span className="text-[10px] text-vanta-ink-subtle font-mono">{u.email}</span>
                                </td>
                                <td className="py-4 px-4 font-mono">{u.phone || 'N/A'}</td>
                                <td className="py-4 px-4 font-mono text-[10px] uppercase">{u.role_id === 1 ? 'ADMIN' : 'USER'}</td>
                                <td className="py-4 px-4">
                                  <span className={`px-2 py-0.5 rounded text-[10px] font-mono border ${
                                    u.status === 'active' ? 'text-green-400 bg-green-500/10 border-green-500/20' : 'text-red-400 bg-red-500/10 border-red-500/20'
                                  }`}>
                                    {u.status.toUpperCase()}
                                  </span>
                                </td>
                                <td className="py-4 px-4 text-right">
                                  {u.id !== user?.id && (
                                    <button
                                      onClick={() => userStatusMutation.mutate({ id: u.id, status: u.status === 'active' ? 'disabled' : 'active' })}
                                      className={`px-3 py-1.5 border border-vanta-border rounded-lg bg-vanta-paper text-[10px] font-mono transition-all ${
                                        u.status === 'active' ? 'hover:border-red-500 text-red-400' : 'hover:border-green-500 text-green-400'
                                      }`}
                                    >
                                      {u.status === 'active' ? 'DISABLE' : 'ENABLE'}
                                    </button>
                                  )}
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                    <div className="flex flex-col gap-4 md:hidden">
                      {filteredUsers.map((u: any) => (
                        <div key={u.id} className="bg-vanta-paper border border-vanta-border rounded-xl p-4 flex flex-col gap-3">
                          <div className="flex justify-between items-start border-b border-vanta-border pb-3">
                            <div>
                              <p className="font-semibold text-white">{u.first_name} {u.last_name}</p>
                              <span className="text-[10px] text-vanta-ink-subtle font-mono truncate">{u.email}</span>
                            </div>
                            <span className={`px-2 py-0.5 rounded text-[10px] font-mono border ${
                              u.status === 'active' ? 'text-green-400 bg-green-500/10 border-green-500/20' : 'text-red-400 bg-red-500/10 border-red-500/20'
                            }`}>
                              {u.status.toUpperCase()}
                            </span>
                          </div>
                          
                          <div className="grid grid-cols-2 gap-2 text-xs">
                            <div>
                              <span className="block text-[9px] font-mono text-vanta-ink-subtle uppercase">Phone</span>
                              <span className="font-mono text-white">{u.phone || 'N/A'}</span>
                            </div>
                            <div>
                              <span className="block text-[9px] font-mono text-vanta-ink-subtle uppercase">Role</span>
                              <span className="font-mono text-[10px] uppercase text-white">{u.role_id === 1 ? 'ADMIN' : 'USER'}</span>
                            </div>
                          </div>
                          
                          <div className="flex justify-end pt-3 border-t border-vanta-border">
                            {u.id !== user?.id && (
                              <button
                                onClick={() => userStatusMutation.mutate({ id: u.id, status: u.status === 'active' ? 'disabled' : 'active' })}
                                className={`px-4 py-2 border border-vanta-border rounded-lg bg-vanta-panel text-[10px] font-mono transition-all ${
                                  u.status === 'active' ? 'hover:border-red-500 text-red-400' : 'hover:border-green-500 text-green-400'
                                }`}
                              >
                                {u.status === 'active' ? 'DISABLE USER' : 'ENABLE USER'}
                              </button>
                            )}
                          </div>
                        </div>
                      ))}
                    </div>
                  </>
                )}
              </div>
            )}

            {/* LOGS PANEL */}
            {activeTab === 'activity' && (
              <div className="space-y-6">
                <h3 className="font-grotesk text-xl font-bold text-white border-b border-vanta-border pb-4 flex items-center gap-2">
                  <FileText size={18} className="text-vanta-amber" /> Vault Activity Logs
                </h3>

                {logsLoading ? (
                  <div className="flex items-center justify-center py-20">
                    <Loader2 className="w-8 h-8 text-vanta-amber animate-spin" />
                  </div>
                ) : logs.length === 0 ? (
                  <p className="text-xs text-vanta-ink-subtle font-mono uppercase text-center py-16">Log history is empty</p>
                ) : (
                  <>
                    <div className="hidden md:block">
                      <div className="overflow-x-auto">
                        <table className="w-full border-collapse text-left text-xs text-vanta-ink-muted">
                          <thead>
                            <tr className="border-b border-vanta-border font-mono text-[10px] uppercase tracking-wider">
                              <th className="py-3 px-4">Timestamp</th>
                              <th className="py-3 px-4">Action</th>
                              <th className="py-3 px-4">Details</th>
                              <th className="py-3 px-4">IP Address</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-vanta-border">
                            {logs.map((log: any) => (
                              <tr key={log.id} className="hover:bg-white/[0.02] transition-colors">
                                <td className="py-4 px-4 font-mono">{log.created_at.replace('T', ' ').split('.')[0]}</td>
                                <td className="py-4 px-4 font-bold text-white">{log.action}</td>
                                <td className="py-4 px-4">{log.details}</td>
                                <td className="py-4 px-4 font-mono">{log.ip_address || 'N/A'}</td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                    <div className="flex flex-col gap-4 md:hidden">
                      {logs.map((log: any) => (
                        <div key={log.id} className="bg-vanta-paper border border-vanta-border rounded-xl p-4 flex flex-col gap-2">
                          <div className="flex justify-between items-start border-b border-vanta-border pb-2">
                            <span className="font-bold text-white">{log.action}</span>
                            <span className="text-[10px] text-vanta-ink-subtle font-mono">{log.created_at.replace('T', ' ').split('.')[0]}</span>
                          </div>
                          <p className="text-xs text-vanta-ink-muted">{log.details}</p>
                          <div className="pt-2">
                            <span className="text-[9px] font-mono text-vanta-ink-subtle uppercase">IP: {log.ip_address || 'N/A'}</span>
                          </div>
                        </div>
                      ))}
                    </div>
                  </>
                )}
              </div>
            )}

            {/* SETTINGS PANEL */}
            {activeTab === 'settings' && (
              <div className="space-y-6">
                <h3 className="font-grotesk text-xl font-bold text-white border-b border-vanta-border pb-4 flex items-center gap-2">
                  <Settings size={18} className="text-vanta-amber" /> Vault Global Settings
                </h3>

                <div className="border border-vanta-border rounded-xl p-6 bg-vanta-paper-soft text-center max-w-md mx-auto space-y-4 my-8">
                  <ShieldAlert size={36} className="text-vanta-amber mx-auto" />
                  <h4 className="font-grotesk font-bold text-white">System Settings Access</h4>
                  <p className="text-xs text-vanta-ink-muted leading-relaxed">
                    Adjustments to FAQ collections, Testimonials, Categories, and Landing Banner configurations are linked directly to DB schemas. Use the vehicle database manager or database tools to modify collections directly.
                  </p>
                </div>
              </div>
            )}

          </div>
        </div>
      </div>

      {/* ── VEHICLE ADD/EDIT MODAL ── */}
      <AnimatePresence>
        {vehicleModalOpen && (
          <div className="fixed inset-0 z-[1000] flex items-center justify-center p-4">
            <div className="fixed inset-0 bg-black/80 backdrop-blur-sm" onClick={() => { setSelectedFiles([]); setVehicleModalOpen(false); }} />
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              className="bg-vanta-panel border border-vanta-border w-full max-w-[95vw] sm:max-w-[800px] max-h-[90vh] sm:max-h-[85vh] rounded-2xl z-50 relative flex flex-col overflow-hidden"
            >
              {/* Modal Header */}
              <div className="p-4 sm:p-6 border-b border-vanta-border flex justify-between items-center bg-vanta-panel">
                <h3 className="font-grotesk text-lg sm:text-2xl font-bold text-white">
                  {editingVehicleId ? 'Update Vehicle specifications' : 'Add Vehicle to Fleet'}
                </h3>
                <button
                  onClick={() => {
                    setSelectedFiles([]);
                    setVehicleModalOpen(false);
                  }}
                  className="text-vanta-ink-muted hover:text-white transition-colors"
                >
                  <X size={18} />
                </button>
              </div>

              {/* Modal Body (Scrollable) */}
              <div data-lenis-prevent className="p-6 overflow-y-auto flex-1 space-y-6">
                <div className="space-y-6">
                  {/* Row 1 */}
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                      <label className="block text-[9px] font-mono uppercase tracking-wider text-vanta-ink-muted mb-1">Brand (Auto-assigned)</label>
                      <input
                        type="text"
                        value={vehicleForm.brand}
                        readOnly
                        className="w-full bg-vanta-paper-soft border border-vanta-border/50 rounded-xl py-2 px-3 text-xs text-vanta-ink-muted focus:outline-none"
                        placeholder="Select Brand Name below"
                      />
                    </div>
                    <div>
                      <label className="block text-[9px] font-mono uppercase tracking-wider text-vanta-ink-muted mb-1">Model / Class</label>
                      <input
                        type="text"
                        value={vehicleForm.model}
                        onChange={(e) => setVehicleForm({ ...vehicleForm, model: e.target.value })}
                        className="w-full bg-vanta-paper border border-vanta-border rounded-xl py-2.5 px-3 text-xs text-white focus:outline-none focus:border-vanta-amber"
                        placeholder="Vantage GT"
                      />
                    </div>
                    <div>
                      <label className="block text-[9px] font-mono uppercase tracking-wider text-vanta-ink-muted mb-1">Display Name</label>
                      <input
                        type="text"
                        value={vehicleForm.name}
                        onChange={(e) => {
                          const name = e.target.value;
                          const slug = name
                            .toLowerCase()
                            .trim()
                            .replace(/[^a-z0-9\s-]/g, '')
                            .replace(/[\s_]+/g, '-')
                            .replace(/-+/g, '-');
                          setVehicleForm({ ...vehicleForm, name, slug });
                        }}
                        className="w-full bg-vanta-paper border border-vanta-border rounded-xl py-2.5 px-3 text-xs text-white focus:outline-none focus:border-vanta-amber"
                        placeholder="Aston Martin Vantage GT"
                      />
                    </div>
                  </div>

                  {/* Row 2 */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-[9px] font-mono uppercase tracking-wider text-vanta-ink-muted mb-1">Brand Name</label>
                      <select
                        value={vehicleForm.brand_id}
                        onChange={(e) => {
                          const id = Number(e.target.value);
                          setVehicleForm({
                            ...vehicleForm,
                            brand_id: id,
                            brand: BRAND_NAMES[id] || ''
                          });
                        }}
                        className="w-full bg-vanta-paper border border-vanta-border rounded-xl py-2.5 px-3 text-xs text-white focus:outline-none focus:border-vanta-amber"
                      >
                        {Object.entries(BRAND_NAMES).map(([id, name]) => (
                          <option key={id} value={id}>{name}</option>
                        ))}
                      </select>
                    </div>
                    <div>
                      <label className="block text-[9px] font-mono uppercase tracking-wider text-vanta-ink-muted mb-1">Category Type</label>
                      <select
                        value={vehicleForm.category_id}
                        onChange={(e) => {
                          const id = Number(e.target.value);
                          setVehicleForm({
                            ...vehicleForm,
                            category_id: id
                          });
                        }}
                        className="w-full bg-vanta-paper border border-vanta-border rounded-xl py-2.5 px-3 text-xs text-white focus:outline-none focus:border-vanta-amber"
                      >
                        {Object.entries(CATEGORY_NAMES).map(([id, name]) => (
                          <option key={id} value={id}>{name}</option>
                        ))}
                      </select>
                    </div>
                  </div>

                  {/* Row 3 */}
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                      <label className="block text-[9px] font-mono uppercase tracking-wider text-vanta-ink-muted mb-1">Daily rate (AED / day)</label>
                      <input
                        type="number"
                        value={vehicleForm.pricing.daily}
                        onChange={(e) => setVehicleForm({ ...vehicleForm, pricing: { ...vehicleForm.pricing, daily: Number(e.target.value) } })}
                        className="w-full bg-vanta-paper border border-vanta-border rounded-xl py-2.5 px-3 text-xs text-white focus:outline-none focus:border-vanta-amber"
                      />
                    </div>
                    <div>
                      <label className="block text-[9px] font-mono uppercase tracking-wider text-vanta-ink-muted mb-1">Weekly rate (AED / day)</label>
                      <input
                        type="number"
                        value={vehicleForm.pricing.weekly}
                        onChange={(e) => setVehicleForm({ ...vehicleForm, pricing: { ...vehicleForm.pricing, weekly: Number(e.target.value) } })}
                        className="w-full bg-vanta-paper border border-vanta-border rounded-xl py-2.5 px-3 text-xs text-white focus:outline-none focus:border-vanta-amber"
                      />
                    </div>
                    <div>
                      <label className="block text-[9px] font-mono uppercase tracking-wider text-vanta-ink-muted mb-1">Monthly rate (AED / month)</label>
                      <input
                        type="number"
                        value={vehicleForm.pricing.monthly}
                        onChange={(e) => setVehicleForm({ ...vehicleForm, pricing: { ...vehicleForm.pricing, monthly: Number(e.target.value) } })}
                        className="w-full bg-vanta-paper border border-vanta-border rounded-xl py-2.5 px-3 text-xs text-white focus:outline-none focus:border-vanta-amber"
                      />
                    </div>
                  </div>

                  {/* Specs */}
                  <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
                    <div>
                      <label className="block text-[9px] font-mono uppercase tracking-wider text-vanta-ink-muted mb-1">Engine specs</label>
                      <input
                        type="text"
                        value={vehicleForm.specifications.engine}
                        onChange={(e) => setVehicleForm({ ...vehicleForm, specifications: { ...vehicleForm.specifications, engine: e.target.value } })}
                        className="w-full bg-vanta-paper border border-vanta-border rounded-xl py-2.5 px-3 text-xs text-white focus:outline-none focus:border-vanta-amber"
                      />
                    </div>
                    <div>
                      <label className="block text-[9px] font-mono uppercase tracking-wider text-vanta-ink-muted mb-1">Power specs</label>
                      <input
                        type="text"
                        value={vehicleForm.specifications.power}
                        onChange={(e) => setVehicleForm({ ...vehicleForm, specifications: { ...vehicleForm.specifications, power: e.target.value } })}
                        className="w-full bg-vanta-paper border border-vanta-border rounded-xl py-2.5 px-3 text-xs text-white focus:outline-none focus:border-vanta-amber"
                      />
                    </div>
                    <div>
                      <label className="block text-[9px] font-mono uppercase tracking-wider text-vanta-ink-muted mb-1">Transmission type</label>
                      <select
                        value={vehicleForm.specifications.transmission}
                        onChange={(e) => setVehicleForm({ ...vehicleForm, specifications: { ...vehicleForm.specifications, transmission: e.target.value } })}
                        className="w-full bg-vanta-paper border border-vanta-border rounded-xl py-2.5 px-3 text-xs text-white focus:outline-none focus:border-vanta-amber"
                      >
                        <option value="auto">Automatic</option>
                        <option value="manual">Manual</option>
                      </select>
                    </div>
                    <div>
                      <label className="block text-[9px] font-mono uppercase tracking-wider text-vanta-ink-muted mb-1">Seats count</label>
                      <input
                        type="number"
                        value={vehicleForm.specifications.seats}
                        onChange={(e) => setVehicleForm({ ...vehicleForm, specifications: { ...vehicleForm.specifications, seats: Number(e.target.value) } })}
                        className="w-full bg-vanta-paper border border-vanta-border rounded-xl py-2.5 px-3 text-xs text-white focus:outline-none focus:border-vanta-amber"
                      />
                    </div>
                  </div>

                  {/* Description */}
                  <div>
                    <label className="block text-[9px] font-mono uppercase tracking-wider text-vanta-ink-muted mb-1">Tagline</label>
                    <input
                      type="text"
                      value={vehicleForm.tagline}
                      onChange={(e) => setVehicleForm({ ...vehicleForm, tagline: e.target.value })}
                      className="w-full bg-vanta-paper border border-vanta-border rounded-xl py-2.5 px-3 text-xs text-white focus:outline-none focus:border-vanta-amber"
                    />
                  </div>
                  <div>
                    <label className="block text-[9px] font-mono uppercase tracking-wider text-vanta-ink-muted mb-1">Description text</label>
                    <textarea
                      value={vehicleForm.description}
                      onChange={(e) => setVehicleForm({ ...vehicleForm, description: e.target.value })}
                      className="w-full bg-vanta-paper border border-vanta-border rounded-xl py-2.5 px-3 text-xs text-white h-24 focus:outline-none focus:border-vanta-amber"
                    />
                  </div>

                  {/* Toggles */}
                  <div className="flex gap-6 pt-2">
                    <label className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={vehicleForm.featured}
                        onChange={(e) => setVehicleForm({ ...vehicleForm, featured: e.target.checked })}
                        className="h-4 w-4 bg-vanta-paper border border-vanta-border text-vanta-amber focus:ring-vanta-amber rounded"
                      />
                      <span className="text-xs font-mono uppercase text-vanta-ink-muted">Featured Card</span>
                    </label>
                    <label className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={vehicleForm.is_popular}
                        onChange={(e) => setVehicleForm({ ...vehicleForm, is_popular: e.target.checked })}
                        className="h-4 w-4 bg-vanta-paper border border-vanta-border text-vanta-amber focus:ring-vanta-amber rounded"
                      />
                      <span className="text-xs font-mono uppercase text-vanta-ink-muted">Popular Car</span>
                    </label>
                    <div>
                      <label className="block text-[10px] font-mono uppercase text-vanta-ink-muted mb-1">Vehicle Quantity</label>
                      <input
                        type="number"
                        min="0"
                        value={vehicleForm.quantity ?? 1}
                        onChange={(e) => setVehicleForm({ ...vehicleForm, quantity: parseInt(e.target.value) || 0 })}
                        className="w-full bg-vanta-paper border border-vanta-border rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-vanta-amber"
                      />
                    </div>
                    <label className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={vehicleForm.available}
                        onChange={(e) => setVehicleForm({ ...vehicleForm, available: e.target.checked })}
                        className="h-4 w-4 bg-vanta-paper border border-vanta-border text-vanta-amber focus:ring-vanta-amber rounded"
                      />
                      <span className="text-xs font-mono uppercase text-vanta-ink-muted">Available lease</span>
                    </label>
                  </div>

                  {/* Media / Images Section */}
                  <div className="border-t border-vanta-border pt-6 mt-6">
                    <h4 className="font-grotesk font-bold text-white text-sm mb-3">Vehicle Media / Images</h4>
                    
                    {/* Previews of existing or selected images */}
                    <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-4">
                      {/* DB Previews (Existing images) */}
                      {editingVehicleId && (() => {
                        const currentEditingCar = fleet.find(v => v.id === editingVehicleId);
                        return [
                          ...(currentEditingCar?.images?.thumbnail 
                            ? [{ url: currentEditingCar.images.thumbnail, type: 'thumbnail' }] 
                            : []),
                          ...(currentEditingCar?.images?.exterior?.map(url => ({ url, type: 'exterior' })) || []),
                          ...(currentEditingCar?.images?.interior?.map(url => ({ url, type: 'interior' })) || []),
                        ].map((item: any, idx: number) => (
                          <div key={idx} className="relative aspect-[4/3] rounded-lg overflow-hidden border border-vanta-border bg-vanta-paper group">
                            <img src={item.url} alt={item.type} className="w-full h-full object-cover" />
                            <span className="absolute bottom-1 left-1 bg-black/70 text-[8px] font-mono uppercase text-vanta-amber px-1.5 py-0.5 rounded border border-white/10">
                              {item.type}
                            </span>
                            <button
                              type="button"
                              onClick={async () => {
                                try {
                                  const { data } = await api.get(`/vehicles/${editingVehicleId}`);
                                  const rawImages = data.images || [];
                                  const match = rawImages.find((img: any) => item.url.endsWith(img.image_url));
                                  if (match) {
                                    await api.delete(`/vehicles/images/${match.id}`);
                                    queryClient.invalidateQueries({ queryKey: ['admin-vehicles'] });
                                    addToast("Image deleted", "success");
                                  } else {
                                    addToast("Image reference not found in database", "error");
                                  }
                                } catch {
                                  addToast("Failed to delete image", "error");
                                }
                              }}
                              className="absolute top-1.5 right-1.5 p-1.5 rounded-md bg-black/60 hover:bg-red-500/80 text-white opacity-0 group-hover:opacity-100 transition-opacity"
                              title="Delete Image"
                            >
                              <Trash2 size={10} />
                            </button>
                          </div>
                        ));
                      })()}

                      {/* Local Previews (Queued local files) */}
                      {selectedFiles.map((item, idx) => (
                        <div key={`local-${idx}`} className="relative aspect-[4/3] rounded-lg overflow-hidden border border-vanta-border bg-vanta-paper group">
                          <img src={item.previewUrl} alt={item.type} className="w-full h-full object-cover" />
                          <span className="absolute bottom-1 left-1 bg-black/70 text-[8px] font-mono uppercase text-vanta-amber px-1.5 py-0.5 rounded border border-white/10">
                            {item.type} (new)
                          </span>
                          <button
                            type="button"
                            onClick={() => {
                              setSelectedFiles(selectedFiles.filter((_, i) => i !== idx));
                            }}
                            className="absolute top-1.5 right-1.5 p-1.5 rounded-md bg-black/60 hover:bg-red-500/80 text-white opacity-0 group-hover:opacity-100 transition-opacity"
                            title="Remove Image"
                          >
                            <X size={10} />
                          </button>
                        </div>
                      ))}
                    </div>

                    {/* Image Type Selector + Upload Input Area */}
                    <div className="flex flex-col gap-3">
                      <div className="flex items-center gap-3">
                        <span className="font-mono text-[9px] uppercase tracking-wider text-vanta-ink-muted">Upload Category:</span>
                        <div className="flex gap-2">
                          {(['thumbnail', 'exterior', 'interior'] as const).map(type => (
                            <button
                              key={type}
                              type="button"
                              onClick={() => setModalUploadType(type)}
                              className={`px-2.5 py-1 rounded text-[9px] font-mono uppercase border transition-all ${
                                modalUploadType === type 
                                  ? 'bg-vanta-amber border-vanta-amber text-white' 
                                  : 'border-vanta-border text-vanta-ink-muted hover:border-vanta-amber/40 hover:text-white'
                              }`}
                            >
                              {type}
                            </button>
                          ))}
                        </div>
                      </div>

                      <div className="border border-dashed border-vanta-border hover:border-vanta-amber/50 rounded-xl p-6 text-center bg-vanta-paper-soft hover:bg-vanta-paper transition-all relative">
                        <input
                          type="file"
                          onChange={(e) => {
                            const file = e.target.files?.[0];
                            if (!file) return;
                            const previewUrl = URL.createObjectURL(file);
                            setSelectedFiles([
                              ...selectedFiles,
                              { file, previewUrl, type: modalUploadType }
                            ]);
                            addToast(`Image queued as ${modalUploadType}`, "info");
                          }}
                          className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                          accept="image/*"
                        />
                        <Upload size={20} className="text-vanta-ink-subtle mx-auto mb-1.5" />
                        <span className="block text-xs font-mono uppercase text-white/90">Add New Image ({modalUploadType})</span>
                        <span className="block text-[9px] text-vanta-ink-subtle mt-0.5">PNG, JPG or WEBP format</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Modal Footer */}
              <div className="p-6 border-t border-vanta-border flex gap-4 bg-vanta-panel justify-end">
                <button
                  onClick={() => {
                    setSelectedFiles([]);
                    setVehicleModalOpen(false);
                  }}
                  className="px-6 py-3 border border-vanta-border hover:bg-white/5 rounded-xl font-grotesk font-semibold text-xs text-vanta-ink-muted hover:text-white transition-all uppercase tracking-wider"
                >
                  Cancel
                </button>
                <button
                  onClick={() => saveVehicleMutation.mutate()}
                  disabled={saveVehicleMutation.isPending}
                  className="bg-vanta-amber hover:bg-orange-500 text-white font-grotesk font-semibold text-xs px-6 py-3 rounded-xl transition-all shadow-amber-sm flex items-center gap-2 uppercase tracking-wider"
                >
                  {saveVehicleMutation.isPending ? <Loader2 className="w-4 h-4 animate-spin" /> : <Plus size={12} />}
                  Save Specifications
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* ── IMAGE UPLOAD MODAL ── */}
      <AnimatePresence>
        {uploadingVehicleId !== null && (
          <div className="fixed inset-0 z-[1000] flex items-center justify-center p-4">
            <div className="fixed inset-0 bg-black/80 backdrop-blur-sm" onClick={() => setUploadingVehicleId(null)} />
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              className="bg-vanta-panel border border-vanta-border w-full max-w-[550px] rounded-2xl p-8 z-50 relative space-y-6"
            >
              <div>
                <h3 className="font-grotesk text-2xl font-bold text-white border-b border-vanta-border pb-3 mb-4">
                  Manage Car Media
                </h3>
                <p className="text-xs text-vanta-ink-muted">
                  Add high-resolution luxury exterior or interior images. These are stored on the server and updated in the SQLite index.
                </p>
              </div>

              {/* Upload Input Area */}
              <div className="border-2 border-dashed border-vanta-border hover:border-vanta-amber/50 rounded-xl p-8 text-center bg-vanta-paper-soft hover:bg-vanta-paper transition-all relative">
                <input
                  type="file"
                  onChange={handleUploadImage}
                  className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                  accept="image/*"
                />
                <Upload size={32} className="text-vanta-ink-subtle mx-auto mb-2" />
                <span className="block text-xs font-mono uppercase text-white/90">Select Media file</span>
                <span className="block text-[10px] text-vanta-ink-subtle mt-1">PNG, JPG or WEBP formats</span>
              </div>

              {/* Footer Actions */}
              <div className="flex justify-end gap-3 border-t border-vanta-border pt-4">
                <button
                  onClick={() => setUploadingVehicleId(null)}
                  className="px-6 py-2.5 bg-vanta-amber text-white font-grotesk font-semibold text-xs rounded-xl hover:bg-orange-500 transition-colors shadow-amber-sm"
                >
                  Done
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* DELETE CONFIRMATION MODAL */}
      <AnimatePresence>
        {deleteConfirmOpen && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
            <motion.div
              initial={{ scale: 0.95, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.95, opacity: 0 }}
              transition={{ ease: ease.out, duration: duration.normal }}
              className="bg-vanta-panel border border-vanta-border rounded-2xl p-6 max-w-sm w-full shadow-2xl text-center"
            >
              <div className="flex justify-center mb-4 text-red-500">
                <ShieldAlert size={48} className="animate-pulse" />
              </div>
              <h3 className="font-grotesk font-bold text-lg text-white mb-2">Delete Vehicle?</h3>
              <p className="text-[11px] text-vanta-ink-subtle mb-6 leading-relaxed">
                Are you sure you want to delete this vehicle? You can choose to <strong>Deactivate</strong> it instead, which hides it from the public catalog while preserving all booking history and specifications data.
              </p>
              <div className="flex flex-col gap-2">
                <div className="flex gap-2">
                  <button
                    onClick={() => {
                      if (vehicleToDeleteId) {
                        toggleStatusMutation.mutate({ id: vehicleToDeleteId, available: false });
                      }
                      setDeleteConfirmOpen(false);
                    }}
                    className="flex-1 py-2.5 rounded-xl bg-orange-500 hover:bg-orange-600 text-[10px] uppercase tracking-wider text-white font-bold transition-all"
                  >
                    Deactivate
                  </button>
                  <button
                    onClick={() => {
                      if (vehicleToDeleteId) {
                        deleteVehicleMutation.mutate(vehicleToDeleteId);
                      }
                      setDeleteConfirmOpen(false);
                    }}
                    className="flex-1 py-2.5 rounded-xl bg-red-600 hover:bg-red-500 text-[9px] uppercase tracking-wider text-white font-bold transition-all"
                  >
                    Permanently Delete
                  </button>
                </div>
                <button
                  onClick={() => setDeleteConfirmOpen(false)}
                  className="w-full py-2.5 rounded-xl border border-vanta-border hover:bg-white/5 text-[10px] uppercase tracking-wider text-white font-bold transition-all"
                >
                  Cancel
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

    </div>
  );
};

export default AdminDashboard;
