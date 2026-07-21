import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/views/splash_screen.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/auth/presentation/views/register_screen.dart';
import '../../features/home/presentation/views/home_screen.dart';
import '../../features/home/presentation/views/placeholder_screens.dart';
import '../../features/profile/presentation/views/profile_screen.dart';
import '../../features/navigation/presentation/main_navigation_shell.dart';
import '../../features/home/data/models/home_models.dart';
import '../../features/home/presentation/views/vehicle_detail_screen.dart';
import '../../features/admin/presentation/views/admin_navigation_shell.dart';

// ─── Route name constants ─────────────────────────────────────────────────────
class AppRoute {
  AppRoute._();
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/';
  static const search = '/search';
  static const fleet = '/fleet';
  static const profile = '/profile';
  static const vehicleDetail = '/vehicle';

  /// Phase 1 admin placeholder — role_id == 1 users land here.
  /// Replace with full admin ShellRoute in Phase 2.
  static const adminHome = '/admin';
}

// ─── Router Listenable ────────────────────────────────────────────────────────
class RouterListenable extends ChangeNotifier {
  RouterListenable(Ref ref) {
    ref.listen<AuthState>(authControllerProvider, (_, next) {
      notifyListeners();
    });
  }
}

// ─── Router provider ──────────────────────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  final listenable = RouterListenable(ref);

  return GoRouter(
    initialLocation: AppRoute.splash,
    refreshListenable: listenable,
    debugLogDiagnostics: false,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final isOnSplash = location == AppRoute.splash;

      // Always let splash render while auth state resolves
      if (isOnSplash) return null;

      // Still initialising — send non-splash routes back to splash
      if (authState is AuthInitializing) return AppRoute.splash;

      final isAuthenticated = authState is AuthAuthenticated;
      final isOnAuth = location == AppRoute.login || location == AppRoute.register;

      // Unauthenticated guard — only allow auth screens (/login, /register)
      if (!isAuthenticated && !isOnAuth) return AppRoute.login;

      // Authenticated guard — keep logged in users away from login/register screens
      if (authState is AuthAuthenticated && isOnAuth) {
        final user = authState.user;
        return user.isAdmin ? AppRoute.adminHome : AppRoute.home;
      }

      return null;
    },
    routes: [
      // ─── Unauthenticated routes ─────────────────────────────────────────────
      GoRoute(
        path: AppRoute.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // ─── Admin Dashboard ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoute.adminHome,
        builder: (context, state) => const AdminNavigationShell(),
      ),

      // ─── Vehicle Detail Screen ──────────────────────────────────────────────
      GoRoute(
        path: AppRoute.vehicleDetail,
        builder: (context, state) {
          final vehicle = state.extra as VehicleModel;
          return VehicleDetailScreen(vehicle: vehicle);
        },
      ),

      // ─── Search Screen ──────────────────────────────────────────────────────
      GoRoute(
        path: AppRoute.search,
        builder: (context, state) => const SearchPlaceholderScreen(),
      ),

      // ─── User shell with bottom navigation ──────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainNavigationShell(child: child),
        routes: [
          GoRoute(
            path: AppRoute.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoute.fleet,
            builder: (context, state) {
              final brand = state.uri.queryParameters['brand'];
              return FleetPlaceholderScreen(preselectedBrand: brand);
            },
          ),
          GoRoute(
            path: AppRoute.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
