import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/trending/trending_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/watchlist/watchlist_screen.dart';
import '../screens/profile/profile_screen.dart';

/// App Router Configuration
/// Defines all routes and navigation for the application

class AppRouter {
  /// GoRouter instance
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      // Home Route
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Nested routes can be added here if needed
        ],
      ),

      // Trending Route
      GoRoute(
        path: '/trending',
        name: 'trending',
        builder: (context, state) => const TrendingScreen(),
      ),

      // Categories Route
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoriesScreen(),
      ),

      // Watchlist Route
      GoRoute(
        path: '/watchlist',
        name: 'watchlist',
        builder: (context, state) => const WatchlistScreen(),
      ),

      // Profile Route
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Trailer Detail Route (could be implemented for detailed trailer view)
      GoRoute(
        path: '/trailer/:id',
        name: 'trailer_detail',
        builder: (context, state) {
          final trailerId = state.pathParameters['id'] ?? '';
          // You can implement a detailed trailer view here
          // For now, we'll navigate back to home
          return const HomeScreen();
        },
      ),
    ],

    // Error page handler
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Page not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );

  /// Navigate to home
  static void goHome(BuildContext context) {
    context.go('/home');
  }

  /// Navigate to trending
  static void goTrending(BuildContext context) {
    context.go('/trending');
  }

  /// Navigate to categories
  static void goCategories(BuildContext context) {
    context.go('/categories');
  }

  /// Navigate to watchlist
  static void goWatchlist(BuildContext context) {
    context.go('/watchlist');
  }

  /// Navigate to profile
  static void goProfile(BuildContext context) {
    context.go('/profile');
  }

  /// Navigate to trailer detail
  static void goTrailerDetail(BuildContext context, String trailerId) {
    context.go('/trailer/$trailerId');
  }
}
