import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../../../app/app_theme.dart';
import '../../../core/models/trailer.dart';
import '../../../shared/widgets/trailer_card.dart';

class TrailerRail extends StatelessWidget {
  const TrailerRail({
    super.key,
    required this.title,
    required this.trailers,
    required this.onTap,
    required this.onPlay,
  });

  final String title;
  final List<Trailer> trailers;
  final ValueChanged<Trailer> onTap;
  final ValueChanged<Trailer> onPlay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final railCardWidth = MediaQuery.sizeOf(context).width * 0.74;
              final imageH = railCardWidth * (9 / 16);
              return SizedBox(
                height: imageH + kCardTextSectionHeight,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  scrollCacheExtent: ScrollCacheExtent.pixels(railCardWidth * 2.5),
                  itemCount: trailers.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) => RepaintBoundary(
                    child: TrailerCard(
                      trailer: trailers[index],
                      onTap: () => onTap(trailers[index]),
                      onPlay: () => onPlay(trailers[index]),
                      width: railCardWidth,
                      height: imageH,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
