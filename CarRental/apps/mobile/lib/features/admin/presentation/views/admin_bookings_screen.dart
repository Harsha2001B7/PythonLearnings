import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/theme_toggle_button.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/models/admin_models.dart';

final adminBookingsProvider = FutureProvider.autoDispose<List<AdminBookingModel>>((ref) async {
  return ref.read(adminRepositoryProvider).fetchBookings();
});

class AdminBookingsScreen extends ConsumerWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(adminBookingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final surface2 = isDark ? AppColors.surface2Dark : AppColors.surface2Light;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
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
                          'RESERVATION CONTROL',
                          style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All Bookings',
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

            // ─── Bookings List ──────────────────────────────────
            Expanded(
              child: bookingsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.orange)),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Failed to load bookings:\n$err',
                        style: TextStyle(color: textMuted), textAlign: TextAlign.center),
                  ),
                ),
                data: (bookings) {
                  if (bookings.isEmpty) {
                    return Center(
                      child: Text('No bookings found.',
                          style: TextStyle(color: textMuted, fontSize: 14)),
                    );
                  }

                  // Sort bookings with pending first, then by date descending
                  final sortedList = List<AdminBookingModel>.from(bookings)
                    ..sort((a, b) {
                      if (a.status.toLowerCase() == 'pending' && b.status.toLowerCase() != 'pending') return -1;
                      if (a.status.toLowerCase() != 'pending' && b.status.toLowerCase() == 'pending') return 1;
                      final da = a.createdAt ?? DateTime.now();
                      final db = b.createdAt ?? DateTime.now();
                      return db.compareTo(da);
                    });

                  return RefreshIndicator(
                    color: AppColors.orange,
                    onRefresh: () => ref.refresh(adminBookingsProvider.future),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: sortedList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, idx) {
                        final booking = sortedList[idx];
                        return _AdminBookingManageCard(
                          booking: booking,
                          isDark: isDark,
                          surface2: surface2,
                          textColor: textColor,
                          textMuted: textMuted,
                          borderColor: borderColor,
                          onActionPressed: (status) async {
                            try {
                              await ref.read(adminRepositoryProvider).updateBookingStatus(booking.id, status);
                              ref.invalidate(adminBookingsProvider);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Reservation status updated to $status!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to update status: $e'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
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

class _AdminBookingManageCard extends StatelessWidget {
  const _AdminBookingManageCard({
    required this.booking,
    required this.isDark,
    required this.surface2,
    required this.textColor,
    required this.textMuted,
    required this.borderColor,
    required this.onActionPressed,
  });

  final AdminBookingModel booking;
  final bool isDark;
  final Color surface2;
  final Color textColor;
  final Color textMuted;
  final Color borderColor;
  final ValueChanged<String> onActionPressed;

  @override
  Widget build(BuildContext context) {
    final status = booking.status.toLowerCase();
    
    // Status colors
    Color statusColor = AppColors.orange;
    Color statusBg = AppColors.orange.withValues(alpha: 0.1);
    if (status == 'completed' || status == 'approved' || status == 'active') {
      statusColor = AppColors.success;
      statusBg = AppColors.success.withValues(alpha: 0.1);
    } else if (status == 'cancelled' || status == 'rejected') {
      statusColor = AppColors.error;
      statusBg = AppColors.error.withValues(alpha: 0.1);
    }

    final startFmt = booking.startDate != null ? DateFormat('dd MMM').format(booking.startDate!) : 'N/A';
    final endFmt = booking.endDate != null ? DateFormat('dd MMM yyyy').format(booking.endDate!) : 'N/A';
    final createdFmt = booking.createdAt != null ? DateFormat('dd MMM yyyy, hh:mm a').format(booking.createdAt!) : 'N/A';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking #${booking.id}',
                style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(100)),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          Divider(color: borderColor, height: 20),

          // Renter & Vehicle Info
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 16, color: textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${booking.user?.displayName ?? "User"} (${booking.user?.phone ?? "No Phone"})',
                  style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.directions_car_outlined, size: 16, color: textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${booking.vehicle?.name ?? "Premium Car"} (${booking.vehicle?.year ?? "2023"})',
                  style: TextStyle(color: textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.date_range_rounded, size: 16, color: textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lease: $startFmt – $endFmt',
                  style: TextStyle(color: textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 16, color: AppColors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Booked On: $createdFmt',
                  style: const TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Price', style: TextStyle(color: textMuted, fontSize: 12)),
              Text(
                'AED ${booking.totalPrice?.toInt() ?? 0}',
                style: const TextStyle(color: AppColors.orange, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          // Admin Actions (only show if status is pending)
          if (status == 'pending') ...[
            Divider(color: borderColor, height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: OutlinedButton(
                      onPressed: () => onActionPressed('rejected'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Reject', style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () => onActionPressed('approved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Approve', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
