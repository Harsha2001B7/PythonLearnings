import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/theme_toggle_button.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/models/admin_models.dart';

final adminUsersProvider = FutureProvider.autoDispose<List<AdminUserModel>>((ref) async {
  return ref.read(adminRepositoryProvider).fetchUsers();
});

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final surface2 = isDark ? AppColors.surface2Dark : AppColors.surface2Light;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: _saving
            ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // ─── Header ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'VAULT ACCESS',
                                style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Vault Users',
                                style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        const ThemeToggleButton(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── Search input ───────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      height: 46,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded, size: 20, color: textMuted),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  onChanged: (_) => setState(() {}),
                                  style: TextStyle(color: textColor, fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: 'Search users by name or email...',
                                    hintStyle: TextStyle(color: textMuted, fontSize: 13),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── User List ─────────────────────────────────────
                  Expanded(
                    child: usersAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.orange)),
                      error: (err, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('Failed to load users:\n$err',
                              style: TextStyle(color: textMuted), textAlign: TextAlign.center),
                        ),
                      ),
                      data: (users) {
                        final query = _searchCtrl.text.trim().toLowerCase();
                        final filtered = users.where((u) {
                          return u.displayName.toLowerCase().contains(query) ||
                              u.email.toLowerCase().contains(query);
                        }).toList();

                        if (filtered.isEmpty) {
                          return Center(
                            child: Text('No users found.',
                                style: TextStyle(color: textMuted, fontSize: 14)),
                          );
                        }

                        return RefreshIndicator(
                          color: AppColors.orange,
                          onRefresh: () => ref.refresh(adminUsersProvider.future),
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, idx) {
                              final user = filtered[idx];
                              return _AdminUserManageCard(
                                user: user,
                                isDark: isDark,
                                surface2: surface2,
                                textColor: textColor,
                                textMuted: textMuted,
                                borderColor: borderColor,
                                onStatusToggled: (newStatus) async {
                                  setState(() => _saving = true);
                                  try {
                                    await ref.read(adminRepositoryProvider).updateUserStatus(user.id, newStatus);
                                    ref.invalidate(adminUsersProvider);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('User status updated to $newStatus!'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to update user status: $e'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) setState(() => _saving = false);
                                  }
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}


class _AdminUserManageCard extends StatelessWidget {
  const _AdminUserManageCard({
    required this.user,
    required this.isDark,
    required this.surface2,
    required this.textColor,
    required this.textMuted,
    required this.borderColor,
    required this.onStatusToggled,
  });

  final AdminUserModel user;
  final bool isDark;
  final Color surface2;
  final Color textColor;
  final Color textMuted;
  final Color borderColor;
  final ValueChanged<String> onStatusToggled;

  @override
  Widget build(BuildContext context) {
    final status = user.status.toLowerCase();
    final isActive = status == 'active';
    
    Color statusColor = isActive ? AppColors.success : AppColors.error;
    Color statusBg = (isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.1);

    final initial = user.displayName.isNotEmpty ? user.displayName.substring(0, 1).toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // User Avatar Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface3Dark : AppColors.surface3Light,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(color: AppColors.orange, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: TextStyle(color: textMuted, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  'Phone: ${user.phone ?? "N/A"}',
                  style: TextStyle(color: textMuted, fontSize: 10),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: user.role.toUpperCase() == 'ADMIN' 
                            ? AppColors.orange.withValues(alpha: 0.1)
                            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          color: user.role.toUpperCase() == 'ADMIN' ? AppColors.orange : textMuted,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(100)),
                      child: Text(
                        isActive ? 'ACTIVE' : 'DISABLED',
                        style: TextStyle(color: statusColor, fontSize: 8, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Button
          SizedBox(
            width: 76,
            height: 32,
            child: ElevatedButton(
              onPressed: () => onStatusToggled(isActive ? 'disabled' : 'active'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive ? AppColors.errorDim : AppColors.success.withValues(alpha: 0.1),
                side: BorderSide(color: isActive ? AppColors.error : AppColors.success, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.zero,
                elevation: 0,
              ),
              child: Text(
                isActive ? 'DISABLE' : 'ENABLE',
                style: TextStyle(
                  color: isActive ? AppColors.error : AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
