// ─────────────────────────────────────────────────────────────────
// Falcon View Car Rentals — Animation Easing Constants
// Shared between Motion and GSAP for consistent brand motion feel.
// Named after the quality of motion they produce.
// ─────────────────────────────────────────────────────────────────

// Motion-compatible cubic-bezier arrays [x1, y1, x2, y2]
export const ease = {
  /** Refined deceleration — main transition easing */
  elegant: [0.25, 0.46, 0.45, 0.94] as [number, number, number, number],
  /** Hard snap — menus, drawers snapping open */
  snap: [0.77, 0, 0.175, 1] as [number, number, number, number],
  /** Material — Google-style motion */
  float: [0.4, 0, 0.2, 1] as [number, number, number, number],
  /** Spring with slight overshoot — buttons, cards on hover */
  spring: [0.34, 1.56, 0.64, 1] as [number, number, number, number],
  /** Pure ease-out cubic */
  out: [0.33, 1, 0.68, 1] as [number, number, number, number],
  /** Pure ease-in cubic */
  in: [0.32, 0, 0.67, 0] as [number, number, number, number],
} as const;

// GSAP-compatible string format (for use in gsap tweens)
export const gsapEase = {
  elegant: 'power2.out',
  snap: 'power4.inOut',
  float: 'power2.inOut',
  spring: 'back.out(1.4)',
  out: 'power2.out',
  in: 'power2.in',
} as const;

// Motion spring configs (for motion's spring transition type)
export const spring = {
  /** Snappy interactive response */
  responsive: { type: 'spring', stiffness: 380, damping: 30 } as const,
  /** Gentle float */
  soft: { type: 'spring', stiffness: 200, damping: 25 } as const,
  /** Tight snap */
  tight: { type: 'spring', stiffness: 500, damping: 35 } as const,
  /** Gentle entrance */
  enter: { type: 'spring', stiffness: 280, damping: 24 } as const,
} as const;

// Standard durations in seconds (for consistency)
export const duration = {
  instant: 0.1,
  fast: 0.2,
  normal: 0.35,
  slow: 0.55,
  cinematic: 0.9,
} as const;
