import React, { useState, useEffect, useRef } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { useNavigate, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Eye, EyeOff, User, Lock, Mail, Phone, Globe, ArrowRight } from 'lucide-react';

import { useToastStore } from '../store';
import { useAuthStore } from '../store/authStore';
import api from '../services/api/axios';
import { GOOGLE_CLIENT_ID } from '../config/oauth';
import { ease, duration } from '../lib/easing';
import falconLogo from '../../assets/falconviewLogotrans.png';
import googleSvg from '../../assets/signinwithgoogle.svg';
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
  const [googleReady, setGoogleReady] = useState(false);
  const { login } = useAuthStore();
  const googleBtnRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const SCRIPT_ID = 'gsi-client-script';
    let scriptEl = document.getElementById(SCRIPT_ID) as HTMLScriptElement | null;

    const initGSI = () => {
      const g = (window as any).google;
      if (!g || !googleBtnRef.current) return;

      g.accounts.id.initialize({
        client_id: GOOGLE_CLIENT_ID,
        callback: async (response: any) => {
          setLoading(true);
          try {
            const res = await api.post('/auth/google', { id_token: response.credential });
            const { access_token, refresh_token } = res.data;
            const profileResponse = await api.get('/auth/me', {
              headers: { Authorization: `Bearer ${access_token}` },
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
        },
        use_fedcm_for_prompt: false,
      });

      const containerWidth = googleBtnRef.current.offsetWidth || 300;
      g.accounts.id.renderButton(googleBtnRef.current, {
        theme: 'filled_black',
        size: 'large',
        width: Math.min(containerWidth, 400),
        text: 'continue_with',
        logo_alignment: 'center',
        shape: 'rectangular',
      });
      setGoogleReady(true);
    };

    if (scriptEl) {
      if ((window as any).google) {
        initGSI();
      } else {
        scriptEl.addEventListener('load', initGSI);
      }
    } else {
      scriptEl = document.createElement('script');
      scriptEl.id = SCRIPT_ID;
      scriptEl.src = 'https://accounts.google.com/gsi/client';
      scriptEl.async = true;
      scriptEl.defer = true;
      scriptEl.onload = initGSI;
      document.head.appendChild(scriptEl);
    }

    return () => {
      scriptEl?.removeEventListener('load', initGSI);
    };
  }, [navigate, login, addToast]);

  const handleGoogleFallback = () => {
    const g = (window as any).google;
    if (g && !googleReady) g.accounts.id.prompt();
  };

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
      <div className="min-h-screen bg-vanta-paper text-vanta-ink flex flex-col md:flex-row relative overflow-hidden">
        {/* Decorative Blur Orbs */}
        <div className="absolute top-1/4 left-1/4 w-96 h-96 rounded-full bg-vanta-amber/5 blur-[120px] pointer-events-none" />
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 rounded-full bg-orange-600/5 blur-[120px] pointer-events-none" />

        {/* LEFT SIDE: Branding — hidden on mobile */}
        <div className="hidden md:flex w-full md:w-1/2 flex-col justify-center items-start px-12 lg:px-24 py-12 z-10">
          <Link to="/" className="inline-block mb-6">
            <img src={falconLogo} alt="Falcon View Logo" className="h-20 w-auto object-contain" />
          </Link>
          <h1 className="font-sans text-5xl lg:text-6xl font-extrabold tracking-tight text-white mb-4">
            Request Access
          </h1>
          <p className="text-vanta-ink-subtle text-[10px] font-mono uppercase tracking-[0.25em] leading-relaxed">
            Join the elite club of Falcon View
          </p>
        </div>

        {/* RIGHT SIDE: Register Form */}
        <div className="w-full md:w-1/2 flex items-start md:items-center justify-center px-4 sm:px-6 md:px-12 lg:px-20 py-8 z-10 relative">
          {/* Subtle Background Glow */}
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[550px] h-[550px] rounded-full bg-gradient-to-r from-vanta-amber/10 to-orange-600/5 blur-[100px] pointer-events-none" />

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: duration.slow, ease: ease.elegant }}
            className="w-full max-w-[500px] z-10"
          >
            {/* Mobile-only logo */}
            <div className="flex flex-col items-center mb-6 md:hidden pt-8">
              <Link to="/">
                <img src={falconLogo} alt="Falcon View Logo" className="h-14 w-auto object-contain" />
              </Link>
              <h1 className="font-sans text-2xl font-extrabold tracking-tight text-white mt-3 text-center">
                Request Access
              </h1>
            </div>

            {/* Glassmorphic Form Card */}
            <div
              className="rounded-2xl px-5 sm:px-8 py-6 shadow-2xl relative overflow-hidden"
              style={{
                background: 'rgba(25, 25, 25, 0.65)',
                backdropFilter: 'blur(12px)',
                WebkitBackdropFilter: 'blur(12px)',
                border: '1px solid rgba(255, 255, 255, 0.07)',
              }}
            >
              <form onSubmit={handleSubmit(onSubmit)} className="space-y-3.5">

                {/* Grid of First/Last Name */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div className="space-y-1.5">
                    <label className="block text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">
                      First Name
                    </label>
                    <div className="relative">
                      <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle pointer-events-none">
                        <User size={14} />
                      </span>
                      <input
                        type="text"
                        placeholder="John"
                        autoComplete="given-name"
                        {...register('firstName')}
                        className={`w-full bg-vanta-paper-soft/40 border ${
                          errors.firstName ? 'border-red-500/50 focus:border-red-500' : 'border-white/[0.08] focus:border-vanta-amber'
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
                      <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle pointer-events-none">
                        <User size={14} />
                      </span>
                      <input
                        type="text"
                        placeholder="Doe"
                        autoComplete="family-name"
                        {...register('lastName')}
                        className={`w-full bg-vanta-paper-soft/40 border ${
                          errors.lastName ? 'border-red-500/50 focus:border-red-500' : 'border-white/[0.08] focus:border-vanta-amber'
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
                    <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle pointer-events-none">
                      <Mail size={14} />
                    </span>
                    <input
                      type="email"
                      placeholder="john@example.com"
                      autoComplete="email"
                      {...register('email')}
                      className={`w-full bg-vanta-paper-soft/40 border ${
                        errors.email ? 'border-red-500/50 focus:border-red-500' : 'border-white/[0.08] focus:border-vanta-amber'
                      } rounded-xl py-2.5 pl-9 pr-3 text-sm text-white placeholder-vanta-ink-subtle focus:outline-none transition-all`}
                    />
                  </div>
                  {errors.email && (
                    <p className="text-[10px] text-red-400 font-mono mt-0.5">{errors.email.message}</p>
                  )}
                </div>

                {/* Grid of Phone/Country */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div className="space-y-1.5">
                    <label className="block text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">
                      Phone Number
                    </label>
                    <div className="relative">
                      <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle pointer-events-none">
                        <Phone size={14} />
                      </span>
                      <input
                        type="tel"
                        placeholder="+971 50..."
                        autoComplete="tel"
                        {...register('phone')}
                        className={`w-full bg-vanta-paper-soft/40 border ${
                          errors.phone ? 'border-red-500/50 focus:border-red-500' : 'border-white/[0.08] focus:border-vanta-amber'
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
                      <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle pointer-events-none">
                        <Globe size={14} />
                      </span>
                      <input
                        type="text"
                        placeholder="United Arab Emirates"
                        autoComplete="country-name"
                        {...register('country')}
                        className={`w-full bg-vanta-paper-soft/40 border ${
                          errors.country ? 'border-red-500/50 focus:border-red-500' : 'border-white/[0.08] focus:border-vanta-amber'
                        } rounded-xl py-2.5 pl-9 pr-3 text-sm text-white placeholder-vanta-ink-subtle focus:outline-none transition-all`}
                      />
                    </div>
                    {errors.country && (
                      <p className="text-[10px] text-red-400 font-mono mt-0.5">{errors.country.message}</p>
                    )}
                  </div>
                </div>

                {/* Grid of Passwords */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div className="space-y-1.5">
                    <label className="block text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">
                      Password
                    </label>
                    <div className="relative">
                      <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle pointer-events-none">
                        <Lock size={14} />
                      </span>
                      <input
                        type={showPassword ? 'text' : 'password'}
                        placeholder="••••••••"
                        autoComplete="new-password"
                        {...register('password')}
                        className={`w-full bg-vanta-paper-soft/40 border ${
                          errors.password ? 'border-red-500/50 focus:border-red-500' : 'border-white/[0.08] focus:border-vanta-amber'
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
                      <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle pointer-events-none">
                        <Lock size={14} />
                      </span>
                      <input
                        type={showPassword ? 'text' : 'password'}
                        placeholder="••••••••"
                        autoComplete="new-password"
                        {...register('confirmPassword')}
                        className={`w-full bg-vanta-paper-soft/40 border ${
                          errors.confirmPassword ? 'border-red-500/50 focus:border-red-500' : 'border-white/[0.08] focus:border-vanta-amber'
                        } rounded-xl py-2.5 pl-9 pr-3 text-sm text-white placeholder-vanta-ink-subtle focus:outline-none transition-all`}
                      />
                    </div>
                    {errors.confirmPassword && (
                      <p className="text-[10px] text-red-400 font-mono mt-0.5">{errors.confirmPassword.message}</p>
                    )}
                  </div>
                </div>

                {/* Show/hide password toggle */}
                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="flex items-center gap-1.5 text-[10px] font-mono text-vanta-ink-muted hover:text-white transition-colors"
                  >
                    {showPassword ? <EyeOff size={12} /> : <Eye size={12} />}
                    {showPassword ? 'Hide passwords' : 'Show passwords'}
                  </button>
                </div>

                {/* Accept Terms */}
                <div className="space-y-1 pt-1">
                  <div className="flex items-start gap-2">
                    <input
                      id="acceptTerms"
                      type="checkbox"
                      {...register('acceptTerms')}
                      className="h-4 w-4 bg-vanta-paper-soft border border-white/[0.08] text-vanta-amber rounded focus:ring-vanta-amber focus:ring-offset-vanta-paper transition-all mt-0.5 checked:bg-vanta-amber checked:border-vanta-amber shrink-0"
                    />
                    <label htmlFor="acceptTerms" className="text-xs text-white/80 leading-relaxed cursor-pointer">
                      I consent to the terms of service and premium driver regulations.
                    </label>
                  </div>
                  {errors.acceptTerms && (
                    <p className="text-[10px] text-red-400 font-mono">{errors.acceptTerms.message}</p>
                  )}
                </div>

                {/* Submit Button */}
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  type="submit"
                  disabled={loading}
                  className="w-full bg-gradient-to-r from-vanta-amber to-orange-600 hover:from-orange-500 hover:to-vanta-amber text-white font-grotesk font-bold text-sm py-3.5 rounded-xl shadow-lg shadow-orange-500/10 flex items-center justify-center gap-2 mt-2 disabled:opacity-60 disabled:cursor-not-allowed"
                >
                  {loading ? (
                    <div className="w-5 h-5 rounded-full border-2 border-white/30 border-t-white animate-spin" />
                  ) : (
                    <>Submit Request <ArrowRight size={16} /></>
                  )}
                </motion.button>
              </form>

              {/* Google Sign-In */}
              <div className="mt-4 pt-4 border-t border-white/[0.08]">
                <span className="block text-center text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-subtle mb-3">
                  Or request access with SSO
                </span>
                {/*
                  SVG provides the branded visual face.
                  Real GSI button sits on top at opacity 0.001 — invisible
                  but fully interactive (opacity-0 blocks touch on iOS).
                */}
                <div className="w-full relative flex justify-center overflow-hidden rounded-xl h-11">
                  <div className="absolute inset-0 flex justify-center items-center pointer-events-none">
                    <img
                      src={googleSvg}
                      className="w-[200px] h-11 object-contain"
                      alt="Sign in with Google"
                    />
                  </div>
                  <div
                    ref={googleBtnRef}
                    id="google-signup-btn"
                    className="absolute inset-0 flex justify-center"
                    style={{ opacity: 0.001 }}
                    onClick={handleGoogleFallback}
                    aria-label="Continue with Google"
                  />
                </div>
              </div>
            </div>

            {/* Footer Link */}
            <p className="text-center text-xs text-vanta-ink-muted mt-4">
              Already a member?{' '}
              <Link to="/login" className="text-vanta-amber hover:text-orange-500 hover:underline font-semibold">
                Sign In Here
              </Link>
            </p>
          </motion.div>
        </div>
      </div>
    </>
  );
};

export default Register;
