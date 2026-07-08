import React, { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { useNavigate, useSearchParams, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Lock, Eye, EyeOff, ArrowRight } from 'lucide-react';

import { useToastStore } from '../store';
import api from '../services/api/axios';
import { ease, duration } from '../lib/easing';
import falconLogo from '../../assets/falconviewLogotrans.png';

const schema = z.object({
  token: z.string().min(1, 'Reset token is required'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords do not match",
  path: ["confirmPassword"],
});

type FormType = z.infer<typeof schema>;

const ResetPassword: React.FC = () => {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const { addToast } = useToastStore();
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);

  const queryToken = searchParams.get('token') || '';

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormType>({
    resolver: zodResolver(schema),
    defaultValues: {
      token: queryToken
    }
  });

  const onSubmit = async (data: FormType) => {
    setLoading(true);
    try {
      await api.post('/auth/reset-password', {
        token: data.token,
        new_password: data.password,
      });

      addToast("Password has been reset successfully. Please log in.", "success");
      navigate('/login');
    } catch (error: any) {
      const errMsg = error.response?.data?.detail || 'Reset failed. Token may be invalid or expired.';
      addToast(errMsg, 'error');
    } finally {
      setLoading(false);
    }
  };

  return (
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
            Establish Password
          </h1>
          <p className="text-vanta-ink-muted text-sm font-mono uppercase tracking-wider">
            Enter your new security passkey
          </p>
        </div>

        {/* Card */}
        <div className="bg-vanta-panel border border-vanta-border rounded-2xl p-8 shadow-2xl relative overflow-hidden backdrop-blur-xl">
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
            
            {/* Token field */}
            <div className="space-y-1.5">
              <label className="block text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">
                Recovery Key / Token
              </label>
              <input
                type="text"
                placeholder="Paste your reset token here"
                {...register('token')}
                className={`w-full bg-vanta-paper-soft border ${
                  errors.token ? 'border-red-500/50 focus:border-red-500' : 'border-vanta-border focus:border-vanta-amber'
                } rounded-xl py-2.5 px-4 text-xs font-mono text-white placeholder-vanta-ink-subtle focus:outline-none transition-all`}
              />
              {errors.token && (
                <p className="text-[10px] text-red-400 font-mono mt-0.5">{errors.token.message}</p>
              )}
            </div>

            {/* New Password */}
            <div className="space-y-1.5">
              <label className="block text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">
                New Password
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

            {/* Confirm Password */}
            <div className="space-y-1.5">
              <label className="block text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">
                Confirm New Password
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
                  } rounded-xl py-2.5 pl-9 pr-10 text-sm text-white placeholder-vanta-ink-subtle focus:outline-none transition-all`}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute inset-y-0 right-0 pr-3 flex items-center text-vanta-ink-subtle hover:text-white transition-colors"
                >
                  {showPassword ? <EyeOff size={14} /> : <Eye size={14} />}
                </button>
              </div>
              {errors.confirmPassword && (
                <p className="text-[10px] text-red-400 font-mono mt-0.5">{errors.confirmPassword.message}</p>
              )}
            </div>

            {/* Submit Button */}
            <motion.button
              whileHover={{ scale: 1.01 }}
              whileTap={{ scale: 0.99 }}
              type="submit"
              disabled={loading}
              className="w-full bg-vanta-amber hover:bg-orange-500 text-white font-grotesk font-semibold text-sm py-4 rounded-xl transition-all shadow-amber-sm flex items-center justify-center gap-2 mt-2"
            >
              {loading ? (
                <div className="w-5 h-5 rounded-full border-2 border-white/30 border-t-white animate-spin" />
              ) : (
                <>
                  Update Security Code <ArrowRight size={16} />
                </>
              )}
            </motion.button>
          </form>
        </div>

        {/* Footer Link */}
        <p className="text-center text-xs text-vanta-ink-muted mt-6">
          Cancel reset?{' '}
          <Link to="/login" className="text-vanta-amber hover:underline font-semibold">
            Return to Login
          </Link>
        </p>
      </motion.div>
    </div>
  );
};

export default ResetPassword;
