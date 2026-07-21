import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'admin_dashboard_screen.dart';
import 'admin_vehicles_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_users_screen.dart';

class AdminNavigationShell extends ConsumerStatefulWidget {
  const AdminNavigationShell({super.key});

  @override
  ConsumerState<AdminNavigationShell> createState() => _AdminNavigationShellState();
}

class _AdminNavigationShellState extends ConsumerState<AdminNavigationShell> {
  int _activeIndex = 0;

  final _screens = const [
    AdminDashboardScreen(),
    AdminVehiclesScreen(),
    AdminBookingsScreen(),
    AdminUsersScreen(),
    AdminSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Scaffold(
      body: IndexedStack(
        sizing: StackFit.expand,
        index: _activeIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                _buildNavItem(0, Icons.dashboard_rounded, 'Dashboard', mutedColor),
                _buildNavItem(1, Icons.directions_car_rounded, 'Vehicles', mutedColor),
                _buildNavItem(2, Icons.calendar_month_rounded, 'Bookings', mutedColor),
                _buildNavItem(3, Icons.people_rounded, 'Users', mutedColor),
                _buildNavItem(4, Icons.settings_rounded, 'Settings', mutedColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color mutedColor) {
    final isActive = _activeIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _activeIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isActive ? AppColors.orange : mutedColor,
              ),
              const SizedBox(height: 3),
              Text(
                label,
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
  }
}
