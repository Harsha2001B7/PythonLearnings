import 'package:flutter/material.dart';

import '../../../../shared/models/trailer_model.dart';
import 'trailer_card.dart';

class TrailerSection extends StatelessWidget {
  final String title;
  final List<TrailerModel> trailers;
  final double cardWidth;

  const TrailerSection({
    super.key,
    required this.title,
    required this.trailers,
    this.cardWidth = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: cardWidth / 0.72 + 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: trailers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, index) => TrailerCard(trailer: trailers[index], width: cardWidth),
          ),
        ),
      ],
    );
  }
}
