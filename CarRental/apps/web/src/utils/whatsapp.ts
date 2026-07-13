import { WHATSAPP_PHONE } from '../config/env';

/**
 * Returns a platform-specific WhatsApp URL.
 * On mobile devices (iOS/Android), if we want to force-open the app,
 * we can construct the deep link, but `https://api.whatsapp.com/send`
 * is the safest universal link that handles redirection to the native app
 * on mobile and falls back to WhatsApp Web/Desktop on non-mobile devices.
 */
export const getWhatsAppUrl = (text: string): string => {
  const cleanPhone = WHATSAPP_PHONE.replace(/[^\d]/g, '');
  const encodedText = encodeURIComponent(text);
  return `https://api.whatsapp.com/send?phone=${cleanPhone}&text=${encodedText}`;
};

/**
 * Opens WhatsApp in a new tab/window in a production-safe way.
 */
export const openWhatsApp = (text: string): void => {
  const url = getWhatsAppUrl(text);
  window.open(url, '_blank', 'noopener,noreferrer');
};
