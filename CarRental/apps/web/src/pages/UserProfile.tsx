import React, { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useNavigate, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { User, ShoppingBag, Heart, Shield, LogOut, ArrowLeft, Loader2, Save } from 'lucide-react';

import { useAuthStore } from '../store/authStore';
import { useToastStore, useAppStore } from '../store';
import api from '../services/api/axios';
import { vehicleService } from '../services/api/vehicles';
import { ease, duration } from '../lib/easing';
import { formatAED } from '../lib/formatters';
import Navbar from '../components/layout/Navbar';

const profileSchema = z.object({
  firstName: z.string().min(2, 'First name must be at least 2 characters'),
  lastName: z.string().min(2, 'Last name must be at least 2 characters'),
  phone: z.string().min(8, 'Phone number must be at least 8 characters'),
  country: z.string().min(2, 'Country must be at least 2 characters'),
});

const passwordSchema = z.object({
  oldPassword: z.string().min(6, 'Old password must be at least 6 characters'),
  newPassword: z.string().min(6, 'New password must be at least 6 characters'),
  confirmNewPassword: z.string(),
}).refine((data) => data.newPassword === data.confirmNewPassword, {
  message: "New passwords do not match",
  path: ["confirmNewPassword"],
});

type ProfileFormType = z.infer<typeof profileSchema>;
type PasswordFormType = z.infer<typeof passwordSchema>;

const UserProfile: React.FC = () => {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { user, logout, updateUser } = useAuthStore();
  const { addToast } = useToastStore();
  const { wishlist } = useAppStore();
  const [activeTab, setActiveTab] = useState<'profile' | 'bookings' | 'saved' | 'security'>('profile');

  // Fetch my bookings
  const { data: bookings = [], isLoading: bookingsLoading } = useQuery({
    queryKey: ['my-bookings'],
    queryFn: async () => {
      const { data } = await api.get('/users/me/bookings');
      return data;
    },
    enabled: activeTab === 'bookings',
  });

  // Fetch all vehicles to display wishlist details
  const { data: fleet = [] } = useQuery({
    queryKey: ['vehicles', 'all'],
    queryFn: () => vehicleService.getVehicles(),
    enabled: activeTab === 'saved',
  });

  const savedVehicles = fleet.filter(v => wishlist.includes(v.id));

  // Profile Form
  const {
    register: regProfile,
    handleSubmit: handleProfileSubmit,
    formState: { errors: profileErrors },
  } = useForm<ProfileFormType>({
    resolver: zodResolver(profileSchema),
    defaultValues: {
      firstName: user?.first_name || '',
      lastName: user?.last_name || '',
      phone: user?.phone || '',
      country: user?.country || '',
    }
  });

  // Password Form
  const {
    register: regPassword,
    handleSubmit: handlePasswordSubmit,
    reset: resetPasswordForm,
    formState: { errors: passwordErrors },
  } = useForm<PasswordFormType>({
    resolver: zodResolver(passwordSchema),
  });

  // Mutations
  const updateProfileMutation = useMutation({
    mutationFn: async (data: ProfileFormType) => {
      const response = await api.put('/users/me', {
        first_name: data.firstName,
        last_name: data.lastName,
        phone: data.phone,
        country: data.country,
      });
      return response.data;
    },
    onSuccess: (data) => {
      updateUser(data);
      addToast("Profile details updated successfully", "success");
    },
    onError: (err: any) => {
      addToast(err.response?.data?.detail || "Failed to update profile", "error");
    }
  });

  const changePasswordMutation = useMutation({
    mutationFn: async (data: PasswordFormType) => {
      await api.put('/users/me/password', {
        old_password: data.oldPassword,
        new_password: data.newPassword,
      });
    },
    onSuccess: () => {
      addToast("Password changed successfully", "success");
      resetPasswordForm();
    },
    onError: (err: any) => {
      addToast(err.response?.data?.detail || "Failed to change password", "error");
    }
  });

  const handleLogout = () => {
    logout();
    addToast("Logged out of session.", "info");
    navigate('/');
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'confirmed': return 'text-green-400 bg-green-500/10 border-green-500/20';
      case 'pending': return 'text-amber-400 bg-amber-500/10 border-amber-500/20';
      case 'cancelled': return 'text-red-400 bg-red-500/10 border-red-500/20';
      default: return 'text-gray-400 bg-gray-500/10 border-gray-500/20';
    }
  };

  return (
    <div className="min-h-screen bg-vanta-paper text-vanta-ink">
      <Navbar />

      <div className="section-container pt-36 pb-32 md:pb-24">
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-6 mb-12 border-b border-vanta-border pb-8">
          <div>
            <Link to="/" className="inline-flex items-center gap-2 text-xs font-mono uppercase tracking-wider text-vanta-amber hover:underline mb-3">
              <ArrowLeft size={12} /> Back to Home
            </Link>
            <h1 className="font-grotesk text-4xl font-extrabold text-white">
              My Credentials
            </h1>
            <p className="text-vanta-ink-muted text-sm mt-1">
              Logged in as: <span className="font-mono text-white/90">{user?.email}</span>
            </p>
          </div>
          <button
            onClick={handleLogout}
            className="flex items-center gap-2 border border-red-500/30 hover:border-red-500/80 bg-red-500/5 hover:bg-red-500/10 text-red-400 font-grotesk font-semibold text-xs px-5 py-3 rounded-xl transition-all self-start md:self-center"
          >
            <LogOut size={14} /> End Session
          </button>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
          {/* Tabs Sidebar */}
          <div className="flex flex-row lg:flex-col overflow-x-auto lg:overflow-visible gap-2 border-b lg:border-b-0 border-vanta-border pb-4 lg:pb-0">
            <button
              onClick={() => setActiveTab('profile')}
              className={`flex items-center gap-3 px-5 py-3.5 rounded-xl font-grotesk font-semibold text-sm transition-all whitespace-nowrap ${
                activeTab === 'profile' ? 'bg-vanta-amber text-white shadow-amber-sm' : 'text-vanta-ink-muted hover:text-white hover:bg-vanta-panel'
              }`}
            >
              <User size={16} /> Profile Details
            </button>
            <button
              onClick={() => setActiveTab('bookings')}
              className={`flex items-center gap-3 px-5 py-3.5 rounded-xl font-grotesk font-semibold text-sm transition-all whitespace-nowrap ${
                activeTab === 'bookings' ? 'bg-vanta-amber text-white shadow-amber-sm' : 'text-vanta-ink-muted hover:text-white hover:bg-vanta-panel'
              }`}
            >
              <ShoppingBag size={16} /> My Bookings
            </button>
            <button
              onClick={() => setActiveTab('saved')}
              className={`flex items-center gap-3 px-5 py-3.5 rounded-xl font-grotesk font-semibold text-sm transition-all whitespace-nowrap ${
                activeTab === 'saved' ? 'bg-vanta-amber text-white shadow-amber-sm' : 'text-vanta-ink-muted hover:text-white hover:bg-vanta-panel'
              }`}
            >
              <Heart size={16} /> Saved Vehicles
            </button>
            <button
              onClick={() => setActiveTab('security')}
              className={`flex items-center gap-3 px-5 py-3.5 rounded-xl font-grotesk font-semibold text-sm transition-all whitespace-nowrap ${
                activeTab === 'security' ? 'bg-vanta-amber text-white shadow-amber-sm' : 'text-vanta-ink-muted hover:text-white hover:bg-vanta-panel'
              }`}
            >
              <Shield size={16} /> Vault Security
            </button>
          </div>

          {/* Tab Content Panel */}
          <div className="lg:col-span-3 bg-vanta-panel border border-vanta-border rounded-2xl p-8 relative overflow-hidden backdrop-blur-xl">
            
            {/* PROFILE TAB */}
            {activeTab === 'profile' && (
              <form onSubmit={handleProfileSubmit(onSubmit => updateProfileMutation.mutate(onSubmit))} className="space-y-6">
                <h3 className="font-grotesk text-xl font-bold text-white border-b border-vanta-border pb-3 mb-6">Profile Settings</h3>
                
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <label className="block text-[11px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">First Name</label>
                    <input
                      type="text"
                      {...regProfile('firstName')}
                      className={`w-full bg-vanta-paper border ${
                        profileErrors.firstName ? 'border-red-500/50' : 'border-vanta-border'
                      } rounded-xl py-3.5 px-4 text-sm text-white focus:outline-none focus:border-vanta-amber transition-all`}
                    />
                    {profileErrors.firstName && <p className="text-xs text-red-400 font-mono">{profileErrors.firstName.message}</p>}
                  </div>
                  <div className="space-y-2">
                    <label className="block text-[11px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">Last Name</label>
                    <input
                      type="text"
                      {...regProfile('lastName')}
                      className={`w-full bg-vanta-paper border ${
                        profileErrors.lastName ? 'border-red-500/50' : 'border-vanta-border'
                      } rounded-xl py-3.5 px-4 text-sm text-white focus:outline-none focus:border-vanta-amber transition-all`}
                    />
                    {profileErrors.lastName && <p className="text-xs text-red-400 font-mono">{profileErrors.lastName.message}</p>}
                  </div>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                  <div className="space-y-2">
                    <label className="block text-[11px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">Phone Number</label>
                    <input
                      type="tel"
                      {...regProfile('phone')}
                      className={`w-full bg-vanta-paper border ${
                        profileErrors.phone ? 'border-red-500/50' : 'border-vanta-border'
                      } rounded-xl py-3.5 px-4 text-sm text-white focus:outline-none focus:border-vanta-amber transition-all`}
                    />
                    {profileErrors.phone && <p className="text-xs text-red-400 font-mono">{profileErrors.phone.message}</p>}
                  </div>
                  <div className="space-y-2">
                    <label className="block text-[11px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">Country</label>
                    <input
                      type="text"
                      {...regProfile('country')}
                      className={`w-full bg-vanta-paper border ${
                        profileErrors.country ? 'border-red-500/50' : 'border-vanta-border'
                      } rounded-xl py-3 px-4 text-sm text-white focus:outline-none focus:border-vanta-amber transition-all`}
                    />
                    {profileErrors.country && <p className="text-xs text-red-400 font-mono">{profileErrors.country.message}</p>}
                  </div>
                </div>

                <div className="pt-4">
                  <motion.button
                    whileHover={{ scale: 1.01 }}
                    whileTap={{ scale: 0.99 }}
                    type="submit"
                    disabled={updateProfileMutation.isPending}
                    className="bg-vanta-amber hover:bg-orange-500 text-white font-grotesk font-semibold text-xs px-6 py-3.5 rounded-xl transition-all shadow-amber-sm flex items-center gap-2"
                  >
                    {updateProfileMutation.isPending ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save size={14} />}
                    Save Profile Settings
                  </motion.button>
                </div>
              </form>
            )}

            {/* BOOKINGS TAB */}
            {activeTab === 'bookings' && (
              <div className="space-y-6">
                <h3 className="font-grotesk text-xl font-bold text-white border-b border-vanta-border pb-3 mb-6">Booking History</h3>
                
                {bookingsLoading ? (
                  <div className="flex items-center justify-center py-16">
                    <Loader2 className="w-8 h-8 text-vanta-amber animate-spin" />
                  </div>
                ) : bookings.length === 0 ? (
                  <div className="text-center py-16">
                    <ShoppingBag className="w-12 h-12 text-vanta-ink-subtle mx-auto mb-4" />
                    <p className="text-vanta-ink-muted text-sm font-mono uppercase tracking-wider mb-4">No active booking leases</p>
                    <Link to="/fleet" className="inline-block bg-vanta-amber text-white font-grotesk font-semibold text-xs px-6 py-3 rounded-xl hover:bg-orange-500 transition-colors shadow-amber-sm">
                      Rent a Car
                    </Link>
                  </div>
                ) : (
                  <div className="space-y-4">
                    {bookings.map((booking: any) => (
                      <div key={booking.id} className="border border-vanta-border rounded-xl p-5 bg-vanta-paper-soft hover:border-vanta-amber/30 transition-all flex flex-col sm:flex-row justify-between sm:items-center gap-4">
                        <div>
                          <div className="flex items-center gap-3 mb-2">
                            <span className="font-mono text-xs text-vanta-amber">LEASE #{booking.id}</span>
                            <span className={`text-[10px] font-mono uppercase px-2 py-0.5 rounded border ${getStatusColor(booking.status)}`}>
                              {booking.status}
                            </span>
                          </div>
                          <h4 className="font-grotesk font-bold text-white text-lg">{booking.vehicle?.name}</h4>
                          <p className="text-vanta-ink-muted text-xs font-mono mt-1">
                            {booking.startDate.split('T')[0]} to {booking.endDate.split('T')[0]}
                          </p>
                        </div>
                        <div className="text-left sm:text-right border-t sm:border-t-0 border-vanta-border pt-4 sm:pt-0">
                          <span className="text-[10px] font-mono uppercase text-vanta-ink-muted block">Total Lease Cost</span>
                          <span className="font-grotesk font-bold text-white text-xl">{formatAED(booking.totalPrice)}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}

            {/* SAVED CARS TAB */}
            {activeTab === 'saved' && (
              <div className="space-y-6">
                <h3 className="font-grotesk text-xl font-bold text-white border-b border-vanta-border pb-3 mb-6">Saved Luxury Vehicles</h3>
                
                {savedVehicles.length === 0 ? (
                  <div className="text-center py-16">
                    <Heart className="w-12 h-12 text-vanta-ink-subtle mx-auto mb-4" />
                    <p className="text-vanta-ink-muted text-sm font-mono uppercase tracking-wider mb-4">Your wishlist is empty</p>
                    <Link to="/fleet" className="inline-block bg-vanta-amber text-white font-grotesk font-semibold text-xs px-6 py-3 rounded-xl hover:bg-orange-500 transition-colors shadow-amber-sm">
                      Explore Fleet
                    </Link>
                  </div>
                ) : (
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {savedVehicles.map((car) => (
                      <Link to={`/vehicles/${car.slug}`} key={car.id} className="border border-vanta-border rounded-xl overflow-hidden bg-vanta-paper-soft hover:border-vanta-amber/30 transition-all flex items-center">
                        <div className="w-1/3 aspect-[4/3] bg-vanta-paper border-r border-vanta-border">
                          <img src={car.images.thumbnail} alt={car.name} className="w-full h-full object-cover" />
                        </div>
                        <div className="p-4 w-2/3">
                          <span className="text-[9px] font-mono uppercase text-vanta-amber tracking-wider block mb-1">{car.brand}</span>
                          <h4 className="font-grotesk font-bold text-white text-sm truncate">{car.name}</h4>
                          <span className="font-mono text-xs text-vanta-ink-muted block mt-2">Starting at {formatAED(car.pricePerDay)}/day</span>
                        </div>
                      </Link>
                    ))}
                  </div>
                )}
              </div>
            )}

            {/* SECURITY TAB */}
            {activeTab === 'security' && (
              <form onSubmit={handlePasswordSubmit(onSubmit => changePasswordMutation.mutate(onSubmit))} className="space-y-6">
                <h3 className="font-grotesk text-xl font-bold text-white border-b border-vanta-border pb-3 mb-6">Vault Security Settings</h3>
                
                <div className="space-y-4">
                  <div className="space-y-2">
                    <label className="block text-[11px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">Old Security Code</label>
                    <input
                      type="password"
                      placeholder="••••••••"
                      {...regPassword('oldPassword')}
                      className={`w-full bg-vanta-paper border ${
                        passwordErrors.oldPassword ? 'border-red-500/50' : 'border-vanta-border'
                      } rounded-xl py-3 px-4 text-sm text-white focus:outline-none focus:border-vanta-amber transition-all`}
                    />
                    {passwordErrors.oldPassword && <p className="text-xs text-red-400 font-mono">{passwordErrors.oldPassword.message}</p>}
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="space-y-2">
                      <label className="block text-[11px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">New Security Code</label>
                      <input
                        type="password"
                        placeholder="••••••••"
                        {...regPassword('newPassword')}
                        className={`w-full bg-vanta-paper border ${
                          passwordErrors.newPassword ? 'border-red-500/50' : 'border-vanta-border'
                        } rounded-xl py-3 px-4 text-sm text-white focus:outline-none focus:border-vanta-amber transition-all`}
                      />
                      {passwordErrors.newPassword && <p className="text-xs text-red-400 font-mono">{passwordErrors.newPassword.message}</p>}
                    </div>

                    <div className="space-y-2">
                      <label className="block text-[11px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">Confirm New Security Code</label>
                      <input
                        type="password"
                        placeholder="••••••••"
                        {...regPassword('confirmNewPassword')}
                        className={`w-full bg-vanta-paper border ${
                          passwordErrors.confirmNewPassword ? 'border-red-500/50' : 'border-vanta-border'
                        } rounded-xl py-3 px-4 text-sm text-white focus:outline-none focus:border-vanta-amber transition-all`}
                      />
                      {passwordErrors.confirmNewPassword && <p className="text-xs text-red-400 font-mono">{passwordErrors.confirmNewPassword.message}</p>}
                    </div>
                  </div>
                </div>

                <div className="pt-4">
                  <motion.button
                    whileHover={{ scale: 1.01 }}
                    whileTap={{ scale: 0.99 }}
                    type="submit"
                    disabled={changePasswordMutation.isPending}
                    className="bg-vanta-amber hover:bg-orange-500 text-white font-grotesk font-semibold text-xs px-6 py-3.5 rounded-xl transition-all shadow-amber-sm flex items-center gap-2"
                  >
                    {changePasswordMutation.isPending ? <Loader2 className="w-4 h-4 animate-spin" /> : <Shield size={14} />}
                    Update Vault Code
                  </motion.button>
                </div>
              </form>
            )}

          </div>
        </div>
      </div>
    </div>
  );
};

export default UserProfile;
