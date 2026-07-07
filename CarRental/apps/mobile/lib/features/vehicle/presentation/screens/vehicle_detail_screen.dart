import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/toast_notification.dart';
import '../../../../core/repositories/fleet_repository.dart';
import '../../../../core/providers/app_state_provider.dart';
import 'package:luxury_car_rental/features/booking/presentation/booking_modal.dart';
import '../../../../core/models/vehicle.dart';

class VehicleDetailScreen extends ConsumerStatefulWidget {
  final String slug;

  const VehicleDetailScreen({
    super.key,
    required this.slug,
  });

  @override
  ConsumerState<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends ConsumerState<VehicleDetailScreen> {
  int _currentImageIndex = 0;
  late VehicleColor _selectedColor;

  @override
  void initState() {
    super.initState();
    
    final vehicle = FleetRepository.fleetData.firstWhere(
      (v) => v.slug == widget.slug,
      orElse: () => FleetRepository.fleetData.first,
    );
    _selectedColor = vehicle.colors.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appStateProvider.notifier).addRecentlyViewed(vehicle.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Find vehicle by slug
    final vehicle = FleetRepository.fleetData.firstWhere(
      (v) => v.slug == widget.slug,
      orElse: () => FleetRepository.fleetData.first,
    );

    final appState = ref.watch(appStateProvider);
    final appNotifier = ref.read(appStateProvider.notifier);
    final isFav = appState.wishlist.contains(vehicle.id);

    // Mock images list for PageView
    final galleryImages = [
      vehicle.images.thumbnail,
      vehicle.images.thumbnail, // Replicate for swipe mock
    ];

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Stack(
        children: [
          // ── Scrollable detail page ──
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Swipe-based Image Gallery ──
                Stack(
                  children: [
                    SizedBox(
                      height: 320,
                      child: PageView.builder(
                        itemCount: galleryImages.length,
                        onPageChanged: (idx) {
                          setState(() {
                            _currentImageIndex = idx;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Hero(
                            tag: index == 0 ? 'hero-vehicle-${vehicle.id}' : 'gallery-vehicle-$index',
                            child: CachedNetworkImage(
                              imageUrl: galleryImages[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        },
                      ),
                    ),
                    // Back button & Wishlist floaters
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          child: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      right: 16,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          appNotifier.toggleWishlist(vehicle.id);
                          ToastNotification.show(
                            context,
                            isFav ? 'Removed ${vehicle.name} from wishlist' : 'Added ${vehicle.name} to wishlist',
                            type: isFav ? 'info' : 'success',
                          );
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? AppColors.danger : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Dot indicators
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          galleryImages.length,
                          (index) => Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 3.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index ? AppColors.amber : Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name & Tagline Block
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              vehicle.category.toUpperCase(),
                              style: AppTypography.monoBold(color: AppColors.amber, size: 8),
                            ),
                          ),
                          if (vehicle.badge != null)
                            Text(
                              vehicle.badge!,
                              style: AppTypography.monoStyle(color: AppColors.inkMuted, size: 8),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vehicle.name,
                        style: AppTypography.displayMedium(color: AppColors.ink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.tagline,
                        style: AppTypography.bodyLarge(color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Compact Info Cards Row (At a glance specifications) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickSpecCard(Icons.speed_outlined, '0-60 MPH', vehicle.specs.zeroToSixty ?? 'N/A'),
                        _buildQuickSpecCard(Icons.airline_seat_recline_normal, 'SEATS', '${vehicle.specs.seats}'),
                        _buildQuickSpecCard(Icons.settings_outlined, 'TRANS', vehicle.specs.transmission),
                        if (vehicle.specs.range != null)
                          _buildQuickSpecCard(Icons.ev_station_outlined, 'RANGE', vehicle.specs.range!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Finish Color Swatches Selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CHOOSE FINISH — ${_selectedColor.name.toUpperCase()}',
                        style: AppTypography.eyebrow(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: vehicle.colors.map((color) {
                          final active = _selectedColor.name == color.name;
                          final hexColor = Color(int.parse(color.hex.replaceAll('#', '0xFF')));

                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _selectedColor = color;
                                });
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: hexColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: active ? AppColors.amber : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Expandable description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('EXPERIENCE', style: AppTypography.eyebrow()),
                      const SizedBox(height: 8),
                      Text(
                        'Drive one of the world\'s finest engineered machinery. Complete with customized active exhausts, smart navigation support, and SAFRA concierge assistance available 24/7.',
                        style: AppTypography.bodyMedium(color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Specs Bottom Sheet Trigger button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CustomButton.ghost(
                    text: 'View Full Specifications',
                    width: double.infinity,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showSpecsBottomSheet(context, vehicle);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Persistent Sticky Bottom Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 14.0,
                bottom: MediaQuery.of(context).padding.bottom + 14.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.panel,
                border: const Border(top: BorderSide(color: AppColors.border, width: 1.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'AED ${vehicle.pricePerDay.toInt()}',
                        style: AppTypography.headingLarge(color: AppColors.ink).copyWith(fontSize: 24),
                      ),
                      Text(
                        'per day rate',
                        style: AppTypography.bodySmall(),
                      ),
                    ],
                  ),
                  CustomButton.amber(
                    text: 'Reserve Now',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => BookingModal(vehicleName: vehicle.name),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSpecCard(IconData icon, String label, String val) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.panel,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.amber, size: 18),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.monoStyle(color: AppColors.inkSubtle, size: 7),
          ),
          const SizedBox(height: 2),
          Text(
            val,
            style: AppTypography.monoBold(color: AppColors.ink, size: 9),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── FULL SPECIFICATIONS BOTTOM SHEET ──
  void _showSpecsBottomSheet(BuildContext context, dynamic vehicle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TECHNICAL SPECIFICATIONS', style: AppTypography.eyebrow()),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    if (vehicle.specs.engine != null)
                      _buildSpecRow('Engine', vehicle.specs.engine!),
                    if (vehicle.specs.power != null)
                      _buildSpecRow('Power', vehicle.specs.power!),
                    if (vehicle.specs.torque != null)
                      _buildSpecRow('Torque', vehicle.specs.torque!),
                    if (vehicle.specs.zeroToSixty != null)
                      _buildSpecRow('0-60 MPH', vehicle.specs.zeroToSixty!),
                    if (vehicle.specs.topSpeed != null)
                      _buildSpecRow('Top Speed', vehicle.specs.topSpeed!),
                    if (vehicle.specs.range != null)
                      _buildSpecRow('Range (EV)', vehicle.specs.range!),
                    _buildSpecRow('Seats Count', '${vehicle.specs.seats} seats'),
                    _buildSpecRow('Transmission', vehicle.specs.transmission.toUpperCase()),
                    _buildSpecRow('Fuel Type', vehicle.specs.fuel.toUpperCase()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecRow(String key, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key.toUpperCase(),
            style: AppTypography.monoStyle(color: AppColors.inkMuted, size: 8),
          ),
          Text(
            val,
            style: AppTypography.monoBold(color: AppColors.ink, size: 10),
          ),
        ],
      ),
    );
  }
}
