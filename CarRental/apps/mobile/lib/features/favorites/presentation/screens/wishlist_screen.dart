import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/shimmer_card.dart';
import '../../../../core/widgets/toast_notification.dart';
import '../../../../core/repositories/fleet_repository.dart';
import '../../../../core/providers/app_state_provider.dart';
import 'package:luxury_car_rental/features/booking/presentation/booking_modal.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);

    // Retrieve favorited vehicles
    final vehicles = FleetRepository.fleetData.where((v) => appState.wishlist.contains(v.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('My Wishlist'),
      ),
      body: vehicles.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ShimmerCard(
                    onTap: () => context.push('/fleet/vehicle/${vehicle.slug}'),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: CachedNetworkImage(
                              imageUrl: vehicle.images.thumbnail,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.paperSoft,
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Text & Button detail fields
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        vehicle.name,
                                        style: AppTypography.headingSmall(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        notifier.toggleWishlist(vehicle.id);
                                        ToastNotification.show(
                                          context,
                                          'Removed ${vehicle.name} from wishlist',
                                          type: 'info',
                                        );
                                      },
                                      child: const Icon(
                                        Icons.favorite_rounded,
                                        color: AppColors.danger,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vehicle.tagline,
                                  style: AppTypography.bodySmall(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'AED ${vehicle.pricePerDay.toInt()}',
                                          style: AppTypography.headingSmall(color: AppColors.amber),
                                        ),
                                        Text(
                                          '/day',
                                          style: AppTypography.bodySmall(),
                                        ),
                                      ],
                                    ),
                                    CustomButton.amber(
                                      text: 'Book Now',
                                      height: 32.0,
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) => BookingModal(vehicleName: vehicle.name),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.inkSubtle),
            const SizedBox(height: 16),
            Text(
              'No vehicles in wishlist.',
              style: AppTypography.headingMedium(color: AppColors.inkMuted),
            ),
            const SizedBox(height: 16),
            CustomButton.amber(
              text: 'Browse Vehicles',
              onPressed: () => context.go('/fleet'),
            ),
          ],
        ),
      ),
    );
  }
}
