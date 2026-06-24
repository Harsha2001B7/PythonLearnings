import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';
import 'trailer_card.dart';

class TrailerSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<TrailerModel> trailers;
  final double cardWidth;
  final ValueChanged<TrailerModel>? onTap;
  final Color? titleColor;
  final bool letterSpaced;
  final bool showTrendingBadge;

  const TrailerSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.trailers,
    this.cardWidth = 150,
    this.onTap,
    this.titleColor,
    this.letterSpaced = false,
    this.showTrendingBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = cardWidth / 0.72 + 96;
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: [0, 0.88, 1],
        colors: [Colors.white, Colors.white, Colors.transparent],
      ).createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: Padding(
        padding: const EdgeInsets.only(top: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: titleColor ?? AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                      letterSpacing: letterSpaced ? 1.6 : 0,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 5),
                    Text(subtitle!, style: const TextStyle(color: AppColors.textGrey)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: cardHeight,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: trailers.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, index) => TrailerCard(
                  trailer: trailers[index],
                  width: cardWidth,
                  showTrendingBadge: showTrendingBadge,
                  onTap: onTap == null ? null : () => onTap!(trailers[index]),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
