part of 'home_screen.dart';

// ignore: unused_element
class _ClassicHomeBody extends StatelessWidget {
  const _ClassicHomeBody({
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
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height < 770
                ? 430
                : MediaQuery.sizeOf(context).height * .56,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (heroTrailers.isNotEmpty)
                  PageView.builder(
                    controller: heroController,
                    onPageChanged: onPageChanged,
                    itemBuilder: (context, index) {
                      final trailer = heroTrailers[index % heroTrailers.length];
                      return _HeroSlide(
                        trailer: trailer,
                        onOpen: () => onOpenDetails(trailer),
                        onPlay: () => onPlayTrailer(trailer),
                      );
                    },
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
                    left: 0,
                    right: 0,
                    bottom: 18,
                    child: ValueListenableBuilder<int>(
                      valueListenable: pageListenable,
                      builder: (context, page, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(heroTrailers.length, (index) {
                            final selected =
                                page % heroTrailers.length == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: selected ? 24 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: selected ? Colors.white : Colors.white24,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _QuickCategoryBar(
            onShowBrowse: onShowBrowse,
            onSelect: onSelectSection,
          ),
        ),
        buildSectionsSliver(sections),
      ],
    );
  }
}

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
                          AppTheme.background.withValues(alpha: 0.6),
                          AppTheme.background,
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
            child: CinematicImage(
              url: trailer.youtubeThumbnailUrl,
              alignment: Alignment.topCenter,
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
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppTheme.background,
                    Color(0xE6090909),
                    Color(0x99090909),
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

class _HeroSlide extends StatelessWidget {
  const _HeroSlide({
    required this.trailer,
    required this.onOpen,
    required this.onPlay,
  });

  final Trailer trailer;
  final VoidCallback onOpen;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return GestureDetector(
      onTap: onOpen,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: MediaQuery.paddingOf(context).top + 60,
            left: 0,
            right: 0,
            bottom: 0,
            child: Hero(
              tag: 'backdrop-${trailer.id}',
              child: CinematicImage(
                url: trailer.youtubeThumbnailUrl,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC000000),
                  Color(0x00000000),
                  Color(0xD9000000),
                  AppTheme.background,
                ],
                stops: [0, .28, .72, 1],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _HeaderCurveClipper(
                headerHeight: MediaQuery.paddingOf(context).top + 68,
                curveDepth: 14,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: MediaQuery.paddingOf(context).top + 68 + 14,
                  color: Colors.black.withValues(alpha: 0.48),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.paddingOf(context).top + 68 + 14,
              child: CustomPaint(
                painter: _HeaderArcPainter(
                  headerHeight: MediaQuery.paddingOf(context).top + 68,
                  curveDepth: 14,
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 16,
            bottom: 44,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .62),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          trailer.studio.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        trailer.title.toUpperCase(),
                        maxLines: 2,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width < 380 ? 12 : 14,
                          height: 1.25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '"${trailer.tagline}"',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            trailer.genres.take(2).join(' / '),
                            style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            '•',
                            style: TextStyle(
                              color: AppTheme.muted,
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            trailer.runtime,
                            style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 9,
                            ),
                          ),
                          const Text(
                            '•',
                            style: TextStyle(
                              color: AppTheme.muted,
                              fontSize: 9,
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
                const SizedBox(width: 12),
                InkWell(
                  onTap: onPlay,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.3),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
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

// ignore: unused_element
class _CinematicTopBar extends StatelessWidget {
  const _CinematicTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/TrailerBaaz6.png',
              height: 50,
              fit: BoxFit.contain,
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => AppShell.setIndex(context, 4),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CinematicImage(
                  url:
                      'https://images.unsplash.com/photo-1527980965255-d3b416303d12?auto=format&fit=crop&w=200&q=80',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderCurveClipper extends CustomClipper<Path> {
  const _HeaderCurveClipper({
    required this.headerHeight,
    required this.curveDepth,
  });

  final double headerHeight;
  final double curveDepth;

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, headerHeight)
      ..quadraticBezierTo(
        size.width / 2,
        headerHeight + curveDepth,
        0,
        headerHeight,
      )
      ..close();
    return path;
  }

  @override
  bool shouldReclip(_HeaderCurveClipper old) =>
      old.headerHeight != headerHeight || old.curveDepth != curveDepth;
}

class _HeaderArcPainter extends CustomPainter {
  const _HeaderArcPainter({
    required this.headerHeight,
    required this.curveDepth,
  });

  final double headerHeight;
  final double curveDepth;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, headerHeight)
      ..quadraticBezierTo(
        size.width / 2,
        headerHeight + curveDepth,
        size.width,
        headerHeight,
      );

    final gradient = const LinearGradient(
      colors: [Colors.transparent, Color(0xFFE50914), Colors.transparent],
      stops: [0.0, 0.5, 1.0],
    );
    final rect = Rect.fromLTWH(
      0,
      headerHeight - 20,
      size.width,
      curveDepth + 40,
    );

    canvas.drawPath(
      path,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    canvas.drawPath(
      path,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
