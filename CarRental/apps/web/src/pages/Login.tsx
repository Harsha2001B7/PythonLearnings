import React, { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Eye, EyeOff, Lock, Mail, ArrowRight } from 'lucide-react';

import { useAuthStore } from '../store/authStore';
import { useToastStore } from '../store';
import api from '../services/api/axios';
import { GOOGLE_CLIENT_ID } from '../config/oauth';
import { ease, duration } from '../lib/easing';
import falconLogo from '../../assets/falconviewLogotrans.png';
import googleSvg from '../../assets/signinwithgoogle.svg';
import SEO from '../components/seo/SEO';

const loginSchema = z.object({
  email: z.string().email('Please enter a valid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  rememberMe: z.boolean().optional(),
});

type LoginSchemaType = z.infer<typeof loginSchema>;

const Login: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { login } = useAuthStore();
  const { addToast } = useToastStore();
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);

  const from = (location.state as any)?.from?.pathname || '/';

  useEffect(() => {
    const script = document.createElement('script');
    script.src = 'https://accounts.google.com/gsi/client';
    script.async = true;
    script.defer = true;
    script.onload = () => {
      const g = (window as any).google;
      if (g) {
        g.accounts.id.initialize({
          client_id: GOOGLE_CLIENT_ID,
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
              addToast(`Welcome back, ${profileResponse.data.first_name || 'User'}!`, 'success');
              if (profileResponse.data.role_id === 1) {
                navigate('/admin');
              } else {
                navigate(from, { replace: true });
              }
            } catch (err: any) {
              addToast(err.response?.data?.detail || 'Google Sign-In failed', 'error');
            } finally {
              setLoading(false);
            }
          }
        });
        g.accounts.id.renderButton(
          document.getElementById('google-signin-btn'),
          { theme: 'outline', size: 'large', width: 376, text: 'continue_with', logo_alignment: 'left' }
        );
      }
    };
    document.body.appendChild(script);
    return () => {
      document.body.removeChild(script);
    };
  }, [navigate, login, addToast, from]);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginSchemaType>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      rememberMe: false
    }
  });

  const onSubmit = async (data: LoginSchemaType) => {
    setLoading(true);
    try {
      const response = await api.post('/auth/login', {
        email: data.email,
        password: data.password,
      });

      const { access_token, refresh_token } = response.data;
      
      // Get current user profile
      const profileResponse = await api.get('/auth/me', {
        headers: { Authorization: `Bearer ${access_token}` }
      });

      login(access_token, refresh_token, profileResponse.data, !!data.rememberMe);
      addToast(`Welcome back, ${profileResponse.data.first_name || 'User'}!`, 'success');
      
      if (profileResponse.data.role_id === 1) {
        navigate('/admin');
      } else {
        navigate(from, { replace: true });
      }
    } catch (error: any) {
      const errMsg = error.response?.data?.detail || 'Invalid email or credentials.';
      addToast(errMsg, 'error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
    <SEO title="Login | Falcon View Car Rentals" canonicalUrl="/login" />
    <div className="min-h-screen bg-vanta-paper text-vanta-ink flex flex-col md:flex-row relative overflow-hidden">
      {/* Decorative Blur Orbs */}
      <div className="absolute top-1/4 left-1/4 w-96 h-96 rounded-full bg-vanta-amber/5 blur-[120px]" />
      <div className="absolute bottom-1/4 right-1/4 w-96 h-96 rounded-full bg-orange-600/5 blur-[120px]" />

      {/* LEFT SIDE: Welcome / Branding */}
      <div className="w-full md:w-1/2 flex flex-col justify-center items-center md:items-start px-8 md:px-16 lg:px-24 py-12 z-10">
        <Link to="/" className="inline-block mb-8">
          <img src={falconLogo} alt="Falcon View Logo" className="h-24 w-auto object-contain mx-auto md:mx-0" />
        </Link>
        <h1 className="font-sans text-4xl md:text-5xl lg:text-6xl font-extrabold tracking-tight text-white mb-4 text-center md:text-left">
          Welcome Back
        </h1>
        <p className="text-vanta-ink-subtle text-[10px] font-mono uppercase tracking-[0.25em] text-center md:text-left leading-relaxed">
          Sign in to your luxury experience
        </p>
      </div>

      {/* RIGHT SIDE: Login Form */}
      <div className="w-full md:w-1/2 flex items-center justify-center px-6 md:px-12 lg:px-20 py-8 z-10 relative">
        {/* Subtle Background Glow behind login box */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[450px] h-[450px] rounded-full bg-gradient-to-r from-vanta-amber/10 to-orange-600/5 blur-[100px] pointer-events-none" />

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: duration.slow, ease: ease.elegant }}
          className="w-full max-w-[440px] z-10"
        >
          {/* Glassmorphic Form Card */}
          <div 
            className="rounded-3xl px-10 py-10 shadow-2xl relative overflow-hidden"
            style={{
              background: 'rgba(25, 25, 25, 0.65)',
              backdropFilter: 'blur(12px)',
              WebkitBackdropFilter: 'blur(12px)',
              border: '1px solid rgba(255, 255, 255, 0.07)'
            }}
          >
            <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
              
              {/* Email Field */}
              <div className="space-y-2">
                <label className="block text-[11px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">
                  Email Address
                </label>
                <div className="relative">
                  <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle">
                    <Mail size={16} />
                  </span>
                  <input
                    type="email"
                    placeholder="name@example.com"
                    {...register('email')}
                    className={`w-full bg-vanta-paper-soft/40 border ${
                      errors.email ? 'border-red-500/50 focus:border-red-500' : 'border-white/[0.08] focus:border-vanta-amber'
                    } rounded-xl py-3 pl-10 pr-4 text-sm text-white placeholder-vanta-ink-subtle focus:outline-none transition-all`}
                  />
                </div>
                {errors.email && (
                  <p className="text-xs text-red-400 font-mono mt-1">{errors.email.message}</p>
                )}
              </div>

              {/* Password Field */}
              <div className="space-y-2">
                <div className="flex justify-between items-center">
                  <label className="block text-[11px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">
                    Password
                  </label>
                  <Link
                    to="/forgot-password"
                    className="text-[11px] font-mono uppercase tracking-[0.1em] text-vanta-amber hover:text-orange-500 transition-colors"
                  >
                    Forgot?
                  </Link>
                </div>
                <div className="relative">
                  <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle">
                    <Lock size={16} />
                  </span>
                  <input
                    type={showPassword ? 'text' : 'password'}
                    placeholder="••••••••"
                    {...register('password')}
                    className={`w-full bg-vanta-paper-soft/40 border ${
                      errors.password ? 'border-red-500/50 focus:border-red-500' : 'border-white/[0.08] focus:border-vanta-amber'
                    } rounded-xl py-3 pl-10 pr-10 text-sm text-white placeholder-vanta-ink-subtle focus:outline-none transition-all`}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute inset-y-0 right-0 pr-3 flex items-center text-vanta-ink-subtle hover:text-white transition-colors"
                  >
                    {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
                {errors.password && (
                  <p className="text-xs text-red-400 font-mono mt-1">{errors.password.message}</p>
                )}
              </div>

              {/* Remember Me */}
              <div className="flex items-center">
                <input
                  id="rememberMe"
                  type="checkbox"
                  {...register('rememberMe')}
                  className="h-4 w-4 bg-vanta-paper-soft border border-white/[0.08] text-vanta-amber rounded focus:ring-vanta-amber focus:ring-offset-vanta-paper transition-all checked:bg-vanta-amber checked:border-vanta-amber"
                />
                <label htmlFor="rememberMe" className="ml-2 block text-xs text-white/80">
                  Remember my login credentials
                </label>
              </div>

              {/* Submit Button */}
              <motion.button
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                type="submit"
                disabled={loading}
                className="w-full bg-gradient-to-r from-vanta-amber to-orange-600 hover:from-orange-500 hover:to-vanta-amber text-white font-grotesk font-bold text-sm py-4 rounded-xl shadow-lg shadow-orange-500/10 flex items-center justify-center gap-2 transition-all duration-300 transform"
              >
                {loading ? (
                  <div className="w-5 h-5 rounded-full border-2 border-white/30 border-t-white animate-spin" />
                ) : (
                  <>
                    Enter Vault <ArrowRight size={16} />
                  </>
                )}
              </motion.button>
            </form>

            {/* Social Logins */}
            <div className="mt-8 pt-6 border-t border-white/[0.08]">
              <span className="block text-center text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-subtle mb-4">
                Secure single sign-on (SSO)
              </span>
              <div className="w-full flex justify-center overflow-hidden rounded-xl relative h-10">
                {/* Custom SVG underneath */}
                <div className="absolute inset-0 flex justify-center items-center pointer-events-none">
                  <img src={googleSvg} className="w-[180px] h-10 object-contain" alt="Sign in with Google" />
                </div>
                {/* Transparent Google GSI Button on top */}
                <div 
                  id="google-signin-btn" 
                  className="absolute inset-0 opacity-0 pointer-events-auto flex justify-center"
                />
              </div>
            </div>
          </div>

          {/* Footer Link */}
          <p className="text-center text-xs text-vanta-ink-muted mt-6">
            New to Falcon View?{' '}
            <Link to="/register" className="text-vanta-amber hover:text-orange-500 hover:underline font-semibold">
              Request an Invitation
            </Link>
          </p>
        </motion.div>
      </div>
    </div>
    </>
  );
};

export default Login;
