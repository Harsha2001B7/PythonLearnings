part of 'home_screen.dart';

class _CinematicHomeBody extends StatelessWidget {
  const _CinematicHomeBody({
    required this.heroTrailers,
    required this.sections,
    required this.heroController,
    required this.pageListenable,
    required this.onPageChanged,
    required this.onOpenDetails,
    required this.onPlayTrailer,
    required this.onShowBrowse,
    required this.onSelectSection,
    required this.buildSectionsSliver,
  });

  final List<Trailer> heroTrailers;
  final Map<String, List<Trailer>> sections;
  final PageController heroController;
  final ValueListenable<int> pageListenable;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<Trailer> onOpenDetails;
  final ValueChanged<Trailer> onPlayTrailer;
  final VoidCallback onShowBrowse;
  final ValueChanged<String> onSelectSection;
  final Widget Function(Map<String, List<Trailer>>) buildSectionsSliver;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = screenHeight * 0.65;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: heroHeight + 30,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (heroTrailers.isNotEmpty)
                  Positioned.fill(
                    bottom: 0,
                    child: PageView.builder(
                      controller: heroController,
                      onPageChanged: onPageChanged,
                      itemBuilder: (context, index) {
                        final trailer =
                            heroTrailers[index % heroTrailers.length];
                        return _CinematicHeroSlide(
                          trailer: trailer,
                          onOpen: () => onOpenDetails(trailer),
                          onPlay: () => onPlayTrailer(trailer),
                          bottomPadding: 110.0,
                        );
                      },
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: HomeHeader(
                    topPadding: MediaQuery.paddingOf(context).top,
                  ),
                ),
                if (heroTrailers.isNotEmpty)
                  Positioned(
                    left: 28,
                    right: 28,
                    bottom: 126,
                    child: _CinematicProgressBar(
                      total: heroTrailers.length,
                      currentListenable: pageListenable,
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.only(top: 32, bottom: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: _QuickCategoryBar(
                      onShowBrowse: onShowBrowse,
                      onSelect: onSelectSection,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        buildSectionsSliver(sections),
      ],
    );
  }
}

class _CinematicHeroSlide extends StatelessWidget {
  const _CinematicHeroSlide({
    required this.trailer,
    required this.onOpen,
    required this.onPlay,
    this.bottomPadding = 0.0,
  });

  final Trailer trailer;
  final VoidCallback onOpen;
  final VoidCallback onPlay;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'backdrop-${trailer.id}',
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [Colors.black, Colors.black, Colors.transparent],
                stops: const [0.0, 0.75, 1.0],
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: CinematicImage(
                url: trailer.youtubeThumbnailUrl,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.4,
                  colors: [
                    AppTheme.accent.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.9),
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.12, 0.28, 0.55, 1.0],
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Color(0x99000000), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.9,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 28,
            right: 80,
            bottom: 48 + bottomPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailer.studio.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      trailer.studio.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                Text(
                  trailer.title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                if (trailer.tagline.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '"${trailer.tagline}"',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      trailer.genres.take(2).join(' · '),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (trailer.runtime.isNotEmpty) ...[
                      Text(
                        '•',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.25),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        trailer.runtime,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 10,
                        ),
                      ),
                    ],
                    Text(
                      '•',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.25),
                        fontSize: 10,
                      ),
                    ),
                    PopcornBadge(
                      score: trailer.hypeScore,
                      compact: true,
                      onTap: () => showPopcornRating(
                        context,
                        hypeScore: trailer.hypeScore,
                        currentRating: null,
                        onRatingChanged: (_) {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 28,
            bottom: 54 + bottomPadding,
            child: GestureDetector(
              onTap: onPlay,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CinematicProgressBar extends StatelessWidget {
  const _CinematicProgressBar({
    required this.total,
    required this.currentListenable,
  });

  final int total;
  final ValueListenable<int> currentListenable;

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();

    return SizedBox(
      height: 2.5,
      child: ValueListenableBuilder<int>(
        valueListenable: currentListenable,
        builder: (context, current, _) {
          return Row(
            children: List.generate(total, (index) {
              final isActive = index == current % total;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.18),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
