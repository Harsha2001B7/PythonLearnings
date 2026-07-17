import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/theme_toggle_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final surface2 = isDark ? AppColors.surface2Dark : AppColors.surface2Light;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        title: Text('My Profile',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: ListView(
        children: [
          // ─── Profile card ─────────────────────────────────────
          Container(
            color: surface,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.orange, width: 2),
                    color: surface2,
                  ),
                  child: Center(
                    child: Text(
                      user?.firstName2.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(
                        color: AppColors.orange,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'User',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(color: textMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              user?.role ?? 'User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Menu sections ────────────────────────────────────
          _MenuSection(
            title: 'Account',
            isDark: isDark,
            surface: surface,
            textColor: textColor,
            textMuted: textMuted,
            borderColor: borderColor,
            items: const [
              _MenuItem(icon: Icons.person_outline_rounded, title: 'Personal Information', subtitle: 'Edit your profile details'),
              _MenuItem(icon: Icons.badge_rounded, title: 'My Documents', subtitle: 'Emirates ID, Driving Licence'),
              _MenuItem(icon: Icons.account_balance_wallet_rounded, title: 'Payment Methods', subtitle: 'Add or manage cards'),
            ],
          ),

          const SizedBox(height: 16),

          _MenuSection(
            title: 'Preferences',
            isDark: isDark,
            surface: surface,
            textColor: textColor,
            textMuted: textMuted,
            borderColor: borderColor,
            items: const [
              _MenuItem(icon: Icons.notifications_none_rounded, title: 'Notifications', subtitle: 'Push, SMS, Email'),
              _MenuItem(icon: Icons.language_rounded, title: 'Language', subtitle: 'English'),
            ],
          ),

          const SizedBox(height: 16),

          _MenuSection(
            title: 'Support',
            isDark: isDark,
            surface: surface,
            textColor: textColor,
            textMuted: textMuted,
            borderColor: borderColor,
            items: const [
              _MenuItem(icon: Icons.help_outline_rounded, title: 'Help & FAQ'),
              _MenuItem(icon: Icons.chat_bubble_outline_rounded, title: 'Live Chat'),
              _MenuItem(icon: Icons.phone_in_talk_rounded, title: 'Call Us: +971 50 099 9733'),
            ],
          ),

          const SizedBox(height: 24),

          // ─── Logout button ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) context.go(AppRoute.login);
                },
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.errorDim),
                  backgroundColor: AppColors.errorDim,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              'Falcon View Car Rentals LLC · v1.0.0',
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({
    required this.title,
    required this.items,
    required this.isDark,
    required this.surface,
    required this.textColor,
    required this.textMuted,
    required this.borderColor,
  });

  final String title;
  final List<_MenuItem> items;
  final bool isDark;
  final Color surface;
  final Color textColor;
  final Color textMuted;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              return Column(
                children: [
                  ListTile(
                    onTap: () {},
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surface2Dark : AppColors.surface2Light,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, size: 20, color: textMuted),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: item.subtitle != null
                        ? Text(
                            item.subtitle!,
                            style: TextStyle(color: textMuted, fontSize: 11),
                          )
                        : null,
                    trailing: Icon(Icons.chevron_right_rounded,
                        size: 18, color: textMuted),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  ),
                  if (i < items.length - 1)
                    Divider(
                      height: 1,
                      color: borderColor,
                      indent: 66,
                      endIndent: 0,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  const _MenuItem({required this.icon, required this.title, this.subtitle});
  final IconData icon;
  final String title;
  final String? subtitle;
}
