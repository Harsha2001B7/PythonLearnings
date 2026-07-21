import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/theme_toggle_button.dart';
import '../../../../shared/widgets/notification_bell_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/models/admin_models.dart';

final adminStatsProvider = FutureProvider.autoDispose<AdminStatsModel>((ref) async {
  return ref.read(adminRepositoryProvider).fetchStats();
});

final adminRecentBookingsProvider = FutureProvider.autoDispose<List<AdminBookingModel>>((ref) async {
  return ref.read(adminRepositoryProvider).fetchBookings();
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final bookingsAsync = ref.watch(adminRecentBookingsProvider);
    final authState = ref.watch(authControllerProvider);
    final adminUser = authState is AuthAuthenticated ? authState.user : null;

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
        child: RefreshIndicator(
          color: AppColors.orange,
          onRefresh: () async {
            ref.invalidate(adminStatsProvider);
            ref.invalidate(adminRecentBookingsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 16),
              // ─── Header ─────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VAULT CONTROL',
                          style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dashboard',
                          style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  const ThemeToggleButton(),
                  const SizedBox(width: 4),
                  const NotificationBellButton(),
                  const SizedBox(width: 8),
                  // Admin Photo
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: surface2),
                    clipBehavior: Clip.antiAlias,
                    child: adminUser?.avatar != null && adminUser!.avatar!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: adminUser.avatar!,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Text(
                              adminUser?.firstName2.substring(0, 1).toUpperCase() ?? 'A',
                              style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Metrics Grid ──────────────────────────────────
              statsAsync.when(
                data: (stats) {
                  // Resolve pending count dynamically from recent bookings
                  final pendingCount = bookingsAsync.maybeWhen(
                    data: (list) => list.where((b) => b.status.toLowerCase() == 'pending').length,
                    orElse: () => stats.todayBookings,
                  );

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: 'TOTAL FLEET',
                              value: stats.totalVehicles.toString(),
                              surface: surface,
                              textColor: textColor,
                              textMuted: textMuted,
                              borderColor: borderColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'ACTIVE RENTALS',
                              value: stats.bookedVehicles.toString(),
                              surface: AppColors.orange,
                              textColor: Colors.white,
                              textMuted: Colors.white70,
                              borderColor: Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: 'AVAILABLE',
                              value: stats.availableVehicles.toString(),
                              surface: surface,
                              textColor: textColor,
                              textMuted: textMuted,
                              borderColor: borderColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'PENDING',
                              value: pendingCount.toString(),
                              surface: surface,
                              textColor: textColor,
                              textMuted: textMuted,
                              borderColor: borderColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Today's Revenue card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "TODAY'S REVENUE",
                              style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'AED ${NumberFormat('#,###').format(stats.monthlyRevenue)}',
                              style: const TextStyle(
                                color: AppColors.orange,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.trending_up_rounded, size: 16, color: AppColors.success),
                                const SizedBox(width: 4),
                                Text(
                                  '+18% vs. yesterday',
                                  style: TextStyle(color: isDark ? AppColors.success : AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(color: AppColors.orange),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text('Failed to load stats: $err', style: const TextStyle(color: AppColors.error)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Recent Bookings ───────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Bookings',
                    style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'View All',
                      style: TextStyle(color: AppColors.orange, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              bookingsAsync.when(
                data: (bookings) {
                  final list = bookings.take(5).toList();
                  if (list.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
                      child: Center(
                        child: Text('No recent bookings found.', style: TextStyle(color: textMuted, fontSize: 13)),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final b = list[idx];
                      final name = b.user?.displayName ?? 'User';
                      final initial = name.substring(0, 1).toUpperCase();

                      final status = b.status.toLowerCase();
                      Color statusColor = AppColors.orange;
                      Color statusBg = AppColors.orange.withValues(alpha: 0.1);
                      if (status == 'completed' || status == 'approved' || status == 'active') {
                        statusColor = AppColors.success;
                        statusBg = AppColors.success.withValues(alpha: 0.1);
                      } else if (status == 'cancelled' || status == 'rejected') {
                        statusColor = AppColors.error;
                        statusBg = AppColors.error.withValues(alpha: 0.1);
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            // User Circle Initial Icon
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surface3Dark : AppColors.surface3Light,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(color: AppColors.orange, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    b.vehicle?.name ?? 'Premium Car',
                                    style: TextStyle(color: textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(100)),
                              child: Text(
                                b.status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.orange)),
                error: (err, stack) => const SizedBox(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color surface,
    required Color textColor,
    required Color textMuted,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: textMuted, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
