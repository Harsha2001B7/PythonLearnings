import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';

class MainNavigationShell extends ConsumerWidget {
  const MainNavigationShell({super.key, required this.child});
  final Widget child;

  static const _destinations = [
    _NavItem(icon: Icons.home_rounded, label: 'Home', route: AppRoute.home),
    _NavItem(icon: Icons.search_rounded, label: 'Search', route: AppRoute.search),
    _NavItem(icon: Icons.directions_car_rounded, label: 'Fleet', route: AppRoute.fleet),
    _NavItem(icon: Icons.person_rounded, label: 'Profile', route: AppRoute.profile),
  ];

  int _activeIndex(String location) {
    if (location.startsWith(AppRoute.search)) return 1;
    if (location.startsWith(AppRoute.fleet)) return 2;
    if (location.startsWith(AppRoute.profile)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final activeIndex = _activeIndex(location);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_destinations.length, (i) {
                final item = _destinations[i];
                final isActive = i == activeIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      if (!isActive) context.go(item.route);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 24,
                            color: isActive ? AppColors.orange : mutedColor,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                              color: isActive ? AppColors.orange : mutedColor,
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(height: 3),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AppColors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ] else
                            const SizedBox(height: 7),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label, required this.route});
  final IconData icon;
  final String label;
  final String route;
}
