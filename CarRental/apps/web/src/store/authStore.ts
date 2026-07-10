import { create } from 'zustand';
import axios from 'axios';

export interface UserProfile {
  id: number;
  email: string;
  first_name: string | null;
  last_name: string | null;
  phone: string | null;
  country: string | null;
  profile_image: string | null;
  status: string;
  is_verified: boolean;
  role_id: number | null;
  name?: string;
  role?: string;
  permissions?: string[];
  avatar?: string | null;
}

interface AuthState {
  user: UserProfile | null;
  accessToken: string | null;
  isAuthenticated: boolean;
  isAdmin: boolean;
  isInitializing: boolean;
  login: (accessToken: string, refreshToken: string, user: UserProfile, rememberMe: boolean) => void;
  logout: () => void;
  updateUser: (user: Partial<UserProfile>) => void;
  setAccessToken: (token: string) => void;
  initializeAuth: () => Promise<void>;
}

const getStoredItem = (key: string): string | null => {
  return sessionStorage.getItem(key) || localStorage.getItem(key);
};

const getStoredUser = (): UserProfile | null => {
  const user = getStoredItem('fv_user');
  try {
    return user ? JSON.parse(user) : null;
  } catch {
    return null;
  }
};

const checkIsAdmin = (user: UserProfile | null): boolean => {
  return user?.role_id === 1 || user?.role === 'Admin';
};

const initialUser = getStoredUser();
const initialToken = getStoredItem('fv_access_token');

export const useAuthStore = create<AuthState>((set) => ({
  user: initialUser,
  accessToken: initialToken,
  isAuthenticated: !!initialToken && !!initialUser,
  isAdmin: checkIsAdmin(initialUser),
  isInitializing: true, // starts loading auth on application startup

  login: (accessToken, refreshToken, user, rememberMe) => {
    const storage = rememberMe ? localStorage : sessionStorage;
    
    // Clear the other storage to prevent dual-storage token conflicts
    const otherStorage = rememberMe ? sessionStorage : localStorage;
    otherStorage.removeItem('fv_access_token');
    otherStorage.removeItem('fv_refresh_token');
    otherStorage.removeItem('fv_user');

    storage.setItem('fv_access_token', accessToken);
    storage.setItem('fv_refresh_token', refreshToken);
    storage.setItem('fv_user', JSON.stringify(user));
    
    set({
      user,
      accessToken,
      isAuthenticated: true,
      isAdmin: checkIsAdmin(user),
      isInitializing: false
    });
  },

  logout: () => {
    localStorage.removeItem('fv_access_token');
    localStorage.removeItem('fv_refresh_token');
    localStorage.removeItem('fv_user');
    sessionStorage.removeItem('fv_access_token');
    sessionStorage.removeItem('fv_refresh_token');
    sessionStorage.removeItem('fv_user');
    
    set({
      user: null,
      accessToken: null,
      isAuthenticated: false,
      isAdmin: false,
      isInitializing: false
    });
  },

  updateUser: (updatedFields) => {
    set((state) => {
      if (!state.user) return state;
      const newUser = { ...state.user, ...updatedFields };
      
      // Save to whichever storage currently holds the user profile
      if (localStorage.getItem('fv_user')) {
        localStorage.setItem('fv_user', JSON.stringify(newUser));
      } else {
        sessionStorage.setItem('fv_user', JSON.stringify(newUser));
      }

      return {
        user: newUser,
        isAdmin: checkIsAdmin(newUser)
      };
    });
  },

  setAccessToken: (accessToken) => {
    if (localStorage.getItem('fv_access_token')) {
      localStorage.setItem('fv_access_token', accessToken);
    } else {
      sessionStorage.setItem('fv_access_token', accessToken);
    }
    set({ accessToken });
  },

  initializeAuth: async () => {
    const token = getStoredItem('fv_access_token');
    const refresh = getStoredItem('fv_refresh_token');
    const baseUrl = import.meta.env.VITE_API_URL || 'http://localhost:8000/api/v1';

    if (!token) {
      set({
        user: null,
        accessToken: null,
        isAuthenticated: false,
        isAdmin: false,
        isInitializing: false
      });
      return;
    }

    try {
      // Validate token by fetching the profile
      const response = await axios.get(`${baseUrl}/auth/me`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      const user = response.data;
      
      // Update store state
      set({
        user,
        accessToken: token,
        isAuthenticated: true,
        isAdmin: checkIsAdmin(user),
        isInitializing: false
      });
    } catch (err: any) {
      // If validation fails, try refreshing the token
      if (refresh) {
        try {
          const response = await axios.post(`${baseUrl}/auth/refresh`, {
            refresh_token: refresh
          });
          const { access_token, refresh_token } = response.data;

          const profileResponse = await axios.get(`${baseUrl}/auth/me`, {
            headers: { Authorization: `Bearer ${access_token}` }
          });
          const user = profileResponse.data;

          // Determine which storage to use by checking where the old tokens resided
          const isLocal = !!localStorage.getItem('fv_refresh_token');
          const storage = isLocal ? localStorage : sessionStorage;

          storage.setItem('fv_access_token', access_token);
          storage.setItem('fv_refresh_token', refresh_token);
          storage.setItem('fv_user', JSON.stringify(user));

          set({
            user,
            accessToken: access_token,
            isAuthenticated: true,
            isAdmin: checkIsAdmin(user),
            isInitializing: false
          });
          return;
        } catch (refreshErr) {
          // Refresh failed
        }
      }

      // If token validation and refresh both fail, clean up and log out
      localStorage.removeItem('fv_access_token');
      localStorage.removeItem('fv_refresh_token');
      localStorage.removeItem('fv_user');
      sessionStorage.removeItem('fv_access_token');
      sessionStorage.removeItem('fv_refresh_token');
      sessionStorage.removeItem('fv_user');

      set({
        user: null,
        accessToken: null,
        isAuthenticated: false,
        isAdmin: false,
        isInitializing: false
      });
    }
  }
}));
