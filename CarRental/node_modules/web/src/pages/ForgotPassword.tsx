import React, { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { useNavigate, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Mail, ArrowRight, Key } from 'lucide-react';

import { useToastStore } from '../store';
import api from '../services/api/axios';
import { ease, duration } from '../lib/easing';
import falconLogo from '../../assets/falconviewLogotrans.png';

const schema = z.object({
  email: z.string().email('Please enter a valid email address'),
});

type FormType = z.infer<typeof schema>;

const ForgotPassword: React.FC = () => {
  const navigate = useNavigate();
  const { addToast } = useToastStore();
  const [loading, setLoading] = useState(false);
  const [resetToken, setResetToken] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormType>({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: FormType) => {
    setLoading(true);
    try {
      const response = await api.post('/auth/forgot-password', {
        email: data.email,
      });

      addToast("Password recovery link generated.", "success");
      if (response.data.token) {
        setResetToken(response.data.token);
      }
    } catch (error: any) {
      const errMsg = error.response?.data?.detail || 'Something went wrong.';
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
            Recover Credentials
          </h1>
          <p className="text-vanta-ink-muted text-sm font-mono uppercase tracking-wider">
            Reset your security vault key
          </p>
        </div>

        {/* Card */}
        <div className="bg-vanta-panel border border-vanta-border rounded-2xl p-8 shadow-2xl relative overflow-hidden backdrop-blur-xl">
          {!resetToken ? (
            <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
              <div className="space-y-2">
                <label className="block text-[11px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">
                  Account Email
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
                    Send Recovery Code <ArrowRight size={16} />
                  </>
                )}
              </motion.button>
            </form>
          ) : (
            <div className="space-y-6 text-center">
              <div className="w-16 h-16 rounded-full bg-vanta-amber/10 border border-vanta-amber/20 flex items-center justify-center mx-auto text-vanta-amber mb-2">
                <Key size={24} />
              </div>
              <h3 className="font-grotesk font-semibold text-white text-lg">Recovery Token Generated</h3>
              <p className="text-vanta-ink-muted text-xs leading-relaxed">
                A secure password recovery key has been generated for your local instance. Click the button below to proceed to the password reset page with your token.
              </p>
              
              <div className="bg-vanta-paper-soft border border-vanta-border p-3.5 rounded-xl font-mono text-xs text-vanta-amber select-all break-all">
                {resetToken}
              </div>

              <motion.button
                whileHover={{ scale: 1.01 }}
                whileTap={{ scale: 0.99 }}
                onClick={() => navigate(`/reset-password?token=${resetToken}`)}
                className="w-full bg-vanta-amber hover:bg-orange-500 text-white font-grotesk font-semibold text-sm py-4 rounded-xl transition-all shadow-amber-sm flex items-center justify-center gap-2"
              >
                Reset Password <ArrowRight size={16} />
              </motion.button>
            </div>
          )}
        </div>

        {/* Footer Link */}
        <p className="text-center text-xs text-vanta-ink-muted mt-6">
          Remember your password?{' '}
          <Link to="/login" className="text-vanta-amber hover:underline font-semibold">
            Return to Login
          </Link>
        </p>
      </motion.div>
    </div>
  );
};

export default ForgotPassword;
