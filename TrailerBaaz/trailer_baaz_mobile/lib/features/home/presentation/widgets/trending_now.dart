import 'package:flutter/material.dart';

import '../../../../shared/models/trailer_model.dart';
import 'trailer_section.dart';

class TrendingNow extends StatelessWidget {
  final List<TrailerModel> trailers;

  const TrendingNow({super.key, required this.trailers});

  @override
  Widget build(BuildContext context) {
    return TrailerSection(title: '🔥 Trending', trailers: trailers, cardWidth: 156);
  }
}
