import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';
import 'trailer_card.dart';

class TrailerSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<TrailerModel> trailers;
  final double cardWidth;
  final Color? titleColor;
  final bool letterSpaced;
  final bool showTrendingBadge;
  final ValueChanged<TrailerModel>? onTap;

  const TrailerSection({
    super.key,
    required this.title,
    required this.trailers,
    this.subtitle,
    this.cardWidth = 260,
    this.titleColor,
    this.letterSpaced = false,
    this.showTrendingBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = cardWidth.clamp(240.0, 320.0).toDouble();
    final cardHeight = (width * 0.82).clamp(210.0, 270.0).toDouble();

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      // Section spacing stays generous, but the visual density is lighter.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: title,
            subtitle: subtitle,
            color: titleColor ?? AppColors.textWhite,
            letterSpaced: letterSpaced,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: cardHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: trailers.length,
              itemBuilder: (context, index) {
                final trailer = trailers[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == trailers.length - 1 ? 0 : 12,
                  ),
                  child: TrailerCard(
                    trailer: trailer,
                    width: width,
                    showTrendingBadge: showTrendingBadge,
                    onTap: onTap == null ? null : () => onTap!(trailer),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color color;
  final bool letterSpaced;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.letterSpaced,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: letterSpaced ? 3 : 0.8,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: theme.bodySmall?.copyWith(
                color: AppColors.textGrey.withValues(alpha: 0.72),
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
