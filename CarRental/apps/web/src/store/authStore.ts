import { create } from 'zustand';

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
}

interface AuthState {
  user: UserProfile | null;
  accessToken: string | null;
  isAuthenticated: boolean;
  isAdmin: boolean;
  login: (accessToken: string, refreshToken: string, user: UserProfile) => void;
  logout: () => void;
  updateUser: (user: Partial<UserProfile>) => void;
  setAccessToken: (token: string) => void;
}

const getStoredUser = (): UserProfile | null => {
  const user = localStorage.getItem('fv_user');
  try {
    return user ? JSON.parse(user) : null;
  } catch {
    return null;
  }
};

const initialUser = getStoredUser();
const initialToken = localStorage.getItem('fv_access_token');
// Role ID 1 is Admin, Role ID 2 is User. We'll also check role_id or user email/claims if needed.
const checkIsAdmin = (user: UserProfile | null): boolean => {
  // We can determine if user is admin based on role_id (1 = Admin) or we can set it in JWT payload
  return user?.role_id === 1;
};

export const useAuthStore = create<AuthState>((set) => ({
  user: initialUser,
  accessToken: initialToken,
  isAuthenticated: !!initialToken && !!initialUser,
  isAdmin: checkIsAdmin(initialUser),

  login: (accessToken, refreshToken, user) => {
    localStorage.setItem('fv_access_token', accessToken);
    localStorage.setItem('fv_refresh_token', refreshToken);
    localStorage.setItem('fv_user', JSON.stringify(user));
    
    set({
      user,
      accessToken,
      isAuthenticated: true,
      isAdmin: checkIsAdmin(user)
    });
  },

  logout: () => {
    localStorage.removeItem('fv_access_token');
    localStorage.removeItem('fv_refresh_token');
    localStorage.removeItem('fv_user');
    
    set({
      user: null,
      accessToken: null,
      isAuthenticated: false,
      isAdmin: false
    });
  },

  updateUser: (updatedFields) => {
    set((state) => {
      if (!state.user) return state;
      const newUser = { ...state.user, ...updatedFields };
      localStorage.setItem('fv_user', JSON.stringify(newUser));
      return {
        user: newUser,
        isAdmin: checkIsAdmin(newUser)
      };
    });
  },

  setAccessToken: (accessToken) => {
    localStorage.setItem('fv_access_token', accessToken);
    set({ accessToken });
  }
}));
