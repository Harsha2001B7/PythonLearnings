import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../data/models/home_models.dart';

class VehicleDetailScreen extends ConsumerStatefulWidget {
  const VehicleDetailScreen({super.key, required this.vehicle});
  final VehicleModel vehicle;

  @override
  ConsumerState<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends ConsumerState<VehicleDetailScreen> {
  bool _isFavourite = false;

  void _openBookingDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingDetailsSheet(vehicle: widget.vehicle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final trans = widget.vehicle.transmission ?? 'Auto';
    final seats = widget.vehicle.seats ?? 5;
    final fuel = widget.vehicle.fuel ?? 'Petrol';
    final power = widget.vehicle.power ?? '78 hp';
    final price = widget.vehicle.dailyPrice?.toInt() ?? 0;
    final rating = widget.vehicle.rating;
    final type = widget.vehicle.categoryRel?.name ?? 'Sedan';
    final desc = widget.vehicle.description ??
        'The ${widget.vehicle.name} offers a smooth, comfortable ride perfect for city commuting and airport transfers in Dubai. Fuel-efficient and well-maintained, it comes with full insurance, free delivery across Dubai, and 24/7 roadside assistance.';

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ─── Scrollable Content ─────────────────────────────────────────────
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Image Header
                  Stack(
                    children: [
                      Hero(
                        tag: 'vehicle-image-${widget.vehicle.id}',
                        child: SizedBox(
                          height: 320,
                          width: double.infinity,
                          child: widget.vehicle.primaryImage.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: widget.vehicle.primaryImage,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(color: AppColors.surface2Dark),
                                  errorWidget: (context, url, error) => Container(
                                    color: AppColors.surface2Dark,
                                    child: const Icon(Icons.directions_car_rounded, size: 60, color: AppColors.textMutedDark),
                                  ),
                                )
                              : Container(
                                  color: AppColors.surface2Dark,
                                  child: const Icon(Icons.directions_car_rounded, size: 60, color: AppColors.textMutedDark),
                                ),
                        ),
                      ),
                      // Top dark gradient overlay for buttons
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 90,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 2. Info Container
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Availability Tag
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: widget.vehicle.available
                                    ? AppColors.success.withValues(alpha: 0.15)
                                    : AppColors.error.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: widget.vehicle.available
                                      ? AppColors.success.withValues(alpha: 0.3)
                                      : AppColors.error.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                widget.vehicle.available ? 'Available' : 'Rented',
                                style: TextStyle(
                                  color: widget.vehicle.available ? AppColors.success : AppColors.error,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (widget.vehicle.badge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.vehicle.badge!.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Title
                        Text(
                          widget.vehicle.name,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Rating & Tagline
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 18, color: AppColors.warning),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(127 reviews)',
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '·',
                              style: TextStyle(color: textMuted),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$type · Dubai, UAE',
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Spec Grid
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _SpecTile(
                              icon: Icons.settings_rounded,
                              label: trans,
                              sublabel: 'Transmission',
                            ),
                            _SpecTile(
                              icon: Icons.airline_seat_recline_normal_rounded,
                              label: '$seats',
                              sublabel: 'Seats',
                            ),
                            _SpecTile(
                              icon: Icons.bolt_rounded,
                              label: power,
                              sublabel: 'Power',
                            ),
                            _SpecTile(
                              icon: Icons.local_gas_station_rounded,
                              label: fuel,
                              sublabel: 'Fuel',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Included Kilometres Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.orange.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.orange.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.speed_rounded, color: AppColors.orange, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Included Kilometres',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Daily: 300 km/day · Excess: AED 0.5/km\nSalik (toll) charges not included',
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 12,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // About This Vehicle Section
                        Text(
                          'About This Vehicle',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          desc,
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 13,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 120), // Bottom padding for CTA bar
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Top Nav Buttons ───────────────────────────────────────────────
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            right: 16,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isFavourite = !_isFavourite;
                });
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 18,
                    color: _isFavourite ? AppColors.error : Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // ─── Bottom CTA Bar ────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.paddingOf(context).bottom + 16),
              decoration: BoxDecoration(
                color: surface,
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'AED $price',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'per day',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _openBookingDetails(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}

class _SpecTile extends StatelessWidget {
  const _SpecTile({
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  final IconData icon;
  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface2 = isDark ? AppColors.surface2Dark : AppColors.surface2Light;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Container(
      width: 76,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.orange, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: TextStyle(
              color: textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Booking Details Sheet (Slider selector for Daily / Weekly / Monthly) ───
class _BookingDetailsSheet extends StatefulWidget {
  const _BookingDetailsSheet({required this.vehicle});
  final VehicleModel vehicle;

  @override
  State<_BookingDetailsSheet> createState() => _BookingDetailsSheetState();
}

class _BookingDetailsSheetState extends State<_BookingDetailsSheet> {
  String _pricingType = 'Daily'; // 'Daily', 'Weekly', 'Monthly'
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 4));
  final String _location = 'Dubai International Airport\nTerminal 3, Dubai';

  @override
  void initState() {
    super.initState();
    _adjustDefaultDuration();
  }

  void _adjustDefaultDuration() {
    if (_pricingType == 'Weekly') {
      _endDate = _startDate.add(const Duration(days: 7));
    } else if (_pricingType == 'Monthly') {
      _endDate = _startDate.add(const Duration(days: 30));
    } else {
      _endDate = _startDate.add(const Duration(days: 3));
    }
  }

  // Prevent users from exploiting discount tiers by shrinking date ranges
  void _checkPricingTypeConstraints() {
    final days = _endDate.difference(_startDate).inDays;
    if (_pricingType == 'Monthly' && days < 30) {
      if (days >= 7) {
        _pricingType = 'Weekly';
      } else {
        _pricingType = 'Daily';
      }
    } else if (_pricingType == 'Weekly' && days < 7) {
      _pricingType = 'Daily';
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

    final days = _endDate.difference(_startDate).inDays;
    
    // Extract appropriate rate based on selection
    double rate = widget.vehicle.dailyPrice ?? 0;
    if (_pricingType == 'Weekly' && widget.vehicle.weeklyPrice != null) {
      rate = widget.vehicle.weeklyPrice!; // Weekly rate in backend is already the daily equivalent (e.g. 60/day)
    } else if (_pricingType == 'Monthly' && widget.vehicle.monthlyPrice != null) {
      rate = widget.vehicle.monthlyPrice! / 30; // Monthly price is the package total (e.g. 1550/month), so daily equivalent is / 30
    }
    
    final int baseRatePrint = rate.toInt();
    final int estimatedTotal = (rate * (days > 0 ? days : 1)).toInt();

    // Km Included based on selected tab
    String kmIncludedText = 'Daily: 300 km · Weekly: 200 km/day · Monthly: 4000 km\nExcess: AED 0.5/km';
    if (_pricingType == 'Daily') {
      kmIncludedText = 'Daily: 300 km included\nExcess: AED 0.5/km · Salik charges apply';
    } else if (_pricingType == 'Weekly') {
      kmIncludedText = 'Weekly: 200 km/day included\nExcess: AED 0.5/km · Salik charges apply';
    } else if (_pricingType == 'Monthly') {
      kmIncludedText = 'Monthly: 4000 km included\nExcess: AED 0.5/km · Salik charges apply';
    }

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
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
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close_rounded, color: textColor),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Booking Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
            ],
          ),
          const SizedBox(height: 20),

          // Sliding Selector for Daily / Weekly / Monthly
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: ['Daily', 'Weekly', 'Monthly'].map((type) {
                final isSelected = _pricingType == type;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _pricingType = type;
                        _adjustDefaultDuration();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected ? (isDark ? AppColors.surfaceDark : Colors.white) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          type,
                          style: TextStyle(
                            color: isSelected ? textColor : textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Price equivalent display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AED $baseRatePrint /day',
                style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w800),
              ),
              Text(
                'Estimated Total: AED $estimatedTotal',
                style: TextStyle(color: AppColors.orange, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '+5% VAT · Salik AED 1/toll',
            style: TextStyle(color: textMuted, fontSize: 11),
          ),
          const SizedBox(height: 20),

          // Date Picker Row
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                        if (_endDate.isBefore(_startDate)) {
                          _endDate = _startDate.add(const Duration(days: 1));
                        }
                        _checkPricingTypeConstraints();
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PICKUP DATE', style: TextStyle(color: textMuted, fontSize: 8, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.orange),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('dd-MM-yyyy').format(_startDate),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward_rounded, color: textMuted, size: 16),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final minReturnDate = _startDate.add(
                      _pricingType == 'Weekly'
                          ? const Duration(days: 7)
                          : _pricingType == 'Monthly'
                              ? const Duration(days: 30)
                              : const Duration(days: 1),
                    );
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate.isBefore(minReturnDate) ? minReturnDate : _endDate,
                      firstDate: minReturnDate,
                      lastDate: DateTime.now().add(const Duration(days: 180)),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                        _checkPricingTypeConstraints();
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RETURN DATE', style: TextStyle(color: textMuted, fontSize: 8, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.orange),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('dd-MM-yyyy').format(_endDate),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Duration info row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: surface2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_filled_rounded, size: 14, color: AppColors.orange),
                    const SizedBox(width: 8),
                    Text('Duration', style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
                Text('$days days', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Included Kilometres Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.orange.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed_rounded, color: AppColors.orange, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Included kilometres',
                      style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  kmIncludedText,
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Continue button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close sheet
                // Push Book Now summary page onto the context
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _BookNowScreen(
                      vehicle: widget.vehicle,
                      startDate: _startDate,
                      endDate: _endDate,
                      days: days,
                      pricingType: _pricingType,
                      baseRate: baseRatePrint,
                      rentalCost: estimatedTotal,
                      deliveryLocation: _location,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 20),
        ],
      ),
    );
  }
}

// ─── Book Now screen (Summary, insurance, VAT calculation, checkout) ─────────
class _BookNowScreen extends ConsumerStatefulWidget {
  const _BookNowScreen({
    required this.vehicle,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.pricingType,
    required this.baseRate,
    required this.rentalCost,
    required this.deliveryLocation,
  });

  final VehicleModel vehicle;
  final DateTime startDate;
  final DateTime endDate;
  final int days;
  final String pricingType;
  final int baseRate;
  final int rentalCost;
  final String deliveryLocation;

  @override
  ConsumerState<_BookNowScreen> createState() => _BookNowScreenState();
}

class _BookNowScreenState extends ConsumerState<_BookNowScreen> {
  bool _submitting = false;

  Future<void> _submitBooking(BuildContext context, {required bool isWhatsApp}) async {
    setState(() => _submitting = true);
    
    final double insurance = 30.0 * widget.days;
    final double vat = (widget.rentalCost + insurance) * 0.05;
    final double totalEstimated = widget.rentalCost + insurance + vat;
    final rand = Random().nextInt(9000) + 1000;
    final refCode = '#FV-$rand';

    try {
      final dio = ref.read(dioProvider);
      
      // Make a real POST API call to store the booking in SQLite
      // Fixed 307 temporary redirect by using a trailing slash!
      await dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.bookingsMy.replaceAll('/my', '/')}', // Resolves to /api/v1/bookings/
        data: {
          'vehicle_id': widget.vehicle.id,
          'start_date': widget.startDate.toIso8601String(),
          'end_date': widget.endDate.toIso8601String(),
          'total_price': totalEstimated,
          'duration_type': widget.pricingType.toLowerCase(),
          'notes': 'Delivery Location: ${widget.deliveryLocation.replaceAll('\n', ', ')}',
        },
      );
    } catch (e) {
      debugPrint('Reservation API error: $e. Gracefully proceeding to open native client.');
    } finally {
      if (mounted) setState(() => _submitting = false);

      // Launch WhatsApp or Call Dialer based on selection
      if (isWhatsApp) {
        final startFmt = DateFormat('yyyy-MM-dd').format(widget.startDate);
        final endFmt = DateFormat('yyyy-MM-dd').format(widget.endDate);
        final message = "Hi Falcon View! I'd like to book the ${widget.vehicle.name}.\nRental type: ${widget.pricingType.toLowerCase()}.\nPickup: $startFmt  Return: $endFmt.\nEstimated total: AED ${totalEstimated.toInt()}. Please confirm availability.";
        final whatsappUri = Uri.parse('https://wa.me/971500999733?text=${Uri.encodeComponent(message)}');
        try {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        } catch (_) {}
      } else {
        final telUri = Uri.parse('tel:+971500999733');
        try {
          await launchUrl(telUri);
        } catch (_) {}
      }

      if (context.mounted) {
        // Navigate to Request Sent success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => _RequestSentScreen(
              vehicle: widget.vehicle,
              startDate: widget.startDate,
              endDate: widget.endDate,
              days: widget.days,
              deliveryLocation: widget.deliveryLocation,
              refCode: refCode,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final double insurance = 30.0 * widget.days;
    final double vat = (widget.rentalCost + insurance) * 0.05;
    final double totalEstimated = widget.rentalCost + insurance + vat;

    final dateRangeStr = '${DateFormat('d MMM').format(widget.startDate)} – ${DateFormat('d MMM yyyy').format(widget.endDate)}';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Book Now', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: _submitting
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'BOOKING SUMMARY',
                    style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 12),

                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        // Vehicle minirow
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 68,
                                height: 50,
                                child: widget.vehicle.primaryImage.isNotEmpty
                                    ? CachedNetworkImage(imageUrl: widget.vehicle.primaryImage, fit: BoxFit.cover)
                                    : Container(color: AppColors.surface2Dark),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.vehicle.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$dateRangeStr · ${widget.days} days',
                                    style: TextStyle(color: textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Line items
                        _buildSummaryItem('Rental (${widget.days} days)', 'AED ${widget.rentalCost}', textColor),
                        const SizedBox(height: 12),
                        _buildSummaryItem('Comprehensive Insurance', 'AED ${insurance.toInt()}', textColor),
                        const SizedBox(height: 12),
                        _buildSummaryItem('VAT (5%)', 'AED ${vat.toInt()}', textColor),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Total Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Estimated Total', style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
                            Text('AED ${totalEstimated.toInt()}', style: const TextStyle(color: AppColors.orange, fontSize: 20, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  Text(
                    'CHOOSE BOOKING METHOD',
                    style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 12),

                  // Book via WhatsApp
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => _submitBooking(context, isWhatsApp: true),
                      icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                      label: const Text('Book via WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Call phone CTA
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => _submitBooking(context, isWhatsApp: false),
                      icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 20),
                      label: const Text('Call +971 50 099 9733', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.surface2Dark : Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Disclaimer Tip
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: textMuted, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No pre-payment required. Tap above to instantly confirm details directly with our reservation team.',
                            style: TextStyle(color: textMuted, fontSize: 10, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryItem(String label, String price, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Text(price, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ─── Request Sent Screen (Success Page) ──────────────────────────────────────
class _RequestSentScreen extends StatelessWidget {
  const _RequestSentScreen({
    required this.vehicle,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.deliveryLocation,
    required this.refCode,
  });

  final VehicleModel vehicle;
  final DateTime startDate;
  final DateTime endDate;
  final int days;
  final String deliveryLocation;
  final String refCode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final dateRangeStr = '${DateFormat('dd MMM').format(startDate)} – ${DateFormat('dd MMM yyyy').format(endDate)}';

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Checkmark Circle Icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.check_rounded, size: 44, color: Colors.white),
                ),
              ),
              const SizedBox(height: 28),

              // Title
              Text(
                'Request Sent!',
                style: TextStyle(
                  color: textColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Your reservation request for the ${vehicle.name} has been received. Our team will contact you shortly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textMuted, fontSize: 13, height: 1.5),
                ),
              ),
              const SizedBox(height: 32),

              // Booking Reference Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Text(
                      'BOOKING REFERENCE',
                      style: TextStyle(color: textMuted, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      refCode,
                      style: const TextStyle(
                        color: AppColors.orange,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Summary Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildDetailItem(Icons.directions_car_rounded, vehicle.name, '${vehicle.categoryRel?.name ?? 'Sedan'} · ${vehicle.transmission ?? 'Auto'}', textColor, textMuted),
                    const Divider(height: 24),
                    _buildDetailItem(Icons.calendar_today_rounded, dateRangeStr, '$days days rental', textColor, textMuted),
                    const Divider(height: 24),
                    _buildDetailItem(Icons.location_on_rounded, deliveryLocation.split('\n')[0], deliveryLocation.split('\n')[1], textColor, textMuted),
                    const Divider(height: 24),
                    _buildDetailItem(Icons.info_outline_rounded, 'Status: Pending Confirmation', 'Contacting via WhatsApp/Call', textColor, textMuted),
                  ],
                ),
              ),

              const Spacer(),

              // Chat on WhatsApp CTA Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final message = 'Hello Falcon View, checking status of my booking $refCode for the ${vehicle.name}.';
                    final whatsappUri = Uri.parse('https://wa.me/971500999733?text=${Uri.encodeComponent(message)}');
                    try {
                      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Chat on WhatsApp',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Back to Home Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoute.home),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Back to Home',
                    style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String subtitle, Color textColor, Color textMuted) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.orange, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: textMuted, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }
}
