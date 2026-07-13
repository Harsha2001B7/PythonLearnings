export const API_BASE_URL =
  import.meta.env.VITE_API_URL ??
  "https://falconviewcarrental.onrender.com/api/v1";

export const GOOGLE_CLIENT_ID =
  import.meta.env.VITE_GOOGLE_CLIENT_ID ??
  "291772363929-25to6jat1j1puo3kmghrlf3aue5b3qvh.apps.googleusercontent.com";

export const FRONTEND_URL =
  import.meta.env.VITE_FRONTEND_URL ??
  window.location.origin;

export const OAUTH_CALLBACK_URL = `${FRONTEND_URL}/login`;

export const WHATSAPP_PHONE =
  import.meta.env.VITE_WHATSAPP_PHONE ?? "971500999733";

export const CONTACT_PHONE =
  import.meta.env.VITE_CONTACT_PHONE ?? "+971 50 099 9733";
