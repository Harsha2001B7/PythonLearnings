import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { CheckCircle, AlertCircle, Info, X } from 'lucide-react';
import { useToastStore } from '../store';
import { ease } from '../lib/easing';
import { cn } from '../lib/cn';

const ICON_MAP = {
  success: <CheckCircle size={16} className="text-vanta-success" />,
  error:   <AlertCircle size={16} className="text-vanta-danger" />,
  info:    <Info size={16} className="text-vanta-amber" />,
};

export const ToastContainer: React.FC = () => {
  const { toasts, removeToast } = useToastStore();

  return (
    <div
      className="fixed bottom-8 left-6 z-[960] flex flex-col-reverse gap-3 pointer-events-none"
      role="region"
      aria-label="Notifications"
      aria-live="polite"
    >
      <AnimatePresence>
        {toasts.map((toast) => (
          <motion.div
            key={toast.id}
            layout
            initial={{ opacity: 0, y: 16, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, x: -20, scale: 0.95 }}
            transition={{ duration: 0.35, ease: ease.spring }}
            className="pointer-events-auto flex items-center gap-3 bg-vanta-panel border border-vanta-border px-4 py-3.5 rounded-xl shadow-card-lg min-w-[260px] max-w-[340px]"
            role="alert"
          >
            {ICON_MAP[toast.type ?? 'success']}
            <p className="text-[13px] font-grotesk text-vanta-ink font-medium flex-1">{toast.message}</p>
            <button
              onClick={() => removeToast(toast.id)}
              className="text-vanta-ink-subtle hover:text-vanta-ink transition-colors ml-1"
              aria-label="Dismiss notification"
            >
              <X size={13} />
            </button>
          </motion.div>
        ))}
      </AnimatePresence>
    </div>
  );
};
