import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/views/splash_screen.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/home/presentation/views/home_screen.dart';
import '../../features/home/presentation/views/placeholder_screens.dart';
import '../../features/profile/presentation/views/profile_screen.dart';
import '../../features/navigation/presentation/main_navigation_shell.dart';

// ─── Route name constants ─────────────────────────────────────────────────────
class AppRoute {
  AppRoute._();
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/';
  static const search = '/search';
  static const fleet = '/fleet';
  static const profile = '/profile';

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
      final isOnLogin = location == AppRoute.login;

      // Always let splash render while auth state resolves
      if (isOnSplash) return null;

      // Still initialising — send non-splash routes back to splash
      if (authState is AuthInitializing) return AppRoute.splash;

      final isAuthenticated = authState is AuthAuthenticated;

      // Unauthenticated guard
      if (!isAuthenticated && !isOnLogin) return AppRoute.login;

      // Authenticated guard — keep admin away from user shell and vice versa
      if (isAuthenticated && isOnLogin) {
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

      // ─── Admin placeholder (Phase 1) ────────────────────────────────────────
      GoRoute(
        path: AppRoute.adminHome,
        builder: (context, state) => const AdminPlaceholderScreen(),
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
            path: AppRoute.search,
            builder: (context, state) => const SearchPlaceholderScreen(),
          ),
          GoRoute(
            path: AppRoute.fleet,
            builder: (context, state) => const FleetPlaceholderScreen(),
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
