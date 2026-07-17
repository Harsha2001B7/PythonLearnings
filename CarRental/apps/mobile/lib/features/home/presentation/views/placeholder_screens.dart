import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/theme_toggle_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Placeholder for the Search tab (Phase 1).
class SearchPlaceholderScreen extends StatelessWidget {
  const SearchPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _PlaceholderView(
      icon: Icons.search_rounded,
      title: 'Search',
      subtitle: 'Search for vehicles by name, brand, or category.',
    );
  }
}

/// Placeholder for the Fleet tab (Phase 1).
class FleetPlaceholderScreen extends StatelessWidget {
  const FleetPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _PlaceholderView(
      icon: Icons.directions_car_rounded,
      title: 'Fleet',
      subtitle: 'Browse our complete fleet of luxury cars.',
    );
  }
}

class _PlaceholderView extends StatelessWidget {
  const _PlaceholderView({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.orangeDim,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, size: 36, color: AppColors.orange),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: textMuted, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '— Coming in Phase 2 —',
              style: TextStyle(
                color: AppColors.orange.withValues(alpha: 0.6),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Phase 1 Admin Placeholder — shown to users with role_id == 1 (Admin).
/// Replace with full admin dashboard in Phase 2.
class AdminPlaceholderScreen extends ConsumerWidget {
  const AdminPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        title: Text('Admin Dashboard',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Admin badge
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.orange.withValues(alpha: 0.2),
                      AppColors.orange.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.orange.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 40,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Admin Console',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You are logged in as an Administrator.',
                style: TextStyle(color: textMuted, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.warningDim,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  '⚠ Full admin panel coming in Phase 2',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Quick-action tiles
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _AdminTile(
                        icon: Icons.directions_car_rounded,
                        label: 'Manage Fleet',
                        textColor: textColor,
                        textMuted: textMuted),
                    Divider(color: borderColor, height: 1),
                    _AdminTile(
                        icon: Icons.book_online_rounded,
                        label: 'Manage Bookings',
                        textColor: textColor,
                        textMuted: textMuted),
                    Divider(color: borderColor, height: 1),
                    _AdminTile(
                        icon: Icons.people_rounded,
                        label: 'Manage Users',
                        textColor: textColor,
                        textMuted: textMuted),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) context.go(AppRoute.login);
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                  label: const Text('Sign Out',
                      style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.errorDim),
                    backgroundColor: AppColors.errorDim,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({
    required this.icon,
    required this.label,
    required this.textColor,
    required this.textMuted,
  });
  final IconData icon;
  final String label;
  final Color textColor;
  final Color textMuted;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      leading: Icon(icon, color: AppColors.orange, size: 22),
      title: Text(label,
          style: TextStyle(
              color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: Icon(Icons.chevron_right_rounded, color: textMuted, size: 18),
      contentPadding: EdgeInsets.zero,
    );
  }
}
