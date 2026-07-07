import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/repositories/fleet_repository.dart';
import '../../../../core/providers/app_state_provider.dart';

class CompareSheet extends ConsumerWidget {
  const CompareSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);

    final vehicles = appState.compareList.map((id) {
      return FleetRepository.fleetData.firstWhere((v) => v.id == id);
    }).toList();

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
              Row(
                children: [
                  const Icon(Icons.bar_chart_outlined, color: AppColors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Comparing ${vehicles.length} vehicles',
                    style: AppTypography.headingMedium(),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      notifier.clearCompare();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Clear', style: TextStyle(color: AppColors.danger)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Comparison list
          if (vehicles.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Text(
                  'No vehicles selected for comparison.',
                  style: AppTypography.bodyMedium(),
                ),
              ),
            )
          else
            SizedBox(
              height: 380,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];

                  return Container(
                    width: 170,
                    margin: const EdgeInsets.only(right: 12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: CachedNetworkImage(
                              imageUrl: vehicle.images.thumbnail,
                              height: 80,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.paperSoft,
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            vehicle.name,
                            style: AppTypography.headingSmall(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AED ${vehicle.pricePerDay.toInt()}/day',
                            style: AppTypography.monoBold(color: AppColors.amber),
                          ),
                          const Divider(height: 16),
                          _buildCompareRow('Seats', '${vehicle.specs.seats}'),
                          _buildCompareRow('Fuel', vehicle.specs.fuel),
                          _buildCompareRow('Trans', vehicle.specs.transmission),
                          if (vehicle.specs.power != null)
                            _buildCompareRow('Power', vehicle.specs.power!),
                          if (vehicle.specs.zeroToSixty != null)
                            _buildCompareRow('0-60', vehicle.specs.zeroToSixty!),
                          if (vehicle.specs.range != null)
                            _buildCompareRow('Range', vehicle.specs.range!),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompareRow(String key, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key.toUpperCase(),
            style: AppTypography.monoStyle(color: AppColors.inkSubtle, size: 8),
          ),
          Text(
            val,
            style: AppTypography.monoBold(color: AppColors.ink, size: 9),
          ),
        ],
      ),
    );
  }
}
