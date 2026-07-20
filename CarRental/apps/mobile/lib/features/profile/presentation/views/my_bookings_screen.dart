import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/theme_toggle_button.dart';
import '../../../home/data/repositories/home_repository.dart';
import '../../../home/data/models/home_models.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/models/profile_models.dart';

final bookingsWithImagesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final profileRepo = ref.read(profileRepositoryProvider);
  final homeRepo = ref.read(homeRepositoryProvider);

  final results = await Future.wait([
    profileRepo.fetchBookings(),
    homeRepo.fetchAllVehicles(),
  ]);

  final bookings = results[0] as List<BookingModel>;
  final vehicles = results[1] as List<VehicleModel>;

  return bookings.map((b) {
    // Find matching vehicle to extract image URL
    final vehicleMatch = vehicles.firstWhere(
      (v) => v.id == b.vehicleId,
      orElse: () => vehicles.first,
    );
    return {
      'booking': b,
      'imageUrl': vehicleMatch.primaryImage,
    };
  }).toList();
});

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsWithImagesProvider);
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
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Bookings',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(bookingsWithImagesProvider.future),
        color: AppColors.orange,
        child: bookingsAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded, size: 48, color: textMuted),
                        const SizedBox(height: 16),
                        Text(
                          'No Booking History Found',
                          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Browse our fleet to make your first booking.',
                          style: TextStyle(color: textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = list[index];
                final booking = item['booking'] as BookingModel;
                final imageUrl = item['imageUrl'] as String;

                final startFmt = booking.startDate != null
                    ? DateFormat('dd MMM').format(booking.startDate!)
                    : 'N/A';
                final endFmt = booking.endDate != null
                    ? DateFormat('dd MMM yyyy').format(booking.endDate!)
                    : 'N/A';

                return _BookingCard(
                  booking: booking,
                  imageUrl: imageUrl,
                  startFmt: startFmt,
                  endFmt: endFmt,
                  isDark: isDark,
                  surface2: surface2,
                  textColor: textColor,
                  textMuted: textMuted,
                  borderColor: borderColor,
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.orange)),
          error: (err, stack) => Center(
            child: Text('Failed to load bookings: $err', style: const TextStyle(color: AppColors.error)),
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.imageUrl,
    required this.startFmt,
    required this.endFmt,
    required this.isDark,
    required this.surface2,
    required this.textColor,
    required this.textMuted,
    required this.borderColor,
  });

  final BookingModel booking;
  final String imageUrl;
  final String startFmt;
  final String endFmt;
  final bool isDark;
  final Color surface2;
  final Color textColor;
  final Color textMuted;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final status = booking.status.toLowerCase();
    
    // Status style resolution
    Color statusColor = AppColors.orange;
    Color statusBg = AppColors.orange.withValues(alpha: 0.1);
    if (status == 'completed' || status == 'approved') {
      statusColor = AppColors.success;
      statusBg = AppColors.success.withValues(alpha: 0.1);
    } else if (status == 'cancelled' || status == 'rejected') {
      statusColor = AppColors.error;
      statusBg = AppColors.error.withValues(alpha: 0.1);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 40,
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(Icons.directions_car_rounded, color: AppColors.orange),
                        )
                      : const Icon(Icons.directions_car_rounded, color: AppColors.orange),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.vehicle?.name ?? 'Premium Car',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$startFmt – $endFmt',
                      style: TextStyle(color: textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: borderColor, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Price', style: TextStyle(color: textMuted, fontSize: 12)),
              Text(
                'AED ${booking.totalPrice?.toInt() ?? 0}',
                style: TextStyle(
                  color: AppColors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
