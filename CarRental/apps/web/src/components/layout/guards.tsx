import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useAuthStore } from '../../store/authStore';

interface GuardProps {
  children: React.ReactNode;
}

const GuardLoader = () => (
  <div className="fixed inset-0 bg-[#0D0D0D] flex items-center justify-center z-50">
    <div className="w-12 h-12 rounded-full border-2 border-orange-500/30 border-t-orange-500 animate-spin" />
  </div>
);

export const ProtectedRoute: React.FC<GuardProps> = ({ children }) => {
  const { isAuthenticated, isInitializing } = useAuthStore();
  const location = useLocation();

  if (isInitializing) {
    return <GuardLoader />;
  }

  if (!isAuthenticated) {
    // Redirect to login page and remember original location
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return <>{children}</>;
};

export const AdminRoute: React.FC<GuardProps> = ({ children }) => {
  const { isAuthenticated, isAdmin, isInitializing } = useAuthStore();
  const location = useLocation();

  if (isInitializing) {
    return <GuardLoader />;
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  if (!isAdmin) {
    // Redirect non-admins to home page
    return <Navigate to="/" replace />;
  }

  return <>{children}</>;
};
