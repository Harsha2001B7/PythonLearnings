import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/theme_toggle_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/models/home_models.dart';

// ─── Filter Model Class ──────────────────────────────────────────────────────
class VehicleFilter {
  double minPrice = 50;
  double maxPrice = 500;
  String selectedCategory = 'All'; // 'All', 'Sedan', 'Hatchback', 'SUV', etc.
  String selectedTrans = 'All';    // 'All', 'Automatic', 'Manual'
  String selectedBrand = 'All';

  void reset() {
    minPrice = 50;
    maxPrice = 500;
    selectedCategory = 'All';
    selectedTrans = 'All';
    selectedBrand = 'All';
  }
}

// ─── Search tab (Real screen instead of Placeholder) ─────────────────────────
class SearchPlaceholderScreen extends ConsumerStatefulWidget {
  const SearchPlaceholderScreen({super.key});

  @override
  ConsumerState<SearchPlaceholderScreen> createState() => _SearchPlaceholderScreenState();
}

class _SearchPlaceholderScreenState extends ConsumerState<SearchPlaceholderScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<VehicleModel> _allVehicles = [];
  List<VehicleModel> _filteredVehicles = [];
  List<VehicleModel> _suggestions = [];
  bool _isLoading = true;
  final List<String> _recentSearches = ['Mitsubishi Attrage', 'Nissan Sunny', 'MG3'];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    final list = await ref.read(homeRepositoryProvider).fetchAllVehicles();
    if (!mounted) return;
    setState(() {
      _allVehicles = list;
      _suggestions = list.take(2).toList();
      _isLoading = false;
    });
  }

  void _onSearchChanged(String text) {
    if (text.trim().isEmpty) {
      setState(() {
        _filteredVehicles = [];
      });
      return;
    }
    final query = text.toLowerCase();
    setState(() {
      _filteredVehicles = _allVehicles.where((v) {
        return v.name.toLowerCase().contains(query) ||
            (v.categoryRel?.name ?? '').toLowerCase().contains(query) ||
            (v.brandRel?.name ?? '').toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Search Vehicles', style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Search field Row
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: surface2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: _onSearchChanged,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search brand, name or category...',
                              hintStyle: TextStyle(color: textMuted, fontSize: 13),
                              prefixIcon: Icon(Icons.search_rounded, color: textMuted, size: 20),
                              suffixIcon: _searchCtrl.text.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        _searchCtrl.clear();
                                        _onSearchChanged('');
                                      },
                                      child: Icon(Icons.clear_rounded, color: textMuted, size: 20),
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      if (_searchCtrl.text.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            _onSearchChanged('');
                            FocusScope.of(context).unfocus();
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. Recent search chips
                        if (_searchCtrl.text.isEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Text(
                              'RECENT',
                              style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Wrap(
                              spacing: 8,
                              children: _recentSearches.map((tag) {
                                return ActionChip(
                                  onPressed: () {
                                    _searchCtrl.text = tag;
                                    _onSearchChanged(tag);
                                  },
                                  label: Text(tag, style: TextStyle(color: textColor, fontSize: 12)),
                                  backgroundColor: surface2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                  side: BorderSide(color: borderColor),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Suggestions - "You May Also Like"
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Text(
                              'YOU MAY ALSO LIKE',
                              style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _suggestions.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, idx) {
                              return _SmallVehicleRowCard(
                                vehicle: _suggestions[idx],
                                isDark: isDark,
                                surface2: surface2,
                                textColor: textColor,
                                textMuted: textMuted,
                                borderColor: borderColor,
                              );
                            },
                          ),
                        ] else ...[
                          // 3. Search Results list
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Text(
                              '${_filteredVehicles.length} RESULTS FOR "${_searchCtrl.text.toUpperCase()}"',
                              style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ),
                          if (_filteredVehicles.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Text('No vehicles match your search.', style: TextStyle(color: textMuted, fontSize: 14)),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _filteredVehicles.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, idx) {
                                return _SmallVehicleRowCard(
                                  vehicle: _filteredVehicles[idx],
                                  isDark: isDark,
                                  surface2: surface2,
                                  textColor: textColor,
                                  textMuted: textMuted,
                                  borderColor: borderColor,
                                );
                              },
                            ),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Fleet tab (Real screen instead of Placeholder) ──────────────────────────
class FleetPlaceholderScreen extends ConsumerStatefulWidget {
  const FleetPlaceholderScreen({super.key, this.preselectedBrand});
  final String? preselectedBrand;

  @override
  ConsumerState<FleetPlaceholderScreen> createState() => _FleetPlaceholderScreenState();
}

class _FleetPlaceholderScreenState extends ConsumerState<FleetPlaceholderScreen> {
  List<VehicleModel> _allVehicles = [];
  List<VehicleModel> _displayedVehicles = [];
  List<CategoryModel> _categories = [];
  List<BrandModel> _brands = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  bool _sortAscending = true; // sort by price

  // Filters State
  final VehicleFilter _filter = VehicleFilter();

  @override
  void initState() {
    super.initState();
    if (widget.preselectedBrand != null) {
      _filter.selectedBrand = widget.preselectedBrand!;
    }
    _loadFleet();
  }

  Future<void> _loadFleet() async {
    final repo = ref.read(homeRepositoryProvider);
    final results = await Future.wait([
      repo.fetchAllVehicles(),
      repo.fetchHomeData(), // has categories & brands
    ]);

    if (!mounted) return;
    setState(() {
      _allVehicles = results[0] as List<VehicleModel>;
      final homeData = results[1] as HomeData;
      _categories = homeData.categories;
      _brands = homeData.brands;
      _isLoading = false;
      _applyFiltersAndSort();
    });
  }

  void _applyFiltersAndSort() {
    List<VehicleModel> list = List.from(_allVehicles);

    // Apply category chip filter
    if (_selectedCategory != 'All') {
      list = list.where((v) => (v.categoryRel?.name ?? '').toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }

    // Apply Filter sheet filters
    if (_filter.selectedCategory != 'All') {
      list = list.where((v) => (v.categoryRel?.name ?? '').toLowerCase() == _filter.selectedCategory.toLowerCase()).toList();
    }
    if (_filter.selectedBrand != 'All') {
      list = list.where((v) => (v.brandRel?.name ?? '').toLowerCase() == _filter.selectedBrand.toLowerCase()).toList();
    }
    if (_filter.selectedTrans != 'All') {
      list = list.where((v) => (v.transmission ?? '').toLowerCase() == _filter.selectedTrans.toLowerCase()).toList();
    }
    list = list.where((v) {
      final p = v.dailyPrice ?? 0;
      return p >= _filter.minPrice && p <= _filter.maxPrice;
    }).toList();

    // Apply sorting (daily price)
    list.sort((a, b) {
      final pa = a.dailyPrice ?? 0;
      final pb = b.dailyPrice ?? 0;
      return _sortAscending ? pa.compareTo(pb) : pb.compareTo(pa);
    });

    setState(() {
      _displayedVehicles = list;
    });
  }

  void _openFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _FilterBottomSheet(
          filter: _filter,
          categories: _categories,
          brands: _brands,
          onApply: () {
            _applyFiltersAndSort();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Our Fleet', style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
        actions: [
          // Filter trigger
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.orange),
            onPressed: () => _openFilterBottomSheet(context),
          ),
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : Column(
              children: [
                // 1. Horizontal categories chips row
                Container(
                  color: surface,
                  height: 52,
                  width: double.infinity,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: _categories.length + 1,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final name = idx == 0 ? 'All' : _categories[idx - 1].name;
                      final isSelected = _selectedCategory == name;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = name;
                            _applyFiltersAndSort();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.orange : surface2,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: isSelected ? AppColors.orange : borderColor),
                          ),
                          child: Center(
                            child: Text(
                              name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 2. Count & Sort Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_displayedVehicles.length} vehicles found',
                        style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _sortAscending = !_sortAscending;
                            _applyFiltersAndSort();
                          });
                        },
                        child: Row(
                          children: [
                            Text(
                              'Sort: Price',
                              style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                              size: 14,
                              color: AppColors.orange,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Vehicles List
                Expanded(
                  child: _displayedVehicles.isEmpty
                      ? Center(child: Text('No vehicles found.', style: TextStyle(color: textMuted, fontSize: 14)))
                      : ListView.separated(
                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                          itemCount: _displayedVehicles.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, idx) {
                            return _SmallVehicleRowCard(
                              vehicle: _displayedVehicles[idx],
                              isDark: isDark,
                              surface2: surface2,
                              textColor: textColor,
                              textMuted: textMuted,
                              borderColor: borderColor,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

// ─── Small Vehicle Row Card (List view format matching Fleet design) ─────────
class _SmallVehicleRowCard extends StatelessWidget {
  const _SmallVehicleRowCard({
    required this.vehicle,
    required this.isDark,
    required this.surface2,
    required this.textColor,
    required this.textMuted,
    required this.borderColor,
  });

  final VehicleModel vehicle;
  final bool isDark;
  final Color surface2;
  final Color textColor;
  final Color textMuted;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final seats = vehicle.seats ?? 5;
    final trans = vehicle.transmission ?? 'Auto';
    final price = vehicle.dailyPrice?.toInt() ?? 0;

    return GestureDetector(
      onTap: () => context.push(AppRoute.vehicleDetail, extra: vehicle),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            // Left Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 96,
                height: 72,
                child: vehicle.primaryImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: vehicle.primaryImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: AppColors.surfaceDark),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surfaceDark,
                          child: const Icon(Icons.directions_car_rounded, size: 24, color: AppColors.textMutedDark),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceDark,
                        child: const Icon(Icons.directions_car_rounded, size: 24, color: AppColors.textMutedDark),
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Right Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${vehicle.categoryRel?.name ?? 'Sedan'} · $seats Seats · $trans',
                    style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AED $price/day',
                        style: const TextStyle(
                          color: AppColors.orange,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: vehicle.available
                              ? AppColors.success.withValues(alpha: 0.12)
                              : AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          vehicle.available ? 'Available' : 'Rented',
                          style: TextStyle(
                            color: vehicle.available ? AppColors.success : AppColors.error,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
  }
}

// ─── Filter Bottom Sheet ─────────────────────────────────────────────────────
class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet({
    required this.filter,
    required this.categories,
    required this.brands,
    required this.onApply,
  });

  final VehicleFilter filter;
  final List<CategoryModel> categories;
  final List<BrandModel> brands;
  final VoidCallback onApply;

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late double _minPrice;
  late double _maxPrice;
  late String _selectedCategory;
  late String _selectedTrans;
  late String _selectedBrand;

  @override
  void initState() {
    super.initState();
    _minPrice = widget.filter.minPrice;
    _maxPrice = widget.filter.maxPrice;
    _selectedCategory = widget.filter.selectedCategory;
    _selectedTrans = widget.filter.selectedTrans;
    _selectedBrand = widget.filter.selectedBrand;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final surface2 = isDark ? AppColors.surface2Dark : AppColors.surface2Light;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Vehicles',
                style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _minPrice = 50;
                    _maxPrice = 500;
                    _selectedCategory = 'All';
                    _selectedTrans = 'All';
                    _selectedBrand = 'All';
                  });
                },
                child: const Text(
                  'Reset All',
                  style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 1. Daily Rate Slider
          Text(
            'DAILY RATE (AED)',
            style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MIN: AED ${_minPrice.toInt()}', style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('MAX: AED ${_maxPrice.toInt()}+', style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: 50,
            max: 500,
            activeColor: AppColors.orange,
            inactiveColor: borderColor,
            onChanged: (values) {
              setState(() {
                _minPrice = values.start;
                _maxPrice = values.end;
              });
            },
          ),
          const SizedBox(height: 20),

          // 2. Category Chips
          Text(
            'CATEGORY',
            style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                label: 'All',
                isSelected: _selectedCategory == 'All',
                onSelected: () => setState(() => _selectedCategory = 'All'),
                surface2: surface2,
                borderColor: borderColor,
                textColor: textColor,
              ),
              ...widget.categories.map((c) {
                return _buildFilterChip(
                  label: c.name,
                  isSelected: _selectedCategory == c.name,
                  onSelected: () => setState(() => _selectedCategory = c.name),
                  surface2: surface2,
                  borderColor: borderColor,
                  textColor: textColor,
                );
              }),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Brand Chips
          Text(
            'BRAND',
            style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                label: 'All',
                isSelected: _selectedBrand == 'All',
                onSelected: () => setState(() => _selectedBrand = 'All'),
                surface2: surface2,
                borderColor: borderColor,
                textColor: textColor,
              ),
              ...widget.brands.map((b) {
                return _buildFilterChip(
                  label: b.name,
                  isSelected: _selectedBrand == b.name,
                  onSelected: () => setState(() => _selectedBrand = b.name),
                  surface2: surface2,
                  borderColor: borderColor,
                  textColor: textColor,
                );
              }),
            ],
          ),
          const SizedBox(height: 20),

          // 4. Transmission Choice
          Text(
            'TRANSMISSION',
            style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildFilterChip(
                label: 'All',
                isSelected: _selectedTrans == 'All',
                onSelected: () => setState(() => _selectedTrans = 'All'),
                surface2: surface2,
                borderColor: borderColor,
                textColor: textColor,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Automatic',
                isSelected: _selectedTrans == 'Automatic',
                onSelected: () => setState(() => _selectedTrans = 'Automatic'),
                surface2: surface2,
                borderColor: borderColor,
                textColor: textColor,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Manual',
                isSelected: _selectedTrans == 'Manual',
                onSelected: () => setState(() => _selectedTrans == 'Manual'),
                surface2: surface2,
                borderColor: borderColor,
                textColor: textColor,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                widget.filter.minPrice = _minPrice;
                widget.filter.maxPrice = _maxPrice;
                widget.filter.selectedCategory = _selectedCategory;
                widget.filter.selectedTrans = _selectedTrans;
                widget.filter.selectedBrand = _selectedBrand;
                widget.onApply();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 20),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required Color surface2,
    required Color borderColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.orange : surface2,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: isSelected ? AppColors.orange : borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ─── Phase 1 Admin Placeholder ───────────────────────────────────────────────
class AdminPlaceholderScreen extends ConsumerWidget {
  const AdminPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        title: Text('Admin Dashboard',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.orange.withValues(alpha: 0.2),
                      AppColors.orange.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.orange.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 40,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Admin Console',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You are logged in as an Administrator.',
                style: TextStyle(color: textMuted, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.warningDim,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  '⚠ Full admin panel coming in Phase 2',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) context.go(AppRoute.login);
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                  label: const Text('Sign Out',
                      style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.errorDim),
                    backgroundColor: AppColors.errorDim,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
