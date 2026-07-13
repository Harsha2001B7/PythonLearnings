export const API_BASE_URL =
  import.meta.env.VITE_API_URL ??
  "https://falconviewcarrental.onrender.com/api/v1";

export const API_BASE = API_BASE_URL.replace("/api/v1", "");

export const STATIC_BASE_URL = API_BASE;
