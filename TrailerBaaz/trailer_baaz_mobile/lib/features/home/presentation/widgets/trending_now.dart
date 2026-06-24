import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';
import 'trailer_section.dart';

class TrendingNow extends StatelessWidget {
  final List<TrailerModel> trailers;
  final ValueChanged<TrailerModel>? onTap;

  const TrendingNow({super.key, required this.trailers, this.onTap});

  @override
  Widget build(BuildContext context) {
    return TrailerSection(
      title: 'TRENDING NOW',
      subtitle: 'Fresh trailers catching fire across languages',
      titleColor: AppColors.amber,
      letterSpaced: true,
      showTrendingBadge: true,
      trailers: trailers,
      cardWidth: 156,
      onTap: onTap,
    );
  }
}
