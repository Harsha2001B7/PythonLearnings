import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';
import '../../../../shared/widgets/glass_surfaces.dart';
import '../../../../shared/widgets/premium_network_image.dart';

class HeroCarousel extends StatefulWidget {
  final List<TrailerModel> trailers;
  final ValueChanged<TrailerModel> onPlay;
  final ValueChanged<TrailerModel> onDetails;
  final bool fullBleed;

  const HeroCarousel({
    super.key,
    required this.trailers,
    required this.onPlay,
    required this.onDetails,
    this.fullBleed = false,
  });

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _pageController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.fullBleed ? 1 : 0.92,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double get _heroHeight {
    final size = MediaQuery.of(context).size;
    final height = size.height * (widget.fullBleed ? 0.50 : 0.40);
    return height
        .clamp(
          widget.fullBleed ? 360.0 : 280.0,
          widget.fullBleed ? 460.0 : 360.0,
        )
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trailers.isEmpty) {
      return SizedBox(
        height: _heroHeight,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _EmptyHeroState(),
        ),
      );
    }

    return SizedBox(
      height: _heroHeight,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.trailers.length,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          if (_index == index) return;
          setState(() => _index = index);
        },
        itemBuilder: (context, index) {
          final trailer = widget.trailers[index];
          final active = _index == index;
          return AnimatedScale(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            scale: active ? 1.0 : 0.975,
            child: Padding(
              padding: EdgeInsets.only(right: widget.fullBleed ? 0 : 10),
              child: _HeroSlide(
                trailer: trailer,
                onPlay: () => widget.onPlay(trailer),
                onDetails: () => widget.onDetails(trailer),
                indicatorCount: widget.trailers.length,
                indicatorIndex: index,
                fullBleed: widget.fullBleed,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  final TrailerModel trailer;
  final VoidCallback onPlay;
  final VoidCallback onDetails;
  final int indicatorIndex;
  final int indicatorCount;
  final bool fullBleed;

  const _HeroSlide({
    required this.trailer,
    required this.onPlay,
    required this.onDetails,
    required this.indicatorIndex,
    required this.indicatorCount,
    required this.fullBleed,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final topBlurHeight = (topInset + 138).clamp(150.0, 184.0).toDouble();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPlay,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(fullBleed ? 0 : 32),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.card,
            boxShadow: fullBleed
                ? const []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.36),
                      blurRadius: 32,
                      offset: const Offset(0, 18),
                    ),
                  ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: PremiumNetworkImage(url: trailer.imageUrl),
              ),
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                height: topBlurHeight,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xC20A0A0C), Color(0x00100D0A)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.22, 0.56, 0.82, 1.0],
                      colors: [
                        Color(0x6C0D0D0F),
                        Color(0x16000000),
                        Colors.transparent,
                        Color(0xAA000000),
                        Color(0xF20D0D0F),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 14,
                top: fullBleed ? topInset + 118 : 14,
                child: GlassIconButton(
                  size: 38,
                  padding: const EdgeInsets.all(8),
                  icon: const Icon(
                    Icons.local_movies_rounded,
                    color: AppColors.amber,
                    size: 19,
                  ),
                  onTap: () => showReactionBottomSheet(context, trailer),
                ),
              ),
              Positioned(
                left: fullBleed ? 18 : 18,
                right: fullBleed ? 18 : 18,
                bottom: fullBleed ? 24 : 18,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trailer.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.04,
                            fontSize: fullBleed ? 22 : 26,
                            shadows: const [
                              Shadow(
                                color: Colors.black87,
                                blurRadius: 16,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${trailer.language} • ${trailer.genre} • ${trailer.industry}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textGrey.withValues(alpha: 0.72),
                        fontSize: 11,
                        shadows: [
                          Shadow(color: Colors.black87, blurRadius: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _HeroActionButton(
                          label: 'Play',
                          icon: Icons.play_arrow_rounded,
                          filled: true,
                          onTap: onPlay,
                        ),
                        const SizedBox(width: 12),
                        _HeroActionButton(
                          label: 'More info',
                          icon: Icons.info_outline_rounded,
                          onTap: onDetails,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(indicatorCount, (i) {
                          final selected = i == indicatorIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: selected ? 22 : 7,
                            height: 6,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.amber
                                  : Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _HeroActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 92, maxWidth: 132),
      child: GlassPillButton(
        label: label,
        icon: icon,
        filled: filled,
        height: 38,
        onTap: onTap,
      ),
    );
  }
}

class _EmptyHeroState extends StatelessWidget {
  const _EmptyHeroState();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        color: AppColors.card,
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.movie_creation_outlined,
              color: AppColors.textGrey,
              size: 42,
            ),
            SizedBox(height: 12),
            Text(
              'Loading premium trailers',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}
