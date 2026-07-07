import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class MainNavigationScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.panel,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1.5),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: 'Home',
                  isActive: navigationShell.currentIndex == 0,
                  onTap: () => navigationShell.goBranch(0),
                ),
                _NavBarItem(
                  icon: Icons.directions_car_outlined,
                  activeIcon: Icons.directions_car,
                  label: 'Fleet',
                  isActive: navigationShell.currentIndex == 1,
                  onTap: () => navigationShell.goBranch(1),
                ),
                _NavBarItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: 'Concierge',
                  isActive: navigationShell.currentIndex == 2,
                  onTap: () => navigationShell.goBranch(2),
                ),
                _NavBarItem(
                  icon: Icons.favorite_border_rounded,
                  activeIcon: Icons.favorite_rounded,
                  label: 'Wishlist',
                  isActive: navigationShell.currentIndex == 3,
                  onTap: () => navigationShell.goBranch(3),
                ),
                _NavBarItem(
                  icon: Icons.menu_rounded,
                  activeIcon: Icons.menu_open_rounded,
                  label: 'More',
                  isActive: navigationShell.currentIndex == 4,
                  onTap: () => navigationShell.goBranch(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: isActive ? AppColors.amberPale : Colors.transparent,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.amber : AppColors.inkMuted,
              size: 22,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: AppTypography.monoStyle(
              color: isActive ? AppColors.amber : AppColors.inkMuted,
              size: 9.0,
            ).copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
