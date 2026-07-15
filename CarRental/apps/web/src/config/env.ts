// ─────────────────────────────────────────────────────────────────
// Environment configuration
// All values MUST be provided via Vite environment variables.
// No secrets or production values are hardcoded here.
// ─────────────────────────────────────────────────────────────────

export const API_BASE_URL =
  import.meta.env.VITE_API_URL ??
  "http://localhost:8000/api/v1";

// Google OAuth Client ID — provided via environment variable only.
// Never hardcode the real client ID here.
export const GOOGLE_CLIENT_ID =
  import.meta.env.VITE_GOOGLE_CLIENT_ID ?? "";

export const FRONTEND_URL =
  import.meta.env.VITE_FRONTEND_URL ??
  window.location.origin;

export const OAUTH_CALLBACK_URL = `${FRONTEND_URL}/login`;

export const WHATSAPP_PHONE =
  import.meta.env.VITE_WHATSAPP_PHONE ?? "971500999733";

export const CONTACT_PHONE =
  import.meta.env.VITE_CONTACT_PHONE ?? "+971 50 099 9733";
