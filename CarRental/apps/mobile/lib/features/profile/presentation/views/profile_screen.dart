import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../shared/widgets/theme_toggle_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/profile_models.dart';
import '../../data/repositories/profile_repository.dart';
import 'my_bookings_screen.dart';
import 'faq_screen.dart';

final settingsProvider = FutureProvider.autoDispose<List<SiteSettingModel>>((ref) async {
  final repo = ref.read(profileRepositoryProvider);
  return repo.fetchSettings();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _openEditProfileSheet(BuildContext context, WidgetRef ref, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditPersonalInfoSheet(user: user),
    );
  }

  Widget _avatarFallback(String name) => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppColors.orange,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsAsync = ref.watch(settingsProvider);

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final surface2 = isDark ? AppColors.surface2Dark : AppColors.surface2Light;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    // Resolve support phone number dynamically from settings API
    final supportPhone = settingsAsync.maybeWhen(
      data: (settings) {
        for (final s in settings) {
          if (s.key.toLowerCase().contains('phone') || s.key.toLowerCase().contains('contact')) {
            return s.value;
          }
        }
        return '+971 50 099 9733';
      },
      orElse: () => '+971 50 099 9733',
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
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
                // Google Account Avatar with no red crop border cuts
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: surface2,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: user?.avatar != null && user!.avatar!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: user.avatar!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: surface2),
                          errorWidget: (context, url, error) => _avatarFallback(user.firstName2),
                        )
                      : _avatarFallback(user?.firstName2 ?? '?'),
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
            onItemTap: (title) {
              if (title == 'Personal Information' && user != null) {
                _openEditProfileSheet(context, ref, user);
              } else if (title == 'My Bookings') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookingsScreen()));
              }
            },
            items: const [
              _MenuItem(icon: Icons.person_outline_rounded, title: 'Personal Information', subtitle: 'Edit your profile details'),
              _MenuItem(icon: Icons.history_rounded, title: 'My Bookings', subtitle: 'View your booking history'),
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
            onItemTap: (title) {},
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
            onItemTap: (title) {
              if (title == 'Help & FAQ') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqScreen()));
              }
            },
            items: [
              const _MenuItem(icon: Icons.help_outline_rounded, title: 'Help & FAQ'),
              const _MenuItem(icon: Icons.chat_bubble_outline_rounded, title: 'Live Chat'),
              _MenuItem(icon: Icons.phone_in_talk_rounded, title: 'Call Us: $supportPhone'),
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
    required this.onItemTap,
  });

  final String title;
  final List<_MenuItem> items;
  final bool isDark;
  final Color surface;
  final Color textColor;
  final Color textMuted;
  final Color borderColor;
  final ValueChanged<String> onItemTap;

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
                    onTap: () => onItemTap(item.title),
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

// ─── Edit Personal Information Bottom Sheet ──────────────────────────────────
class _EditPersonalInfoSheet extends ConsumerStatefulWidget {
  const _EditPersonalInfoSheet({required this.user});
  final UserModel user;

  @override
  ConsumerState<_EditPersonalInfoSheet> createState() => _EditPersonalInfoSheetState();
}

class _EditPersonalInfoSheetState extends ConsumerState<_EditPersonalInfoSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstCtrl;
  late final TextEditingController _lastCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _countryCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _firstCtrl = TextEditingController(text: widget.user.firstName ?? widget.user.name.split(' ').first);
    // Extract last name or default
    final parts = widget.user.name.split(' ');
    final defLast = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    _lastCtrl = TextEditingController(text: widget.user.lastName ?? defLast);
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
    _countryCtrl = TextEditingController(text: widget.user.country ?? '');
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _phoneCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final dio = ref.read(dioProvider);
      
      // Call PUT /users/me endpoint in the backend API
      final response = await dio.put(
        '${ApiEndpoints.baseUrl}/api/v1/users/me',
        data: {
          'first_name': _firstCtrl.text.trim(),
          'last_name': _lastCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'country': _countryCtrl.text.trim(),
        },
      );

      final updatedUser = UserModel.fromJson(response.data as Map<String, dynamic>);
      
      // Update local state dynamically via AuthController
      ref.read(authControllerProvider.notifier).updateUser(updatedUser);

      if (!mounted) return;
      Navigator.pop(context); // Close modal sheet
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final surface2 = isDark ? AppColors.surface2Dark : AppColors.surface2Light;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _saving
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(color: AppColors.orange),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First Name Field
                      _fieldLabel('FIRST NAME', textMuted),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _firstCtrl,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: _inputDecoration('e.g. John', surface2, borderColor),
                        validator: (v) => (v == null || v.isEmpty) ? 'First name is required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Last Name Field
                      _fieldLabel('LAST NAME', textMuted),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _lastCtrl,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: _inputDecoration('e.g. Doe', surface2, borderColor),
                        validator: (v) => (v == null || v.isEmpty) ? 'Last name is required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Phone Field
                      _fieldLabel('PHONE NUMBER', textMuted),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: _inputDecoration('e.g. +971 50 000 0000', surface2, borderColor),
                      ),
                      const SizedBox(height: 16),

                      // Country Field
                      _fieldLabel('COUNTRY', textMuted),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _countryCtrl,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: _inputDecoration('e.g. United Arab Emirates', surface2, borderColor),
                      ),
                      const SizedBox(height: 28),

                      // Save Changes button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _onSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, Color bg, Color border) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      filled: true,
      fillColor: bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.orange)),
    );
  }
}
