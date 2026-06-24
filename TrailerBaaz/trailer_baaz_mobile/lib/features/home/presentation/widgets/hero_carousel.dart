import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';

class HeroCarousel extends StatefulWidget {
  final List<TrailerModel> trailers;
  final ValueChanged<TrailerModel> onPlay;
  final ValueChanged<TrailerModel> onDetails;

  const HeroCarousel({
    super.key,
    required this.trailers,
    required this.onPlay,
    required this.onDetails,
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
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double get _heroHeight {
    final height = MediaQuery.of(context).size.height * 0.37;
    return height.clamp(260.0, 340.0).toDouble();
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
              padding: const EdgeInsets.only(right: 10),
              child: _HeroSlide(
                trailer: trailer,
                onPlay: () => widget.onPlay(trailer),
                onDetails: () => widget.onDetails(trailer),
                indicatorCount: widget.trailers.length,
                indicatorIndex: index,
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

  const _HeroSlide({
    required this.trailer,
    required this.onPlay,
    required this.onDetails,
    required this.indicatorIndex,
    required this.indicatorCount,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.42),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: _SafeImage(url: trailer.imageUrl),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.45, 0.82, 1.0],
                    colors: [
                      Color(0x66000000),
                      Colors.transparent,
                      Color(0x10000000),
                      Color(0xEE0D0D0F),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: 18,
              child: _GlassBadge(
                label: trailer.isUpcoming ? 'COMING SOON' : 'OFFICIAL TRAILER',
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trailer.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.02,
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
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                      shadows: [
                        Shadow(color: Colors.black87, blurRadius: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _HeroActionButton(
                          label: 'Play',
                          icon: Icons.play_arrow_rounded,
                          filled: true,
                          onTap: onPlay,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HeroActionButton(
                          label: 'More info',
                          icon: Icons.info_outline_rounded,
                          onTap: onDetails,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: List.generate(indicatorCount, (i) {
                      final selected = i == indicatorIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.only(right: 6),
                        width: selected ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.amber
                              : Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: filled
                ? AppColors.textWhite
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: filled
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: filled ? AppColors.background : AppColors.textWhite,
                size: 18,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: filled ? AppColors.background : AppColors.textWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  final String label;

  const _GlassBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
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
            Icon(Icons.movie_creation_outlined, color: AppColors.textGrey, size: 42),
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

class _SafeImage extends StatefulWidget {
  final String url;

  const _SafeImage({required this.url});

  @override
  State<_SafeImage> createState() => _SafeImageState();
}

class _SafeImageState extends State<_SafeImage> {
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    final valid = widget.url.startsWith('http') && widget.url.contains('/t/p/');
    if (_failed || !valid) {
      return const ColoredBox(
        color: AppColors.card,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.textGrey,
            size: 42,
          ),
        ),
      );
    }

    return Image.network(
      widget.url,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
      errorBuilder: (context, error, stackTrace) {
        if (!_failed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _failed = true);
          });
        }
        return const ColoredBox(
          color: AppColors.card,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.textGrey,
              size: 42,
            ),
          ),
        );
      },
    );
  }
}
