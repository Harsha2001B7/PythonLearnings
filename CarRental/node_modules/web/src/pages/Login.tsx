import React, { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Eye, EyeOff, Lock, Mail, ArrowRight } from 'lucide-react';

import { useAuthStore } from '../store/authStore';
import { useToastStore } from '../store';
import api from '../services/api/axios';
import { ease, duration } from '../lib/easing';
import falconLogo from '../../assets/falconviewLogotrans.png';
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
      const profileResponse = await api.get('/users/me', {
        headers: { Authorization: `Bearer ${access_token}` }
      });

      login(access_token, refresh_token, profileResponse.data);
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
    <div className="min-h-screen bg-vanta-paper text-vanta-ink flex items-center justify-center px-4 relative overflow-hidden">
      {/* Decorative Blur Orbs */}
      <div className="absolute top-1/4 left-1/4 w-96 h-96 rounded-full bg-vanta-amber/5 blur-[120px]" />
      <div className="absolute bottom-1/4 right-1/4 w-96 h-96 rounded-full bg-orange-600/5 blur-[120px]" />

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: duration.slow, ease: ease.elegant }}
        className="w-full max-w-[440px] z-10"
      >
        {/* Logo and Header */}
        <div className="text-center mb-8">
          <Link to="/" className="inline-block mb-4">
            <img src={falconLogo} alt="Falcon View Logo" className="h-12 w-auto object-contain mx-auto" />
          </Link>
          <h1 className="font-grotesk text-3xl font-bold tracking-tight text-white mb-2">
            Welcome Back
          </h1>
          <p className="text-vanta-ink-muted text-sm font-mono uppercase tracking-wider">
            Sign in to your luxury experience
          </p>
        </div>

        {/* Login Card */}
        <div className="bg-vanta-panel border border-vanta-border rounded-2xl p-8 shadow-2xl relative overflow-hidden backdrop-blur-xl">
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
                  className={`w-full bg-vanta-paper-soft border ${
                    errors.email ? 'border-red-500/50 focus:border-red-500' : 'border-vanta-border focus:border-vanta-amber'
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
                  className="text-[11px] font-mono uppercase tracking-[0.1em] text-vanta-amber hover:text-orange-400 transition-colors"
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
                  className={`w-full bg-vanta-paper-soft border ${
                    errors.password ? 'border-red-500/50 focus:border-red-500' : 'border-vanta-border focus:border-vanta-amber'
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
                className="h-4 w-4 bg-vanta-paper-soft border border-vanta-border text-vanta-amber rounded focus:ring-vanta-amber focus:ring-offset-vanta-paper transition-all"
              />
              <label htmlFor="rememberMe" className="ml-2 block text-xs text-vanta-ink-muted">
                Remember my login credentials
              </label>
            </div>

            {/* Submit Button */}
            <motion.button
              whileHover={{ scale: 1.01 }}
              whileTap={{ scale: 0.99 }}
              type="submit"
              disabled={loading}
              className="w-full bg-vanta-amber hover:bg-orange-500 text-white font-grotesk font-semibold text-sm py-4 rounded-xl transition-all shadow-amber-sm flex items-center justify-center gap-2"
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

          {/* Social Logins - Disabled */}
          <div className="mt-8 pt-6 border-t border-vanta-border">
            <span className="block text-center text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-subtle mb-4">
              Secure single sign-on (SSO)
            </span>
            <div className="grid grid-cols-2 gap-3">
              <button
                disabled
                className="flex items-center justify-center gap-2 border border-vanta-border bg-vanta-paper-soft py-2.5 rounded-lg text-xs font-mono text-vanta-ink-subtle opacity-50 cursor-not-allowed"
              >
                Google
              </button>
              <button
                disabled
                className="flex items-center justify-center gap-2 border border-vanta-border bg-vanta-paper-soft py-2.5 rounded-lg text-xs font-mono text-vanta-ink-subtle opacity-50 cursor-not-allowed"
              >
                Apple
              </button>
            </div>
          </div>
        </div>

        {/* Footer Link */}
        <p className="text-center text-xs text-vanta-ink-muted mt-6">
          New to Falcon View?{' '}
          <Link to="/register" className="text-vanta-amber hover:underline font-semibold">
            Request an Invitation
          </Link>
        </p>
      </motion.div>
    </div>
    </>
  );
};

export default Login;
