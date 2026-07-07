// ─────────────────────────────────────────────────────────────────
// useCountUp — animated number counter, triggers on intersection
// Respects prefers-reduced-motion (shows final value immediately)
// ─────────────────────────────────────────────────────────────────
import { useEffect, useRef, useState } from 'react';

interface UseCountUpOptions {
  target: number;
  duration?: number;   // ms
  decimals?: number;
  prefix?: string;
  suffix?: string;
  easing?: (t: number) => number;
}

export function useCountUp({
  target,
  duration = 1800,
  decimals = 0,
  prefix = '',
  suffix = '',
  easing = (t) => 1 - Math.pow(1 - t, 3), // ease-out-cubic
}: UseCountUpOptions): { ref: React.RefObject<HTMLSpanElement>; display: string } {
  const ref = useRef<HTMLSpanElement>(null);
  const [current, setCurrent] = useState(0);
  const animationRef = useRef<number | null>(null);
  const startTimeRef = useRef<number | null>(null);

  const prefersReducedMotion =
    typeof window !== 'undefined'
      ? window.matchMedia('(prefers-reduced-motion: reduce)').matches
      : false;

  useEffect(() => {
    const element = ref.current;
    if (!element) return;

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (!entry.isIntersecting) return;
        observer.disconnect();

        if (prefersReducedMotion) {
          setCurrent(target);
          return;
        }

        startTimeRef.current = null;

        const animate = (timestamp: number) => {
          if (!startTimeRef.current) startTimeRef.current = timestamp;
          const elapsed = timestamp - startTimeRef.current;
          const progress = Math.min(elapsed / duration, 1);
          const easedProgress = easing(progress);
          setCurrent(easedProgress * target);
          if (progress < 1) {
            animationRef.current = requestAnimationFrame(animate);
          }
        };

        animationRef.current = requestAnimationFrame(animate);
      },
      { threshold: 0.3 }
    );

    observer.observe(element);
    return () => {
      observer.disconnect();
      if (animationRef.current) cancelAnimationFrame(animationRef.current);
    };
  }, [target, duration, prefersReducedMotion]);

  const display = `${prefix}${current.toFixed(decimals)}${suffix}`;
  return { ref: ref as React.RefObject<HTMLSpanElement>, display };
}
