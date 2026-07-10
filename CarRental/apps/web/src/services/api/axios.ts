import axios from 'axios';
import { useAuthStore } from '../../store/authStore';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:8000/api/v1',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request Interceptor: Attach access token (checks sessionStorage first, then localStorage)
api.interceptors.request.use((config) => {
  const token = sessionStorage.getItem('fv_access_token') || localStorage.getItem('fv_access_token');
  if (token && config.headers) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
}, (error) => {
  return Promise.reject(error);
});

// Response Interceptor: Handle token expiration
let isRefreshing = false;
let failedQueue: any[] = [];

const processQueue = (error: any, token: string | null = null) => {
  failedQueue.forEach(prom => {
    if (error) {
      prom.reject(error);
    } else {
      prom.resolve(token);
    }
  });
  failedQueue = [];
};

api.interceptors.response.use((response) => {
  return response;
}, async (error) => {
  const originalRequest = error.config;

  // Don't intercept refresh token failures or login/register failures
  if (
    originalRequest.url?.includes('/auth/refresh') || 
    originalRequest.url?.includes('/auth/login') ||
    originalRequest._retry
  ) {
    return Promise.reject(error);
  }

  if (error.response?.status === 401) {
    if (isRefreshing) {
      return new Promise((resolve, reject) => {
        failedQueue.push({ resolve, reject });
      })
        .then((token) => {
          originalRequest.headers.Authorization = `Bearer ${token}`;
          return api(originalRequest);
        })
        .catch((err) => {
          return Promise.reject(err);
        });
    }

    originalRequest._retry = true;
    isRefreshing = true;

    const refreshToken = sessionStorage.getItem('fv_refresh_token') || localStorage.getItem('fv_refresh_token');
    if (!refreshToken) {
      useAuthStore.getState().logout();
      return Promise.reject(error);
    }

    try {
      const baseUrl = import.meta.env.VITE_API_URL || 'http://localhost:8000/api/v1';
      const { data } = await axios.post(`${baseUrl}/auth/refresh`, {
        refresh_token: refreshToken
      });

      const newAccessToken = data.access_token;
      const newRefreshToken = data.refresh_token;

      // Determine where the tokens were stored
      const isLocal = !!localStorage.getItem('fv_refresh_token');
      const storage = isLocal ? localStorage : sessionStorage;

      useAuthStore.getState().setAccessToken(newAccessToken);
      storage.setItem('fv_refresh_token', newRefreshToken);

      originalRequest.headers.Authorization = `Bearer ${newAccessToken}`;

      processQueue(null, newAccessToken);
      isRefreshing = false;

      return api(originalRequest);
    } catch (refreshError) {
      processQueue(refreshError, null);
      isRefreshing = false;
      useAuthStore.getState().logout();
      return Promise.reject(refreshError);
    }
  }

  return Promise.reject(error);
});

export default api;
