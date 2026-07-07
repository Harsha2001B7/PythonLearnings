import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/shimmer_card.dart';
import '../../../../core/widgets/toast_notification.dart';
import '../../../../core/repositories/fleet_repository.dart';
import '../../../../core/providers/filter_provider.dart';
import '../../../../core/providers/app_state_provider.dart';
import 'package:luxury_car_rental/features/booking/presentation/booking_modal.dart';
import '../compare_sheet.dart';

class FleetScreen extends ConsumerStatefulWidget {
  const FleetScreen({super.key});

  @override
  ConsumerState<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends ConsumerState<FleetScreen> {
  String _searchQuery = '';
  String _sortBy = 'price_low'; // 'price_low', 'price_high', 'name'

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 800));
    ref.read(filterProvider.notifier).resetFilters();
    setState(() {
      _searchQuery = '';
    });
    if (mounted) {
      ToastNotification.show(context, 'Fleet list refreshed.', type: 'info');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(filterProvider);
    final filterNotifier = ref.read(filterProvider.notifier);
    final appState = ref.watch(appStateProvider);
    final appStateNotifier = ref.read(appStateProvider.notifier);

    // Filter, search, and sort vehicles list
    final vehicles = FleetRepository.fleetData.where((v) {
      final matchesSearch = v.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.tagline.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = filters.category == 'all' || v.category == filters.category;
      final matchesPrice = v.pricePerDay <= filters.maxPrice;
      final matchesTrans = filters.transmission == 'all' || v.specs.transmission == filters.transmission;
      final matchesFuel = filters.fuel == 'all' || v.specs.fuel == filters.fuel;
      final matchesSeats = filters.seats == 'all' ||
          (filters.seats == '7+' ? v.specs.seats >= 7 : v.specs.seats == int.tryParse(filters.seats));

      return matchesSearch && matchesCategory && matchesPrice && matchesTrans && matchesFuel && matchesSeats;
    }).toList();

    // Sorting logic
    if (_sortBy == 'price_low') {
      vehicles.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
    } else if (_sortBy == 'price_high') {
      vehicles.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
    } else if (_sortBy == 'name') {
      vehicles.sort((a, b) => a.name.compareTo(b.name));
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Fleet Explorer'),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showSortOptions(context);
            },
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort Options',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search input field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search brand, model...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    fillColor: AppColors.panel,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),

              // Active filter preview tags row
              _buildActiveFiltersRow(filters, filterNotifier),

              // Grid results view
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: AppColors.amber,
                  backgroundColor: AppColors.panel,
                  child: vehicles.isEmpty
                      ? _buildEmptyState(filterNotifier)
                      : GridView.builder(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 80.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.74,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0,
                          ),
                          itemCount: vehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = vehicles[index];
                            final isFav = appState.wishlist.contains(vehicle.id);
                            final isCompare = appState.compareList.contains(vehicle.id);

                            return ShimmerCard(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.push('/fleet/vehicle/${vehicle.slug}');
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Thumbnail Image Stack with Hero transition
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Hero(
                                            tag: 'hero-vehicle-${vehicle.id}',
                                            child: CachedNetworkImage(
                                              imageUrl: vehicle.images.thumbnail,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        // Wishlist button
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: GestureDetector(
                                            onTap: () {
                                              HapticFeedback.mediumImpact();
                                              appStateNotifier.toggleWishlist(vehicle.id);
                                              ToastNotification.show(
                                                context,
                                                isFav
                                                    ? 'Removed ${vehicle.name} from wishlist'
                                                    : 'Added ${vehicle.name} to wishlist',
                                                type: isFav ? 'info' : 'success',
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(5),
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
                                  // Text details
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vehicle.name,
                                          style: AppTypography.headingSmall(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${vehicle.specs.seats} seats · ${vehicle.specs.transmission}',
                                          style: AppTypography.bodySmall(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'AED ${vehicle.pricePerDay.toInt()}/d',
                                              style: AppTypography.headingSmall(color: AppColors.amber),
                                            ),
                                            // Compare icon toggle
                                            GestureDetector(
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                final ok = appStateNotifier.toggleCompare(vehicle.id);
                                                if (!ok) {
                                                  ToastNotification.show(
                                                    context,
                                                    'Compare up to 3 vehicles at a time',
                                                    type: 'error',
                                                  );
                                                } else {
                                                  ToastNotification.show(
                                                    context,
                                                    isCompare ? 'Removed from comparison' : 'Added to comparison',
                                                    type: 'success',
                                                  );
                                                }
                                              },
                                              child: Icon(
                                                isCompare ? Icons.check_box_outlined : Icons.add_chart_outlined,
                                                color: isCompare ? AppColors.amber : AppColors.inkSubtle,
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        CustomButton.amber(
                                          text: 'Book',
                                          height: 28.0,
                                          width: double.infinity,
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
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),

          // Floating Filter FAB Trigger (Sticky center bottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: appState.compareList.isNotEmpty ? 70 : 16,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _showFilterBottomSheet(context);
                },
                backgroundColor: AppColors.amber,
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: Text('Filters', style: AppTypography.buttonText()),
              ),
            ),
          ),

          // Floating Compare Tray
          if (appState.compareList.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: GestureDetector(
                onTap: () {
                  appStateNotifier.setCompareOpen(true);
                  _openCompareSheet(context);
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.amber,
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.amber.withValues(alpha: 0.3),
                        blurRadius: 10.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bar_chart_outlined, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Comparing ${appState.compareList.length} vehicles',
                            style: AppTypography.buttonText(),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              appStateNotifier.clearCompare();
                            },
                            child: const Text('Clear', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── SORT OPTIONS SHEET ──
  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('SORT VEHICLES BY', style: AppTypography.eyebrow()),
              ),
              const Divider(),
              ListTile(
                title: Text('Price: Low to High', style: AppTypography.bodyLarge()),
                leading: Radio<String>(
                  value: 'price_low',
                  groupValue: _sortBy,
                  onChanged: (val) {
                    setState(() => _sortBy = val!);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: Text('Price: High to Low', style: AppTypography.bodyLarge()),
                leading: Radio<String>(
                  value: 'price_high',
                  groupValue: _sortBy,
                  onChanged: (val) {
                    setState(() => _sortBy = val!);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: Text('Name: Alphabetical', style: AppTypography.bodyLarge()),
                leading: Radio<String>(
                  value: 'name',
                  groupValue: _sortBy,
                  onChanged: (val) {
                    setState(() => _sortBy = val!);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── ACTIVE FILTERS ROW ──
  Widget _buildActiveFiltersRow(FilterState filters, FilterNotifier filterNotifier) {
    final List<Widget> chips = [];

    if (filters.category != 'all') {
      chips.add(_buildActiveFilterChip('Category: ${filters.category.toUpperCase()}', () {
        filterNotifier.setCategory('all');
      }));
    }
    if (filters.maxPrice < 2500) {
      chips.add(_buildActiveFilterChip('Price < AED ${filters.maxPrice.toInt()}', () {
        filterNotifier.setMaxPrice(2500);
      }));
    }
    if (filters.transmission != 'all') {
      chips.add(_buildActiveFilterChip('Trans: ${filters.transmission.toUpperCase()}', () {
        filterNotifier.setTransmission('all');
      }));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        children: chips,
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: Chip(
        label: Text(label, style: AppTypography.monoStyle(color: AppColors.amber, size: 8)),
        backgroundColor: AppColors.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        side: const BorderSide(color: AppColors.border),
        deleteIcon: const Icon(Icons.close, size: 10, color: AppColors.amber),
        onDeleted: onRemove,
      ),
    );
  }

  // ── BOTTOM SHEET FILTER PANEL ──
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final f = ref.watch(filterProvider);
            final fNotifier = ref.read(filterProvider.notifier);

            return Container(
              decoration: const BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              ),
              padding: EdgeInsets.only(
                top: 20.0,
                left: 16.0,
                right: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('FILTER SELECTION', style: AppTypography.eyebrow()),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          fNotifier.resetFilters();
                        },
                        child: Text('Reset All', style: TextStyle(color: AppColors.danger)),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Category Chips
                  Text('Category', style: AppTypography.headingSmall()),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6.0,
                    children: ['all', 'coupe', 'sedan', 'suv', 'ev', 'roadster'].map((cat) {
                      final active = f.category == cat;
                      return ChoiceChip(
                        label: Text(cat.toUpperCase()),
                        selected: active,
                        onSelected: (_) => fNotifier.setCategory(cat),
                        selectedColor: AppColors.amber,
                        backgroundColor: AppColors.paperSoft,
                        labelStyle: AppTypography.monoStyle(
                          color: active ? Colors.white : AppColors.inkMuted,
                          size: 8.0,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Price range
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Max Daily Price', style: AppTypography.headingSmall()),
                      Text('AED ${f.maxPrice.toInt()}/day', style: AppTypography.headingSmall(color: AppColors.amber)),
                    ],
                  ),
                  Slider(
                    min: 500,
                    max: 2500,
                    divisions: 20,
                    value: f.maxPrice,
                    activeColor: AppColors.amber,
                    inactiveColor: AppColors.border,
                    onChanged: (val) => fNotifier.setMaxPrice(val),
                  ),
                  const SizedBox(height: 16),

                  // Transmission Toggles
                  Text('Transmission', style: AppTypography.headingSmall()),
                  const SizedBox(height: 6),
                  Row(
                    children: ['all', 'automatic', 'manual'].map((trans) {
                      final active = f.transmission == trans;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(trans.toUpperCase()),
                          selected: active,
                          onSelected: (_) => fNotifier.setTransmission(trans),
                          selectedColor: AppColors.amber,
                          backgroundColor: AppColors.paperSoft,
                          labelStyle: AppTypography.monoStyle(
                            color: active ? Colors.white : AppColors.inkMuted,
                            size: 8.0,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton.amber(
                          text: 'Apply Filters',
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(FilterNotifier filterNotifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.car_rental_outlined, size: 64, color: AppColors.inkSubtle),
            const SizedBox(height: 16),
            Text(
              'No vehicles match your criteria.',
              style: AppTypography.headingMedium(color: AppColors.inkMuted),
            ),
            const SizedBox(height: 16),
            CustomButton.ghost(
              text: 'Reset Filters',
              onPressed: () => filterNotifier.resetFilters(),
            ),
          ],
        ),
      ),
    );
  }

  void _openCompareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CompareSheet(),
    );
  }
}
