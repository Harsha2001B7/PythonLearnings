/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // ── Semantic Luxury Tokens ──────────────────────────────
        surface: {
          primary: 'var(--vanta-paper)',
          secondary: 'var(--vanta-paper-soft)',
          panel: 'var(--vanta-panel)',
          glass: 'rgba(10, 10, 10, 0.75)',
        },
        text: {
          primary: 'var(--vanta-ink)',
          secondary: 'var(--vanta-ink-muted)',
          subtle: 'var(--vanta-ink-subtle)',
        },
        accent: {
          gold: '#C5A059',
          orange: 'var(--vanta-amber)',
          'orange-glow': 'rgba(255,107,0,0.25)',
        },
        status: {
          success: '#2D7A4F',
          danger: '#C0392B',
        },
        // ── Backwards Compatibility (Vanta & Legacy) ─────────────
        'vanta-paper':      'var(--vanta-paper)',
        'vanta-paper-soft': 'var(--vanta-paper-soft)',
        'vanta-panel':      'var(--vanta-panel)',
        'vanta-border':     'var(--vanta-border)',
        'vanta-ink':        'var(--vanta-ink)',
        'vanta-ink-muted':  'var(--vanta-ink-muted)',
        'vanta-ink-subtle': 'var(--vanta-ink-subtle)',
        'vanta-amber':      'var(--vanta-amber)',
        'vanta-amber-light':'var(--vanta-amber-light)',
        'vanta-amber-pale': 'var(--vanta-amber-pale)',
        background:         '#0D0D0D',
        panel:              '#1A1A1A',
        border:             '#2A2A2A',
      },
      borderColor: {
        DEFAULT: 'var(--vanta-border)',
        subtle: 'rgba(255,255,255,0.08)',
      },
      fontFamily: {
        display:  ['Fraunces', 'Space Grotesk', 'serif'],
        sans:     ['Inter', 'sans-serif'],
        grotesk:  ['Space Grotesk', 'sans-serif'],
        mono:     ['JetBrains Mono', 'monospace'],
      },
      fontSize: {
        'display-2xl': ['clamp(4.5rem, 10vw, 9.5rem)', { lineHeight: '0.9', letterSpacing: '-0.04em' }],
        'display-xl':  ['clamp(3.5rem, 8vw, 7rem)',    { lineHeight: '0.92', letterSpacing: '-0.035em' }],
        'display-lg':  ['clamp(2.5rem, 6vw, 5rem)',    { lineHeight: '0.95', letterSpacing: '-0.03em' }],
        'display-md':  ['clamp(2rem, 4vw, 3.5rem)',    { lineHeight: '1.0', letterSpacing: '-0.02em' }],
        'heading-1':   ['clamp(1.75rem, 3vw, 2.5rem)', { lineHeight: '1.1', letterSpacing: '-0.015em' }],
        'heading-2':   ['clamp(1.5rem, 2.5vw, 2rem)',  { lineHeight: '1.15', letterSpacing: '-0.01em' }],
        'heading-3':   ['1.25rem',                     { lineHeight: '1.2', letterSpacing: '0' }],
        'body-lg':     ['1.125rem',                    { lineHeight: '1.6', letterSpacing: '0' }],
        'body-md':     ['1rem',                        { lineHeight: '1.6', letterSpacing: '0' }],
        'body-sm':     ['0.875rem',                    { lineHeight: '1.5', letterSpacing: '0' }],
        'caption':     ['0.75rem',                     { lineHeight: '1.5', letterSpacing: '0.02em' }],
        'label':       ['0.65rem',                     { lineHeight: '1.4', letterSpacing: '0.05em' }],
      },
      borderRadius: {
        xs:  '4px',
        sm:  '8px',
        md:  '14px',
        lg:  '24px',
        xl:  '36px',
        s:   '10px',
        m:   '16px',
        l:   '28px',
      },
      boxShadow: {
        'card-sm':    '0 1px 3px rgba(0,0,0,0.3), 0 1px 2px rgba(0,0,0,0.2)',
        'card-md':    '0 4px 16px rgba(0,0,0,0.4), 0 1px 4px rgba(0,0,0,0.3)',
        'card-lg':    '0 12px 40px rgba(0,0,0,0.5), 0 4px 12px rgba(0,0,0,0.3)',
        'card-xl':    '0 24px 64px rgba(0,0,0,0.6), 0 8px 24px rgba(0,0,0,0.4)',
        'amber-glow': '0 0 0 1.5px rgba(255,107,0,0.4), 0 8px 32px rgba(255,107,0,0.2)',
        'amber-sm':   '0 0 0 1px rgba(255,107,0,0.3)',
        'glass':      '0 8px 32px rgba(0,0,0,0.5), inset 0 1px 0 rgba(255,255,255,0.05)',
        'orange-glow':'0 0 40px rgba(255,107,0,0.3), 0 0 80px rgba(255,107,0,0.1)',
      },
      spacing: {
        '18': '4.5rem',
        '22': '5.5rem',
        '26': '6.5rem',
        '30': '7.5rem',
        '34': '8.5rem',
        '38': '9.5rem',
        '42': '10.5rem',
        '120': '30rem',
        '128': '32rem',
        '144': '36rem',
        '160': '40rem',
      },
      transitionTimingFunction: {
        'elegant': 'cubic-bezier(0.25, 0.46, 0.45, 0.94)',
        'snap':    'cubic-bezier(0.77, 0, 0.175, 1)',
        'float':   'cubic-bezier(0.4, 0, 0.2, 1)',
        'spring':  'cubic-bezier(0.34, 1.56, 0.64, 1)',
      },
      keyframes: {
        shimmerSweep: {
          '0%':   { transform: 'translateX(-100%) skewX(-15deg)' },
          '100%': { transform: 'translateX(200%) skewX(-15deg)' },
        },
        toastIn: {
          '0%':   { opacity: '0', transform: 'translateY(12px) scale(0.97)' },
          '100%': { opacity: '1', transform: 'translateY(0) scale(1)' },
        },
        loading: {
          '0%':   { transform: 'scaleX(0)', transformOrigin: 'left' },
          '100%': { transform: 'scaleX(1)', transformOrigin: 'left' },
        },
        fadeUp: {
          '0%':   { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        floatY: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%':      { transform: 'translateY(-8px)' },
        },
        pulse: {
          '0%, 100%': { opacity: '1' },
          '50%':      { opacity: '0.5' },
        },
        spin: {
          '0%':   { transform: 'rotate(0deg)' },
          '100%': { transform: 'rotate(360deg)' },
        },
        chatTyping: {
          '0%, 60%, 100%': { opacity: '0.3', transform: 'scale(0.85)' },
          '30%':           { opacity: '1',   transform: 'scale(1)' },
        },
        marquee: {
          '0%':   { transform: 'translateX(0%)' },
          '100%': { transform: 'translateX(-50%)' },
        },
        glowPulse: {
          '0%, 100%': { boxShadow: '0 0 20px rgba(255,107,0,0.3)' },
          '50%':      { boxShadow: '0 0 60px rgba(255,107,0,0.6)' },
        },
      },
      animation: {
        'shimmer-sweep': 'shimmerSweep 0.8s ease forwards',
        'toast-in':      'toastIn 0.4s cubic-bezier(0.34, 1.56, 0.64, 1)',
        'loading':       'loading 1.5s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards',
        'fade-up':       'fadeUp 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94) both',
        'float-y':       'floatY 3s ease-in-out infinite',
        'chat-dot':      'chatTyping 1.4s ease-in-out infinite',
        'spin-slow':     'spin 8s linear infinite',
        'marquee':       'marquee 30s linear infinite',
        'glow-pulse':    'glowPulse 2s ease-in-out infinite',
      },
      backdropBlur: {
        xs: '2px',
      },
    },
  },
  plugins: [],
};
