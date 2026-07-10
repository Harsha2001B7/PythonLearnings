import React, { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { useNavigate, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Eye, EyeOff, User, Lock, Mail, Phone, Globe, ArrowRight } from 'lucide-react';

import { useToastStore } from '../store';
import { useAuthStore } from '../store/authStore';
import api from '../services/api/axios';
import { ease, duration } from '../lib/easing';
import falconLogo from '../../assets/falconviewLogotrans.png';
import SEO from '../components/seo/SEO';

const registerSchema = z.object({
  firstName: z.string().min(2, 'First name must be at least 2 characters'),
  lastName: z.string().min(2, 'Last name must be at least 2 characters'),
  email: z.string().email('Please enter a valid email address'),
  phone: z.string().min(8, 'Please enter a valid phone number'),
  country: z.string().min(2, 'Please select your country'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  confirmPassword: z.string(),
  acceptTerms: z.boolean().refine(val => val === true, 'You must accept the Terms of Service'),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords do not match",
  path: ["confirmPassword"],
});

type RegisterSchemaType = z.infer<typeof registerSchema>;

const Register: React.FC = () => {
  const navigate = useNavigate();
  const { addToast } = useToastStore();
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const { login } = useAuthStore();

  useEffect(() => {
    const script = document.createElement('script');
    script.src = 'https://accounts.google.com/gsi/client';
    script.async = true;
    script.defer = true;
    script.onload = () => {
      const g = (window as any).google;
      if (g) {
        g.accounts.id.initialize({
          client_id: import.meta.env.VITE_GOOGLE_CLIENT_ID || '291772363929-25to6jat1j1puo3kmghrlf3aue5b3qvh.apps.googleusercontent.com',
          callback: async (response: any) => {
            setLoading(true);
            try {
              const res = await api.post('/auth/google', {
                id_token: response.credential
              });
              const { access_token, refresh_token } = res.data;
              const profileResponse = await api.get('/auth/me', {
                headers: { Authorization: `Bearer ${access_token}` }
              });
              login(access_token, refresh_token, profileResponse.data, true);
              addToast(`Welcome, ${profileResponse.data.first_name || 'User'}!`, 'success');
              if (profileResponse.data.role_id === 1) {
                navigate('/admin');
              } else {
                navigate('/', { replace: true });
              }
            } catch (err: any) {
              addToast(err.response?.data?.detail || 'Google Sign-In failed', 'error');
            } finally {
              setLoading(false);
            }
          }
        });
        g.accounts.id.renderButton(
          document.getElementById('google-signup-btn'),
          { theme: 'outline', size: 'large', width: 436, text: 'continue_with', logo_alignment: 'left' }
        );
      }
    };
    document.body.appendChild(script);
    return () => {
      document.body.removeChild(script);
    };
  }, [navigate, login, addToast]);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<RegisterSchemaType>({
    resolver: zodResolver(registerSchema),
  });

  const onSubmit = async (data: RegisterSchemaType) => {
    setLoading(true);
    try {
      await api.post('/auth/register', {
        email: data.email,
        first_name: data.firstName,
        last_name: data.lastName,
        phone: data.phone,
        country: data.country,
        password: data.password,
      });

      addToast("Your invitation has been accepted! Please sign in.", "success");
      navigate('/login');
    } catch (error: any) {
      const errMsg = error.response?.data?.detail || 'Registration failed. Please try again.';
      addToast(errMsg, 'error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
    <SEO title="Register | Falcon View Car Rentals" canonicalUrl="/register" />
    <div className="min-h-screen bg-vanta-paper text-vanta-ink flex items-center justify-center px-4 py-12 relative overflow-hidden">
      {/* Decorative Blur Orbs */}
      <div className="absolute top-1/4 left-1/4 w-96 h-96 rounded-full bg-vanta-amber/5 blur-[120px]" />
      <div className="absolute bottom-1/4 right-1/4 w-96 h-96 rounded-full bg-orange-600/5 blur-[120px]" />

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: duration.slow, ease: ease.elegant }}
        className="w-full max-w-[500px] z-10"
      >
        {/* Logo and Header */}
        <div className="text-center mb-8">
          <Link to="/" className="inline-block mb-4">
            <img src={falconLogo} alt="Falcon View Logo" className="h-12 w-auto object-contain mx-auto" />
          </Link>
          <h1 className="font-grotesk text-3xl font-bold tracking-tight text-white mb-2">
            Request Access
          </h1>
          <p className="text-vanta-ink-muted text-sm font-mono uppercase tracking-wider">
            Join the elite club of Falcon View
          </p>
        </div>

        {/* Register Card */}
        <div className="bg-vanta-panel border border-vanta-border rounded-2xl p-8 shadow-2xl relative overflow-hidden backdrop-blur-xl">
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
            
            {/* Grid of First/Last Name */}
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="block text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">
                  First Name
                </label>
                <div className="relative">
                  <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle">
                    <User size={14} />
                  </span>
                  <input
                    type="text"
                    placeholder="John"
                    {...register('firstName')}
                    className={`w-full bg-vanta-paper-soft border ${
                      errors.firstName ? 'border-red-500/50 focus:border-red-500' : 'border-vanta-border focus:border-vanta-amber'
                    } rounded-xl py-2.5 pl-9 pr-3 text-sm text-white placeholder-vanta-ink-subtle focus:outline-none transition-all`}
                  />
                </div>
                {errors.firstName && (
                  <p className="text-[10px] text-red-400 font-mono mt-0.5">{errors.firstName.message}</p>
                )}
              </div>

              <div className="space-y-1.5">
                <label className="block text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">
                  Last Name
                </label>
                <div className="relative">
                  <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle">
                    <User size={14} />
                  </span>
                  <input
                    type="text"
                    placeholder="Doe"
                    {...register('lastName')}
                    className={`w-full bg-vanta-paper-soft border ${
                      errors.lastName ? 'border-red-500/50 focus:border-red-500' : 'border-vanta-border focus:border-vanta-amber'
                    } rounded-xl py-2.5 pl-9 pr-3 text-sm text-white placeholder-vanta-ink-subtle focus:outline-none transition-all`}
                  />
                </div>
                {errors.lastName && (
                  <p className="text-[10px] text-red-400 font-mono mt-0.5">{errors.lastName.message}</p>
                )}
              </div>
            </div>

            {/* Email Field */}
            <div className="space-y-1.5">
              <label className="block text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">
                Email Address
              </label>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle">
                  <Mail size={14} />
                </span>
                <input
                  type="email"
                  placeholder="john@example.com"
                  {...register('email')}
                  className={`w-full bg-vanta-paper-soft border ${
                    errors.email ? 'border-red-500/50 focus:border-red-500' : 'border-vanta-border focus:border-vanta-amber'
                  } rounded-xl py-2.5 pl-9 pr-3 text-sm text-white placeholder-vanta-ink-subtle focus:outline-none transition-all`}
                />
              </div>
              {errors.email && (
                <p className="text-[10px] text-red-400 font-mono mt-0.5">{errors.email.message}</p>
              )}
            </div>

            {/* Grid of Phone/Country */}
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="block text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">
                  Phone Number
                </label>
                <div className="relative">
                  <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle">
                    <Phone size={14} />
                  </span>
                  <input
                    type="tel"
                    placeholder="+971 50..."
                    {...register('phone')}
                    className={`w-full bg-vanta-paper-soft border ${
                      errors.phone ? 'border-red-500/50 focus:border-red-500' : 'border-vanta-border focus:border-vanta-amber'
                    } rounded-xl py-2.5 pl-9 pr-3 text-sm text-white placeholder-vanta-ink-subtle focus:outline-none transition-all`}
                  />
                </div>
                {errors.phone && (
                  <p className="text-[10px] text-red-400 font-mono mt-0.5">{errors.phone.message}</p>
                )}
              </div>

              <div className="space-y-1.5">
                <label className="block text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">
                  Country
                </label>
                <div className="relative">
                  <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle">
                    <Globe size={14} />
                  </span>
                  <input
                    type="text"
                    placeholder="United Arab Emirates"
                    {...register('country')}
                    className={`w-full bg-vanta-paper-soft border ${
                      errors.country ? 'border-red-500/50 focus:border-red-500' : 'border-vanta-border focus:border-vanta-amber'
                    } rounded-xl py-2.5 pl-9 pr-3 text-sm text-white placeholder-vanta-ink-subtle focus:outline-none transition-all`}
                  />
                </div>
                {errors.country && (
                  <p className="text-[10px] text-red-400 font-mono mt-0.5">{errors.country.message}</p>
                )}
              </div>
            </div>

            {/* Grid of Passwords */}
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="block text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">
                  Password
                </label>
                <div className="relative">
                  <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle">
                    <Lock size={14} />
                  </span>
                  <input
                    type={showPassword ? 'text' : 'password'}
                    placeholder="••••••••"
                    {...register('password')}
                    className={`w-full bg-vanta-paper-soft border ${
                      errors.password ? 'border-red-500/50 focus:border-red-500' : 'border-vanta-border focus:border-vanta-amber'
                    } rounded-xl py-2.5 pl-9 pr-3 text-sm text-white placeholder-vanta-ink-subtle focus:outline-none transition-all`}
                  />
                </div>
                {errors.password && (
                  <p className="text-[10px] text-red-400 font-mono mt-0.5">{errors.password.message}</p>
                )}
              </div>

              <div className="space-y-1.5">
                <label className="block text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">
                  Confirm Password
                </label>
                <div className="relative">
                  <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle">
                    <Lock size={14} />
                  </span>
                  <input
                    type={showPassword ? 'text' : 'password'}
                    placeholder="••••••••"
                    {...register('confirmPassword')}
                    className={`w-full bg-vanta-paper-soft border ${
                      errors.confirmPassword ? 'border-red-500/50 focus:border-red-500' : 'border-vanta-border focus:border-vanta-amber'
                    } rounded-xl py-2.5 pl-9 pr-3 text-sm text-white placeholder-vanta-ink-subtle focus:outline-none transition-all`}
                  />
                </div>
                {errors.confirmPassword && (
                  <p className="text-[10px] text-red-400 font-mono mt-0.5">{errors.confirmPassword.message}</p>
                )}
              </div>
            </div>

            {/* Accept Terms */}
            <div className="space-y-1 pt-1">
              <div className="flex items-start">
                <input
                  id="acceptTerms"
                  type="checkbox"
                  {...register('acceptTerms')}
                  className="h-4 w-4 bg-vanta-paper-soft border border-vanta-border text-vanta-amber rounded focus:ring-vanta-amber focus:ring-offset-vanta-paper transition-all mt-0.5"
                />
                <label htmlFor="acceptTerms" className="ml-2 block text-xs text-vanta-ink-muted leading-relaxed">
                  I consent to the terms of service and premium driver regulations.
                </label>
              </div>
              {errors.acceptTerms && (
                <p className="text-[10px] text-red-400 font-mono">{errors.acceptTerms.message}</p>
              )}
            </div>

            {/* Submit Button */}
            <motion.button
              whileHover={{ scale: 1.01 }}
              whileTap={{ scale: 0.99 }}
              type="submit"
              disabled={loading}
              className="w-full bg-vanta-amber hover:bg-orange-500 text-white font-grotesk font-semibold text-sm py-4.5 rounded-xl transition-all shadow-amber-sm flex items-center justify-center gap-2 mt-4"
            >
              {loading ? (
                <div className="w-5 h-5 rounded-full border-2 border-white/30 border-t-white animate-spin" />
              ) : (
                <>
                  Submit Request <ArrowRight size={16} />
                </>
              )}
            </motion.button>
          </form>

          {/* Social Logins */}
          <div className="mt-6 pt-4 border-t border-vanta-border">
            <span className="block text-center text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-subtle mb-3">
              Or request access with SSO
            </span>
            <div className="w-full flex justify-center overflow-hidden rounded-xl">
              <div id="google-signup-btn" className="w-full flex justify-center"></div>
            </div>
          </div>
        </div>

        {/* Footer Link */}
        <p className="text-center text-xs text-vanta-ink-muted mt-6">
          Already a member?{' '}
          <Link to="/login" className="text-vanta-amber hover:underline font-semibold">
            Sign In Here
          </Link>
        </p>
      </motion.div>
    </div>
    </>
  );
};

export default Register;
