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
import '../../../../core/providers/booking_provider.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/providers/filter_provider.dart';
import 'package:luxury_car_rental/features/booking/presentation/booking_modal.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final appStateNotifier = ref.read(appStateProvider.notifier);
    final filterNotifier = ref.read(filterProvider.notifier);
    final booking = ref.watch(bookingProvider);

    // Filter featured and nearby vehicles
    final featuredCars = FleetRepository.fleetData.where((v) => v.featured).toList();
    final nearbyCars = FleetRepository.fleetData.take(4).toList(); // Mock closest 4
    
    // Resolve recently viewed cars
    final recentlyViewedCars = appState.recentlyViewed
        .map((id) => FleetRepository.fleetData.firstWhere((v) => v.id == id))
        .toList();

    // Mock distances for nearby vehicles
    final mockDistances = ['0.8 km', '1.2 km', '2.5 km', '3.1 km'];

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Stack(
        children: [
          // ── Ambient Background Pattern ──
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.heroRadialGlow,
              ),
            ),
          ),
          const Positioned.fill(
            child: Opacity(
              opacity: 0.015,
              child: GridPaper(
                color: AppColors.amber,
                interval: 40.0,
                divisions: 1,
                subdivisions: 1,
              ),
            ),
          ),

          // ── Dashboard Content ──
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar / Branding
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SAFRA',
                            style: AppTypography.headingMedium(color: AppColors.ink).copyWith(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => context.go('/chat'),
                        icon: const Icon(Icons.support_agent_rounded, color: AppColors.amber),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Entry Point (Tapping directs to fleet tab)
                  GestureDetector(
                    onTap: () => context.go('/fleet'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        border: Border.all(color: AppColors.border, width: 1.5),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.amber, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search luxury fleet...',
                              style: AppTypography.bodyMedium(color: AppColors.inkSubtle),
                            ),
                          ),
                          const Icon(Icons.tune_rounded, color: AppColors.inkMuted, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Category chips
                  _buildPopularCategories(context, filterNotifier),
                  const SizedBox(height: 20),

                  // Continue Booking draft card
                  _buildContinueBookingCard(context, booking),
                  const SizedBox(height: 20),

                  // Nearby Vehicles (Uber style locator)
                  _buildNearbySection(context, nearbyCars, mockDistances, appState, appStateNotifier),
                  const SizedBox(height: 24),

                  // Recently Viewed (Airbnb style history)
                  if (recentlyViewedCars.isNotEmpty) ...[
                    _buildRecentlyViewedSection(context, recentlyViewedCars),
                    const SizedBox(height: 24),
                  ],

                  // Featured Fleet Section
                  _buildFeaturedSection(context, featuredCars, appState, appStateNotifier),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── POPULAR CATEGORY CHIPS ──
  Widget _buildPopularCategories(BuildContext context, FilterNotifier filterNotifier) {
    final categories = ['SUV', 'EV', 'COUPE', 'SEDAN', 'ROADSTER'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('POPULAR CATEGORIES', style: AppTypography.eyebrow()),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () {
                    filterNotifier.setCategory(cat.toLowerCase());
                    context.go('/fleet');
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.panel,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: AppTypography.monoBold(color: AppColors.inkMuted, size: 8),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── DRAFT BOOKING CONTINUATION CARD ──
  Widget _buildContinueBookingCard(BuildContext context, BookingState booking) {
    return ShimmerCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_month_outlined, color: AppColors.amber, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CONTINUE RESERVATION', style: AppTypography.eyebrow()),
                  const SizedBox(height: 4),
                  Text(
                    '${booking.pickup.split(' — ').last} · ${booking.pickupDate}',
                    style: AppTypography.headingSmall(),
                  ),
                ],
              ),
            ),
            CustomButton.amber(
              text: 'Book',
              height: 32.0,
              onPressed: () => context.go('/fleet'),
            ),
          ],
        ),
      ),
    );
  }

  // ── NEARBY VEHICLES LOCATOR ──
  Widget _buildNearbySection(BuildContext context, List<dynamic> cars, List<String> distances, AppState appState, AppStateNotifier appStateNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AVAILABLE NEARBY', style: AppTypography.eyebrow()),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              final dist = distances[index];

              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 12.0),
                child: ShimmerCard(
                  onTap: () => context.push('/fleet/vehicle/${car.slug}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail with mock distance indicator
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CachedNetworkImage(
                                imageUrl: car.images.thumbnail,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on, color: AppColors.amber, size: 10),
                                    const SizedBox(width: 2),
                                    Text(
                                      dist,
                                      style: AppTypography.monoBold(color: Colors.white, size: 7),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Text block
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    car.name,
                                    style: AppTypography.headingSmall(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'AED ${car.pricePerDay.toInt()}/day',
                                    style: AppTypography.monoBold(color: AppColors.amber, size: 8),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.inkSubtle),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── RECENTLY VIEWED HISTORY ──
  Widget _buildRecentlyViewedSection(BuildContext context, List<dynamic> cars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RECENTLY VIEWED', style: AppTypography.eyebrow()),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];

              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: ShimmerCard(
                  onTap: () => context.push('/fleet/vehicle/${car.slug}'),
                  child: Container(
                    width: 260,
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: car.images.thumbnail,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                car.name,
                                style: AppTypography.headingSmall(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                car.tagline,
                                style: AppTypography.bodySmall(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'AED ${car.pricePerDay.toInt()}/day',
                                style: AppTypography.monoBold(color: AppColors.amber, size: 8),
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
        ),
      ],
    );
  }

  // ── FEATURED VEHICLES CAROUSEL ──
  Widget _buildFeaturedSection(BuildContext context, List<dynamic> cars, AppState appState, AppStateNotifier appStateNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FEATURED MODELS', style: AppTypography.eyebrow()),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              final isFav = appState.wishlist.contains(car.id);

              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12.0),
                child: ShimmerCard(
                  onTap: () => context.push('/fleet/vehicle/${car.slug}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CachedNetworkImage(
                                imageUrl: car.images.thumbnail,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Wishlist Toggle
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  appStateNotifier.toggleWishlist(car.id);
                                  ToastNotification.show(
                                    context,
                                    isFav ? 'Removed from wishlist' : 'Added to wishlist',
                                    type: isFav ? 'info' : 'success',
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    color: isFav ? AppColors.danger : AppColors.inkMuted,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Text block
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.name,
                              style: AppTypography.headingSmall(),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'AED ${car.pricePerDay.toInt()}/day',
                                  style: AppTypography.monoBold(color: AppColors.amber, size: 8),
                                ),
                                CustomButton.amber(
                                  text: 'Reserve',
                                  height: 28.0,
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) => BookingModal(vehicleName: car.name),
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
              );
            },
          ),
        ),
      ],
    );
  }
}
