import 'package:flutter/material.dart';

import '../../../../shared/models/trailer_model.dart';
import 'trailer_card.dart';

class RelatedTrailersSection extends StatelessWidget {
  final List<TrailerModel> trailers;
  final ValueChanged<TrailerModel> onTap;

  const RelatedTrailersSection({
    super.key,
    required this.trailers,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = 150 / 0.72 + 92;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Related Trailers', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: trailers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, index) => TrailerCard(trailer: trailers[index], width: 150, onTap: () => onTap(trailers[index])),
          ),
        ),
      ],
    );
  }
}
