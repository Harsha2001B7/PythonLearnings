import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/theme_toggle_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/home_controller.dart';
import '../../data/models/home_models.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/app_router.dart';
import '../../../profile/data/models/profile_models.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../../profile/presentation/views/my_bookings_screen.dart';

final userBookingsProvider = FutureProvider.autoDispose<List<BookingModel>>((ref) async {
  final repo = ref.read(profileRepositoryProvider);
  return repo.fetchBookings();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final surface2 = isDark ? AppColors.surface2Dark : AppColors.surface2Light;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    // Greeting
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    final firstName = user?.firstName2 ?? 'there';

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Sticky header ──────────────────────────────────
            _HomeHeader(
              greeting: greeting,
              firstName: firstName,
              user: user,
              isDark: isDark,
              surface: surface,
              surface2: surface2,
              textColor: textColor,
              textMuted: textMuted,
              borderColor: borderColor,
            ),

            // ─── Scrollable content ─────────────────────────────
            Expanded(
              child: switch (homeState) {
                HomeLoading() => _buildShimmer(isDark),
                HomeError(:final message) => _buildError(message, ref, isDark, textMuted),
                HomeLoaded(:final data, :final offers) => RefreshIndicator(
                    color: AppColors.orange,
                    onRefresh: () => ref.read(homeControllerProvider.notifier).fetch(silent: true),
                    child: _HomeContent(
                      data: data,
                      offers: offers,
                      isDark: isDark,
                      surface: surface,
                      surface2: surface2,
                      textColor: textColor,
                      textMuted: textMuted,
                      borderColor: borderColor,
                    ),
                  ),
                _ => const SizedBox.shrink(),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    final baseColor = isDark ? AppColors.surface2Dark : AppColors.surface2Light;
    final highlightColor = isDark ? AppColors.surface3Dark : AppColors.surface3Light;
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: List.generate(
            5,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message, WidgetRef ref, bool isDark, Color textMuted) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.orange),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: textMuted, fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(homeControllerProvider.notifier).fetch(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sticky Header ─────────────────────────────────────────────────────────────
class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({
    required this.greeting,
    required this.firstName,
    required this.user,
    required this.isDark,
    required this.surface,
    required this.surface2,
    required this.textColor,
    required this.textMuted,
    required this.borderColor,
  });

  final String greeting;
  final String firstName;
  final dynamic user;
  final bool isDark;
  final Color surface;
  final Color surface2;
  final Color textColor;
  final Color textMuted;
  final Color borderColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final u = authState is AuthAuthenticated ? authState.user : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: surface,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          // User greeting row
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: surface2,
                ),
                clipBehavior: Clip.antiAlias,
                child: u?.avatar != null && u!.avatar!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: u.avatar!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => _avatarFallback(u.firstName2),
                      )
                    : _avatarFallback(u?.firstName2 ?? '?'),
              ),
              const SizedBox(width: 10),

              // Greeting text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(text: u?.firstName2 ?? firstName),
                          const TextSpan(text: ' 👋'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Theme toggle
              const ThemeToggleButton(),
              const SizedBox(width: 4),

              // Notification bell
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: surface2,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_rounded,
                      size: 22,
                      color: textColor,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: surface, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search bar
          GestureDetector(
            onTap: () => context.push(AppRoute.search),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface2Dark : AppColors.surface2Light,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search_rounded, size: 22, color: textMuted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      enabled: false, // Prevents keyboard from sliding up, relies on gesture
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search by car, brand or category...',
                        hintStyle: TextStyle(color: textMuted, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoute.fleet),
                    child: Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.only(right: 7),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.tune_rounded, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(String? name) => Center(
        child: Text(
          (name?.isNotEmpty == true) ? name![0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppColors.orange,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      );
}

// ─── Scrollable Home Content ──────────────────────────────────────────────────
class _HomeContent extends ConsumerWidget {
  const _HomeContent({
    required this.data,
    required this.offers,
    required this.isDark,
    required this.surface,
    required this.surface2,
    required this.textColor,
    required this.textMuted,
    required this.borderColor,
  });

  final HomeData data;
  final List<OfferModel> offers;
  final bool isDark;
  final Color surface;
  final Color surface2;
  final Color textColor;
  final Color textMuted;
  final Color borderColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(userBookingsProvider);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ─── Promo Banner ─────────────────────────────────
        _PromoBanner(
          offer: offers.isNotEmpty ? offers.first : null,
          isDark: isDark,
          surface: surface,
          surface2: surface2,
          textColor: textColor,
          textMuted: textMuted,
          borderColor: borderColor,
        ),

        // ─── Browse by Brand ──────────────────────────────
        if (data.brands.isNotEmpty) ...[
          _SectionHeader(
            title: 'Browse by Brand',
            actionLabel: 'See All',
            onAction: () {},
            textColor: textColor,
          ),
          _BrandsRow(
            brands: data.brands,
            isDark: isDark,
            surface2: surface2,
            borderColor: borderColor,
            textMuted: textMuted,
          ),
        ],

        // ─── Featured Fleet ────────────────────────────────
        if (data.featuredVehicles.isNotEmpty) ...[
          const SizedBox(height: 4),
          _SectionHeader(
            title: 'Featured Fleet',
            actionLabel: 'View All',
            onAction: () {},
            textColor: textColor,
          ),
          _FeaturedFleetRow(
            vehicles: data.featuredVehicles,
            isDark: isDark,
            surface: surface,
            textColor: textColor,
            textMuted: textMuted,
            borderColor: borderColor,
          ),
        ],

        // ─── Recent Booking ───────────────────────────────
        bookingsAsync.when(
          data: (bookings) {
            final recentBooking = bookings.isNotEmpty ? bookings.first : null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: 'Recent Booking',
                  actionLabel: bookings.isNotEmpty ? 'History' : '',
                  onAction: () {
                    if (bookings.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyBookingsScreen(),
                        ),
                      );
                    }
                  },
                  textColor: textColor,
                ),
                _RecentBookingCard(
                  booking: recentBooking,
                  isDark: isDark,
                  surface2: surface2,
                  textColor: textColor,
                  textMuted: textMuted,
                  borderColor: borderColor,
                  vehicles: data.featuredVehicles,
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(color: AppColors.orange)),
          ),
          error: (err, stack) => const SizedBox(),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Promo Banner ─────────────────────────────────────────────────────────────
class _PromoBanner extends StatelessWidget {
  const _PromoBanner({
    required this.offer,
    required this.isDark,
    required this.surface,
    required this.surface2,
    required this.textColor,
    required this.textMuted,
    required this.borderColor,
  });

  final OfferModel? offer;
  final bool isDark;
  final Color surface;
  final Color surface2;
  final Color textColor;
  final Color textMuted;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    // Use offer data from backend, or show default promo
    final title = offer?.title ?? 'First Rental 15% Off';
    final code = 'FALCON15';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              isDark ? AppColors.surface2Dark : AppColors.surface2Light,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.orange.withValues(alpha: 0.08),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SPECIAL OFFER',
                        style: TextStyle(
                          color: AppColors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: textMuted, fontSize: 12),
                          children: [
                            const TextSpan(text: 'Use code '),
                            TextSpan(
                              text: code,
                              style: const TextStyle(
                                color: AppColors.orange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(72, 40),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Claim',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    required this.textColor,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: const Text(
              'See All',
              style: TextStyle(
                color: AppColors.orange,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Brands Row ───────────────────────────────────────────────────────────────
class _BrandsRow extends StatelessWidget {
  const _BrandsRow({
    required this.brands,
    required this.isDark,
    required this.surface2,
    required this.borderColor,
    required this.textMuted,
  });

  final List<BrandModel> brands;
  final bool isDark;
  final Color surface2;
  final Color borderColor;
  final Color textMuted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: brands.length,
        separatorBuilder: (_, a) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final brand = brands[index];
          return _BrandTile(
            brand: brand,
            surface2: surface2,
            borderColor: borderColor,
            textMuted: textMuted,
          );
        },
      ),
    );
  }
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({
    required this.brand,
    required this.surface2,
    required this.borderColor,
    required this.textMuted,
  });

  final BrandModel brand;
  final Color surface2;
  final Color borderColor;
  final Color textMuted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/fleet?brand=${Uri.encodeComponent(brand.name)}'),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: brand.logoUrl != null && brand.logoUrl!.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: CachedNetworkImage(
                      imageUrl: brand.logoUrl!,
                      fit: BoxFit.contain,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.directions_car_rounded,
                        size: 28,
                        color: AppColors.textMutedDark,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.directions_car_rounded,
                    size: 28,
                    color: AppColors.textMutedDark,
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            brand.name,
            style: TextStyle(
              color: textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Featured Fleet Row ───────────────────────────────────────────────────────
class _FeaturedFleetRow extends StatelessWidget {
  const _FeaturedFleetRow({
    required this.vehicles,
    required this.isDark,
    required this.surface,
    required this.textColor,
    required this.textMuted,
    required this.borderColor,
  });

  final List<VehicleModel> vehicles;
  final bool isDark;
  final Color surface;
  final Color textColor;
  final Color textMuted;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 310,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        itemCount: vehicles.length,
        separatorBuilder: (_, a) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          return _VehicleCard(
            vehicle: vehicles[i],
            surface: surface,
            textColor: textColor,
            textMuted: textMuted,
            borderColor: borderColor,
          );
        },
      ),
    );
  }
}

class _VehicleCard extends StatefulWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.surface,
    required this.textColor,
    required this.textMuted,
    required this.borderColor,
  });

  final VehicleModel vehicle;
  final Color surface;
  final Color textColor;
  final Color textMuted;
  final Color borderColor;

  @override
  State<_VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<_VehicleCard> {
  bool _isFavourite = false;

  @override
  Widget build(BuildContext context) {
    final trans = widget.vehicle.transmission ?? 'Auto';
    final seats = widget.vehicle.seats ?? 5;
    final fuel = widget.vehicle.fuel ?? 'Petrol';
    final price = widget.vehicle.dailyPrice?.toInt() ?? 0;
    final rating = widget.vehicle.rating;

    return GestureDetector(
      onTap: () => context.push(AppRoute.vehicleDetail, extra: widget.vehicle),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: widget.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Image Stack ───────────────────────────────────────────────────
          Stack(
            children: [
              SizedBox(
                height: 120,
                width: double.infinity,
                child: widget.vehicle.primaryImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.vehicle.primaryImage,
                        fit: BoxFit.cover,
                        placeholder: (_, a) => Container(
                          color: AppColors.surface2Dark,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.orange),
                            ),
                          ),
                        ),
                        errorWidget: (_, a, b) => Container(
                          color: AppColors.surface2Dark,
                          child: const Center(
                            child: Icon(Icons.directions_car_rounded,
                                size: 40, color: AppColors.textMutedDark),
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.surface2Dark,
                        child: const Center(
                          child: Icon(Icons.directions_car_rounded,
                              size: 40, color: AppColors.textMutedDark),
                        ),
                      ),
              ),

              // Favourite heart button overlay
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFavourite = !_isFavourite;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 16,
                      color: _isFavourite ? AppColors.error : Colors.white,
                    ),
                  ),
                ),
              ),

              // Availability / Status overlay
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: widget.vehicle.available
                        ? AppColors.success.withValues(alpha: 0.85)
                        : AppColors.error.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    widget.vehicle.available ? 'Available' : 'Rented',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ─── Details Section ───────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating & Category Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                              const SizedBox(width: 2),
                              Text(
                                rating.toStringAsFixed(1),
                                style: TextStyle(
                                  color: widget.textColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (widget.vehicle.badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.vehicle.badge!.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.orange,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Vehicle Name
                      Text(
                        widget.vehicle.name,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),

                      // Specs (Seats · Trans · Fuel)
                      Text(
                        '$seats Seats · $trans · $fuel',
                        style: TextStyle(
                          color: widget.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  // Pricing & Book CTA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AED $price',
                            style: const TextStyle(
                              color: AppColors.orange,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '/day',
                            style: TextStyle(
                              color: widget.textMuted,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      // Book Button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Book',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

// ─── Recent Booking Card ──────────────────────────────────────────────────────
class _RecentBookingCard extends StatelessWidget {
  const _RecentBookingCard({
    required this.booking,
    required this.isDark,
    required this.surface2,
    required this.textColor,
    required this.textMuted,
    required this.borderColor,
    required this.vehicles,
  });

  final BookingModel? booking;
  final bool isDark;
  final Color surface2;
  final Color textColor;
  final Color textMuted;
  final Color borderColor;
  final List<VehicleModel> vehicles;

  @override
  Widget build(BuildContext context) {
    if (booking == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Icon(Icons.directions_car_rounded, size: 36, color: textMuted),
              const SizedBox(height: 12),
              Text(
                'No Bookings Yet',
                style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Explore our premium fleet and start your rental experience!',
                style: TextStyle(color: textMuted, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Dynamic data from booking
    final b = booking!;
    String? imageUrl;
    
    // Find matching vehicle to get primary image
    if (vehicles.isNotEmpty) {
      final match = vehicles.firstWhere(
        (v) => v.id == b.vehicleId,
        orElse: () => vehicles.first,
      );
      imageUrl = match.primaryImage;
    }

    final startFmt = b.startDate != null ? DateFormat('dd MMM').format(b.startDate!) : 'N/A';
    final endFmt = b.endDate != null ? DateFormat('dd MMM yyyy').format(b.endDate!) : 'N/A';
    final status = b.status.toLowerCase();

    Color statusColor = AppColors.orange;
    Color statusBg = AppColors.orange.withValues(alpha: 0.1);
    if (status == 'completed' || status == 'approved') {
      statusColor = AppColors.success;
      statusBg = AppColors.success.withValues(alpha: 0.1);
    } else if (status == 'cancelled' || status == 'rejected') {
      statusColor = AppColors.error;
      statusBg = AppColors.error.withValues(alpha: 0.1);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Container(
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
                Container(
                  width: 56,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface3Dark : AppColors.surface3Light,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(Icons.directions_car_rounded, color: AppColors.orange),
                        )
                      : const Icon(Icons.directions_car_rounded, color: AppColors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.vehicle?.name ?? 'Premium Car',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$startFmt – $endFmt',
                        style: TextStyle(color: textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    b.status.toUpperCase(),
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
                Text('Total Cost', style: TextStyle(color: textMuted, fontSize: 12)),
                Text(
                  'AED ${b.totalPrice?.toInt() ?? 0}',
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
      ),
    );
  }
}
