import 'package:flutter/material.dart';

import '../../../../shared/models/trailer_model.dart';
import 'trailer_section.dart';

class TrendingNow extends StatelessWidget {
  final List<TrailerModel> trailers;
  final ValueChanged<TrailerModel>? onTap;

  const TrendingNow({super.key, required this.trailers, this.onTap});

  @override
  Widget build(BuildContext context) {
    return TrailerSection(title: '🔥 Trending', trailers: trailers, cardWidth: 156, onTap: onTap);
  }
}
