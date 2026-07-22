import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/home_models.dart';
import '../../../home/data/repositories/home_repository.dart';
import '../../data/repositories/admin_repository.dart';
import 'add_vehicle_screen.dart';
import 'edit_vehicle_screen.dart';

final adminVehiclesProvider = FutureProvider<List<VehicleModel>>((ref) async {
  final homeRepo = ref.read(homeRepositoryProvider);
  return homeRepo.fetchAllVehicles();
});

class AdminVehiclesScreen extends ConsumerStatefulWidget {
  const AdminVehiclesScreen({super.key});

  @override
  ConsumerState<AdminVehiclesScreen> createState() => _AdminVehiclesScreenState();
}

class _AdminVehiclesScreenState extends ConsumerState<AdminVehiclesScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Available', 'Rented'
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showDeleteVehicleDialog(BuildContext context, VehicleModel vehicle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor),
        ),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 36),
            ),
            const SizedBox(height: 14),
            Text(
              'Delete Vehicle?',
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to delete ${vehicle.name}? You can choose to Deactivate it instead, which hides it from the public catalog while preserving all booking history.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textMuted, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      try {
                        await ref.read(adminRepositoryProvider).updateVehicleStatus(vehicle, false);
                        ref.invalidate(adminVehiclesProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vehicle deactivated successfully'),
                              backgroundColor: AppColors.orange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to deactivate: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'Deactivate',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      try {
                        await ref.read(adminRepositoryProvider).deleteVehicle(vehicle.id);
                        ref.invalidate(adminVehiclesProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vehicle permanently deleted'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'Delete Permanently',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                width: double.infinity,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Center(
                  child: Text('Cancel', style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final surface2 = isDark ? AppColors.surface2Dark : AppColors.surface2Light;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final vehiclesAsync = ref.watch(adminVehiclesProvider);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FLEET MANAGEMENT',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'All Vehicles',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
                      ).then((_) => ref.invalidate(adminVehiclesProvider));
                    },
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, size: 18, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Add',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Search Bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  style: TextStyle(color: textColor, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search by name or plate number...',
                    hintStyle: TextStyle(color: textMuted, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: textMuted, size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: textMuted, size: 16),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ─── Status Filter Chips ─────────────────────────────────────────
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildFilterChip('All', isDark, textColor, borderColor),
                  const SizedBox(width: 8),
                  _buildFilterChip('Available', isDark, textColor, borderColor),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rented', isDark, textColor, borderColor),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ─── Vehicles List ───────────────────────────────────────────────
            Expanded(
              child: vehiclesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.orange),
                ),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 36, color: AppColors.error),
                      const SizedBox(height: 8),
                      Text('Failed to load vehicles', style: TextStyle(color: textColor, fontSize: 14)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(adminVehiclesProvider),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (allVehicles) {
                  final list = allVehicles.where((v) {
                    final matchesSearch = _searchQuery.isEmpty ||
                        v.name.toLowerCase().contains(_searchQuery) ||
                        (v.keywords ?? '').toLowerCase().contains(_searchQuery);

                    final matchesFilter = _selectedFilter == 'All' ||
                        (_selectedFilter == 'Available' && v.available) ||
                        (_selectedFilter == 'Rented' && !v.available);

                    return matchesSearch && matchesFilter;
                  }).toList();

                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_car_outlined, size: 48, color: textMuted),
                          const SizedBox(height: 12),
                          Text('No vehicles found',
                              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + Add Vehicle to get started.',
                            style: TextStyle(color: textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.orange,
                    onRefresh: () => ref.refresh(adminVehiclesProvider.future),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (ctx, idx) {
                        final vehicle = list[idx];
                        return _AdminVehicleCard(
                          vehicle: vehicle,
                          isDark: isDark,
                          surface2: surface2,
                          textColor: textColor,
                          textMuted: textMuted,
                          borderColor: borderColor,
                          onEdit: () {
                            Navigator.push(
                              ctx,
                              MaterialPageRoute(builder: (_) => EditVehicleScreen(vehicle: vehicle)),
                            ).then((_) => ref.invalidate(adminVehiclesProvider));
                          },
                          onDelete: () => _showDeleteVehicleDialog(ctx, vehicle),
                          onStatusToggled: (newStatus) async {
                            try {
                              await ref.read(adminRepositoryProvider).updateVehicleStatus(vehicle, newStatus);
                              ref.invalidate(adminVehiclesProvider);
                            } catch (e) {
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                                  content: Text('Failed: $e'),
                                  backgroundColor: AppColors.error,
                                ));
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

  Widget _buildFilterChip(String label, bool isDark, Color textColor, Color borderColor) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.orange : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: isSelected ? AppColors.orange : borderColor),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vehicle Card
// ─────────────────────────────────────────────────────────────────────────────
class _AdminVehicleCard extends StatelessWidget {
  const _AdminVehicleCard({
    required this.vehicle,
    required this.isDark,
    required this.surface2,
    required this.textColor,
    required this.textMuted,
    required this.borderColor,
    required this.onStatusToggled,
    required this.onEdit,
    required this.onDelete,
  });

  final VehicleModel vehicle;
  final bool isDark;
  final Color surface2;
  final Color textColor;
  final Color textMuted;
  final Color borderColor;
  final ValueChanged<bool> onStatusToggled;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isAvail = vehicle.available && vehicle.quantity > 0;
    final statusColor = isAvail ? AppColors.success : AppColors.error;

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enlarged Thumbnail with Overlay Status Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 108,
                    height: 82,
                    child: vehicle.primaryImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: vehicle.primaryImage,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => Container(
                              color: AppColors.surfaceDark,
                              child: const Icon(Icons.directions_car_rounded, color: AppColors.orange, size: 32),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceDark,
                            child: const Icon(Icons.directions_car_rounded, color: AppColors.orange, size: 32),
                          ),
                  ),
                ),
                // Top-Right Overlay Badge on Thumbnail
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      isAvail ? 'Available' : 'Rented',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Middle Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vehicle.name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${vehicle.categoryRel?.name ?? "Vehicle"} · Qty: ${vehicle.quantity}',
                    style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (vehicle.keywords != null && vehicle.keywords!.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Plate: ${vehicle.keywords}',
                      style: TextStyle(color: textMuted, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    'AED ${vehicle.dailyPrice?.toInt() ?? 0}/day',
                    style: const TextStyle(
                      color: AppColors.orange,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            // Right Actions & Toggle Switch
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDelete,
                  tooltip: 'Delete vehicle',
                ),
                const SizedBox(height: 12),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: vehicle.available,
                    onChanged: onStatusToggled,
                    activeThumbColor: AppColors.success,
                    activeTrackColor: AppColors.success.withValues(alpha: 0.3),
                    inactiveThumbColor: textMuted,
                    inactiveTrackColor: borderColor,
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
