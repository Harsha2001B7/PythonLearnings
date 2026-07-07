// ─────────────────────────────────────────────────────────────────
// cn — class name utility
// Combines clsx + tailwind-merge for conditional, merged classes
// ─────────────────────────────────────────────────────────────────
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]): string {
  return twMerge(clsx(inputs));
}
