import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/presentation/screens/preloader_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/fleet/presentation/screens/fleet_screen.dart';
import '../../features/vehicle/presentation/screens/vehicle_detail_screen.dart';
import '../../features/support/presentation/screens/chat_screen.dart';
import '../../features/favorites/presentation/screens/wishlist_screen.dart';
import '../../features/settings/presentation/screens/more_screen.dart';
import 'main_navigation_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Preloader (Initial landing screen)
      GoRoute(
        path: '/',
        builder: (context, state) => const PreloaderScreen(),
      ),

      // Stateful nested navigation for bottom shell branches
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Home Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Branch 2: Fleet Explorer
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/fleet',
                builder: (context, state) => const FleetScreen(),
                routes: [
                  // Nested Vehicle Detail screen
                  GoRoute(
                    path: 'vehicle/:slug',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final slug = state.pathParameters['slug'] ?? '';
                      return VehicleDetailScreen(slug: slug);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 3: Chat Concierge
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),

          // Branch 4: Wishlist Favorites
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wishlist',
                builder: (context, state) => const WishlistScreen(),
              ),
            ],
          ),

          // Branch 5: FAQ & More Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
