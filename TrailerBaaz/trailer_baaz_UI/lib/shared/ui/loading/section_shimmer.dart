import 'package:flutter/material.dart';

import 'loading_shimmer.dart';

/// The Home screen skeleton: a full-height hero placeholder followed by
/// 4 horizontal card-rail skeletons.
///
/// Visually identical to the original `_LoadingShimmer` in `home_loading.dart`.
/// That file now delegates here so this layout lives in exactly one place.
class HomeSectionShimmer extends StatelessWidget {
  const HomeSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      builder: (context, shimmerColor) => CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          // Hero placeholder
          SliverToBoxAdapter(
            child: Container(
              height: MediaQuery.sizeOf(context).height * .54,
              color: shimmerColor,
            ),
          ),
          // Section rails placeholder
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
            sliver: SliverList.builder(
              itemCount: 4,
              itemBuilder: (_, _) => Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section title placeholder
                    Container(
                      width: 140,
                      height: 16,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Card row placeholder
                    SizedBox(
                      height: 166,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: 14),
                        itemBuilder: (_, _) => Container(
                          width: 260,
                          height: 166,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
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
}
