import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../../core/models/trailer.dart';
import '../../../shared/widgets/trailer_card.dart';

class MostAwaitedCarousel extends StatefulWidget {
  const MostAwaitedCarousel({
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
  State<MostAwaitedCarousel> createState() => _MostAwaitedCarouselState();
}

class _MostAwaitedCarouselState extends State<MostAwaitedCarousel> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialPage = widget.trailers.isNotEmpty
        ? widget.trailers.length * 1000
        : 0;
    _pageController = PageController(
      viewportFraction: 0.82,
      initialPage: initialPage,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trailers.isEmpty) return const SizedBox();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth * 0.82;
    final imageHeight = cardWidth * (9 / 16);
    final cardHeight = imageHeight + kCardTextSectionHeight;
    final carouselHeight = cardHeight + 80;

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        Color(0x14FFFFFF),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: carouselHeight,
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  itemBuilder: (context, index) {
                    final trailer =
                        widget.trailers[index % widget.trailers.length];
                    final card = RepaintBoundary(
                      child: TrailerCard(
                        trailer: trailer,
                        width: cardWidth,
                        height: imageHeight,
                        showDetails: true,
                        onTap: () => widget.onTap(trailer),
                        onPlay: () => widget.onPlay(trailer),
                      ),
                    );

                    return AnimatedBuilder(
                      animation: _pageController,
                      child: card,
                      builder: (context, child) {
                        final page = _pageController.position.haveDimensions
                            ? _pageController.page!
                            : _pageController.initialPage.toDouble();

                        final diff = (index - page).clamp(-1.0, 1.0);
                        final scale = 1.0 - (0.12 * diff.abs());
                        final rotateY = -diff * 0.12;
                        final floatY = -12 * (1 - diff.abs());
                        final dimAlpha = (diff.abs() * 0.4).clamp(0.0, 0.4);
                        final glowIntensity = 1 - diff.abs();

                        final cardTransform = Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..multiply(
                            Matrix4.translationValues(0.0, floatY, 0.0),
                          )
                          ..multiply(Matrix4.diagonal3Values(scale, scale, 1.0))
                          ..rotateY(rotateY);

                        return Center(
                          child: Transform(
                            transform: cardTransform,
                            alignment: Alignment.center,
                            child: Container(
                              width: cardWidth,
                              height: cardHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.6 + (0.2 * glowIntensity),
                                    ),
                                    blurRadius: 20 + (10 * glowIntensity),
                                    offset: Offset(0, 12 + (8 * glowIntensity)),
                                  ),
                                  if (glowIntensity > 0)
                                    BoxShadow(
                                      color: AppTheme.accent.withValues(
                                        alpha: 0.15 * glowIntensity,
                                      ),
                                      blurRadius: 40,
                                      spreadRadius: 2,
                                    ),
                                ],
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: child,
                                  ),
                                  IgnorePointer(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: RadialGradient(
                                          center: Alignment.center,
                                          radius: 1.2,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(
                                              alpha: 0.2 + dimAlpha,
                                            ),
                                          ],
                                          stops: const [0.4, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                  IgnorePointer(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withValues(
                                              alpha: 0.12 * glowIntensity,
                                            ),
                                            Colors.transparent,
                                            Colors.transparent,
                                            Colors.white.withValues(
                                              alpha: 0.05 * glowIntensity,
                                            ),
                                          ],
                                          stops: const [0.0, 0.3, 0.7, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
