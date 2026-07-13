import { API_BASE_URL as BASE_URL } from './env';

export const API_BASE_URL = BASE_URL;

export const API_BASE = API_BASE_URL.replace("/api/v1", "");

export const STATIC_BASE_URL = API_BASE;
