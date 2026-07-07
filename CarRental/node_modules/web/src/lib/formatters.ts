// ─────────────────────────────────────────────────────────────────
// VANTA Formatters
// ─────────────────────────────────────────────────────────────────

/**
 * Format a price in AED with thousand separators
 * @example formatAED(1540) => "AED 1,540"
 */
export function formatAED(price: number, showDecimal = false): string {
  return `AED ${price.toLocaleString('en-AE', {
    minimumFractionDigits: showDecimal ? 2 : 0,
    maximumFractionDigits: showDecimal ? 2 : 0,
  })}`;
}

/**
 * Format an ISO date string to a readable format
 * @example formatDate("2026-05-12") => "12 May 2026"
 */
export function formatDate(isoDate: string): string {
  return new Date(isoDate).toLocaleDateString('en-AE', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });
}

/**
 * Pluralise a word
 * @example pluralise(1, "vehicle") => "1 vehicle"
 * @example pluralise(3, "vehicle") => "3 vehicles"
 */
export function pluralise(count: number, word: string, plural?: string): string {
  if (count === 1) return `${count} ${word}`;
  return `${count} ${plural ?? word + 's'}`;
}

/**
 * Clamp a number between min and max
 */
export function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}
