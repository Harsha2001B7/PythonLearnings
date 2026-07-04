import 'package:flutter/material.dart';

import '../../../core/data/youtube_trailers_provider.dart';
import '../../../core/di/locator.dart';
import '../../../core/models/trailer.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../shared/trailer_player/trailer_player.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/trailer_card.dart';

class RelatedRail extends StatefulWidget {
  const RelatedRail({super.key, required this.current, this.reversed = false});

  final Trailer current;
  final bool reversed;

  @override
  State<RelatedRail> createState() => _RelatedRailState();
}

class _RelatedRailState extends State<RelatedRail> {
  late final List<Trailer> _items;

  @override
  void initState() {
    super.initState();
    final provider = locator<YoutubeTrailersProvider>();
    final allTrailers = provider.sections.values
        .expand((list) => list)
        .where((t) => t.id != widget.current.id)
        .toList();
    if (widget.reversed) {
      allTrailers.sort((a, b) => b.title.compareTo(a.title));
    }
    _items = allTrailers.take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const SizedBox(
        height: 100,
        child: NoResults(message: 'No related trailers'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = MediaQuery.sizeOf(context).width * 0.74;
        final imageH = cardWidth * (9 / 16);
        return SizedBox(
          height: imageH + kCardTextSectionHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => TrailerCard(
              trailer: _items[index],
              onTap: () {
                locator<NavigationService>().replaceTrailerDetails(
                  context,
                  _items[index],
                );
              },
              onPlay: () => showTrailerPlayer(context, _items[index]),
              width: cardWidth,
              height: imageH,
            ),
          ),
        );
      },
    );
  }
}
