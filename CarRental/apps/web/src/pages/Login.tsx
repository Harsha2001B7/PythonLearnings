import React, { useState, useEffect, useRef } from 'react';
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

// ─── Shared Google credential handler (used by both rendered button & fallback) ──
async function handleGoogleCredential(
  credential: string,
  options: {
    setLoading: (v: boolean) => void;
    addToast: (msg: string, type?: 'success' | 'error' | 'info') => void;
    login: (at: string, rt: string, user: any, remember: boolean) => void;
    navigate: (path: string, opts?: any) => void;
    from: string;
  }
) {
  options.setLoading(true);
  try {
    const res = await api.post('/auth/google', { id_token: credential });
    const { access_token, refresh_token } = res.data;
    const profileResponse = await api.get('/auth/me', {
      headers: { Authorization: `Bearer ${access_token}` },
    });
    options.login(access_token, refresh_token, profileResponse.data, true);
    options.addToast(`Welcome back, ${profileResponse.data.first_name || 'User'}!`, 'success');
    if (profileResponse.data.role_id === 1) {
      options.navigate('/admin');
    } else {
      options.navigate(options.from, { replace: true });
    }
  } catch (err: any) {
    options.addToast(err.response?.data?.detail || 'Google Sign-In failed', 'error');
  } finally {
    options.setLoading(false);
  }
}

const Login: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { login } = useAuthStore();
  const { addToast } = useToastStore();
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [googleReady, setGoogleReady] = useState(false);
  const googleBtnRef = useRef<HTMLDivElement>(null);

  const from = (location.state as any)?.from?.pathname || '/';

  useEffect(() => {
    // Guard: only attach the GSI script once per page lifetime
    const SCRIPT_ID = 'gsi-client-script';
    let scriptEl = document.getElementById(SCRIPT_ID) as HTMLScriptElement | null;

    const initGSI = () => {
      const g = (window as any).google;
      if (!g || !googleBtnRef.current) return;

      g.accounts.id.initialize({
        client_id: GOOGLE_CLIENT_ID,
        callback: (response: any) =>
          handleGoogleCredential(response.credential, {
            setLoading,
            addToast,
            login,
            navigate,
            from,
          }),
        use_fedcm_for_prompt: false,
      });

      // Render the button — use the container's actual pixel width so it never clips
      const containerWidth = googleBtnRef.current.offsetWidth || 320;
      g.accounts.id.renderButton(googleBtnRef.current, {
        theme: 'filled_black',       // Matches the dark card perfectly — no invisible overlay needed
        size: 'large',
        width: Math.min(containerWidth, 400),
        text: 'continue_with',
        logo_alignment: 'center',
        shape: 'rectangular',
      });

      setGoogleReady(true);
    };

    if (scriptEl) {
      // Script already exists — GSI may already be loaded
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

    // Cleanup: only remove the listener, NOT the script (so it works on back-navigation)
    return () => {
      scriptEl?.removeEventListener('load', initGSI);
    };
  }, [navigate, login, addToast, from]);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginSchemaType>({
    resolver: zodResolver(loginSchema),
    defaultValues: { rememberMe: false },
  });

  const onSubmit = async (data: LoginSchemaType) => {
    setLoading(true);
    try {
      const response = await api.post('/auth/login', {
        email: data.email,
        password: data.password,
      });
      const { access_token, refresh_token } = response.data;
      const profileResponse = await api.get('/auth/me', {
        headers: { Authorization: `Bearer ${access_token}` },
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

  // Fallback: trigger One-Tap prompt when user taps the visual area if GSI button didn't render
  const handleGoogleFallback = () => {
    const g = (window as any).google;
    if (g && !googleReady) {
      g.accounts.id.prompt();
    }
  };

  return (
    <>
      <SEO title="Login | Falcon View Car Rentals" canonicalUrl="/login" />
      <div className="min-h-screen bg-vanta-paper text-vanta-ink flex flex-col md:flex-row relative overflow-hidden">
        {/* Decorative Blur Orbs */}
        <div className="absolute top-1/4 left-1/4 w-96 h-96 rounded-full bg-vanta-amber/5 blur-[120px] pointer-events-none" />
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 rounded-full bg-orange-600/5 blur-[120px] pointer-events-none" />

        {/* LEFT SIDE: Branding — hidden on mobile, shown md+ */}
        <div className="hidden md:flex w-full md:w-1/2 flex-col justify-center items-start px-12 lg:px-24 py-12 z-10">
          <Link to="/" className="inline-block mb-8">
            <img src={falconLogo} alt="Falcon View Logo" className="h-20 w-auto object-contain" />
          </Link>
          <h1 className="font-sans text-5xl lg:text-6xl font-extrabold tracking-tight text-white mb-4">
            Welcome Back
          </h1>
          <p className="text-vanta-ink-subtle text-[10px] font-mono uppercase tracking-[0.25em] leading-relaxed">
            Sign in to your luxury experience
          </p>
        </div>

        {/* RIGHT SIDE: Login Form */}
        <div className="w-full md:w-1/2 flex items-center justify-center px-4 sm:px-8 md:px-12 lg:px-20 py-12 pb-32 md:pb-8 z-10 relative min-h-screen md:min-h-0">
          {/* Subtle Background Glow */}
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[450px] h-[450px] rounded-full bg-gradient-to-r from-vanta-amber/10 to-orange-600/5 blur-[100px] pointer-events-none" />

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: duration.slow, ease: ease.elegant }}
            className="w-full max-w-[440px] z-10"
          >
            {/* Mobile-only logo */}
            <div className="flex flex-col items-center mb-6 md:hidden">
              <Link to="/">
                <img src={falconLogo} alt="Falcon View Logo" className="h-16 w-auto object-contain" />
              </Link>
              <h1 className="font-sans text-3xl font-extrabold tracking-tight text-white mt-4 text-center">
                Welcome Back
              </h1>
            </div>

            {/* Glassmorphic Form Card */}
            <div
              className="rounded-2xl px-5 sm:px-8 py-8 shadow-2xl relative overflow-hidden"
              style={{
                background: 'rgba(25, 25, 25, 0.65)',
                backdropFilter: 'blur(12px)',
                WebkitBackdropFilter: 'blur(12px)',
                border: '1px solid rgba(255, 255, 255, 0.07)',
              }}
            >
              <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">

                {/* Email Field */}
                <div className="space-y-2">
                  <label className="block text-[11px] font-mono uppercase tracking-[0.15em] text-vanta-ink-muted">
                    Email Address
                  </label>
                  <div className="relative">
                    <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle pointer-events-none">
                      <Mail size={16} />
                    </span>
                    <input
                      type="email"
                      placeholder="you@example.com"
                      {...register('email')}
                      className={`w-full bg-white/[0.03] border ${
                        errors.email ? 'border-red-500/50 focus:border-red-500' : 'border-white/[0.08] focus:border-vanta-amber'
                      } rounded-xl py-3.5 pl-10 pr-4 text-sm text-white placeholder-vanta-ink-subtle focus:outline-none transition-all`}
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
                    <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-vanta-ink-subtle pointer-events-none">
                      <Lock size={16} />
                    </span>
                    <input
                      type={showPassword ? 'text' : 'password'}
                      placeholder="••••••••"
                      {...register('password')}
                      className={`w-full bg-white/[0.03] border ${
                        errors.password ? 'border-red-500/50 focus:border-red-500' : 'border-white/[0.08] focus:border-vanta-amber'
                      } rounded-xl py-3.5 pl-10 pr-10 text-sm text-white placeholder-vanta-ink-subtle focus:outline-none transition-all`}
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute inset-y-0 right-0 pr-3 flex items-center text-vanta-ink-subtle hover:text-white transition-colors"
                      aria-label={showPassword ? 'Hide password' : 'Show password'}
                    >
                      {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                    </button>
                  </div>
                  {errors.password && (
                    <p className="text-xs text-red-400 font-mono mt-1">{errors.password.message}</p>
                  )}
                </div>

                {/* Remember Me */}
                <div className="flex items-center gap-2">
                  <input
                    id="rememberMe"
                    type="checkbox"
                    {...register('rememberMe')}
                    className="h-4 w-4 bg-vanta-paper-soft border border-white/[0.08] text-vanta-amber rounded focus:ring-vanta-amber focus:ring-offset-vanta-paper transition-all checked:bg-vanta-amber checked:border-vanta-amber"
                  />
                  <label htmlFor="rememberMe" className="text-xs text-white/80 cursor-pointer">
                    Remember my login credentials
                  </label>
                </div>

                {/* Submit Button */}
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  type="submit"
                  disabled={loading}
                  className="w-full bg-gradient-to-r from-vanta-amber to-orange-600 hover:from-orange-500 hover:to-vanta-amber text-white font-grotesk font-bold text-sm py-4 rounded-xl shadow-lg shadow-orange-500/10 flex items-center justify-center gap-2 transition-all duration-300 disabled:opacity-60 disabled:cursor-not-allowed"
                >
                  {loading ? (
                    <div className="w-5 h-5 rounded-full border-2 border-white/30 border-t-white animate-spin" />
                  ) : (
                    <>Enter Vault <ArrowRight size={16} /></>
                  )}
                </motion.button>
              </form>

              {/* Google Sign-In */}
              <div className="mt-6 pt-5 border-t border-white/[0.08]">
                <span className="block text-center text-[10px] font-mono uppercase tracking-[0.15em] text-vanta-ink-subtle mb-4">
                  Secure single sign-on (SSO)
                </span>

                {/*
                  SVG provides the branded visual face.
                  The real GSI button sits on top at opacity-[0.001] —
                  nearly invisible but still receives pointer/touch events
                  (opacity-0 blocks touch on iOS Safari; 0.001 does not).
                */}
                <div className="w-full relative flex justify-center overflow-hidden rounded-xl h-11">
                  {/* Branded SVG — visible background layer */}
                  <div className="absolute inset-0 flex justify-center items-center pointer-events-none">
                    <img
                      src={googleSvg}
                      className="w-[200px] h-11 object-contain"
                      alt="Sign in with Google"
                    />
                  </div>
                  {/* Real GSI button — nearly transparent but fully interactive */}
                  <div
                    ref={googleBtnRef}
                    id="google-signin-btn"
                    className="absolute inset-0 flex justify-center"
                    style={{ opacity: 0.001 }}
                    onClick={handleGoogleFallback}
                    aria-label="Continue with Google"
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
