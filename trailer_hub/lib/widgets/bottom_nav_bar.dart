import 'package:flutter/material.dart';
import '../navigation/app_router.dart';
import '../core/theme/app_theme.dart';

/// Bottom Navigation Bar Widget
/// Custom bottom navigation bar for app navigation

class BottomNavBar extends StatelessWidget {
  final String currentRoute;

  const BottomNavBar({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'label': 'Home',
        'icon': Icons.home,
        'route': '/home',
      },
      {
        'label': 'Trending',
        'icon': Icons.trending_up,
        'route': '/trending',
      },
      {
        'label': 'Categories',
        'icon': Icons.category,
        'route': '/categories',
      },
      {
        'label': 'Watchlist',
        'icon': Icons.bookmark,
        'route': '/watchlist',
      },
      {
        'label': 'Profile',
        'icon': Icons.person,
        'route': '/profile',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _getSelectedIndex(),
        onTap: (index) {
          final route = items[index]['route'] as String;
          _navigateToRoute(context, route);
        },
        items: items.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item['icon'] as IconData),
            label: item['label'] as String,
          );
        }).toList(),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  /// Get selected index based on current route
  int _getSelectedIndex() {
    if (currentRoute.contains('/home')) return 0;
    if (currentRoute.contains('/trending')) return 1;
    if (currentRoute.contains('/categories')) return 2;
    if (currentRoute.contains('/watchlist')) return 3;
    if (currentRoute.contains('/profile')) return 4;
    return 0;
  }

  /// Navigate to route
  void _navigateToRoute(BuildContext context, String route) {
    switch (route) {
      case '/home':
        AppRouter.goHome(context);
        break;
      case '/trending':
        AppRouter.goTrending(context);
        break;
      case '/categories':
        AppRouter.goCategories(context);
        break;
      case '/watchlist':
        AppRouter.goWatchlist(context);
        break;
      case '/profile':
        AppRouter.goProfile(context);
        break;
    }
  }
}
