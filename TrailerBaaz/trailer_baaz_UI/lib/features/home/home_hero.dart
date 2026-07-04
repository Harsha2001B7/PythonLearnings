part of 'home_screen.dart';

// ─── Cinematic Home Body ─────────────────────────────────────────────────────

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

  static const double _heroHeightFraction = 0.57;
  static const double _playButtonSize = 50;
  static const double _sectionHorizontalPadding = 24;
  static const double _sectionVerticalPadding = 18;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = screenHeight * _heroHeightFraction;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Hero Image (artwork only) ─────────────────────────────────────
        SliverToBoxAdapter(
          child: SizedBox(
            height: heroHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (heroTrailers.isNotEmpty)
                  PageView.builder(
                    controller: heroController,
                    onPageChanged: onPageChanged,
                    itemBuilder: (context, index) {
                      final trailer =
                          heroTrailers[index % heroTrailers.length];
                      return _CinematicHeroSlide(
                        trailer: trailer,
                        onOpen: () => onOpenDetails(trailer),
                      );
                    },
                  ),
                // Header always on top
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: HomeHeader(
                    topPadding: MediaQuery.paddingOf(context).top,
                  ),
                ),
                // Play button bottom-right
                if (heroTrailers.isNotEmpty)
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: ValueListenableBuilder<int>(
                      valueListenable: pageListenable,
                      builder: (context, page, _) {
                        final trailer =
                            heroTrailers[page % heroTrailers.length];
                        return _HeroPlayButton(
                          onTap: () => onPlayTrailer(trailer),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ── Progress Bar ──────────────────────────────────────────────────
        if (heroTrailers.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: _CinematicProgressBar(
                total: heroTrailers.length,
                currentListenable: pageListenable,
              ),
            ),
          ),

        // ── Trailer Information Section ───────────────────────────────────
        if (heroTrailers.isNotEmpty)
          SliverToBoxAdapter(
            child: ValueListenableBuilder<int>(
              valueListenable: pageListenable,
              builder: (context, page, _) {
                final trailer = heroTrailers[page % heroTrailers.length];
                return _HeroInfoSection(
                  trailer: trailer,
                  onTap: () => onOpenDetails(trailer),
                );
              },
            ),
          ),

        // ── Subtle Divider ──────────────────────────────────────────────
        if (heroTrailers.isNotEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _CinematicHomeBody._sectionHorizontalPadding,
              ),
              child: Divider(
                height: 1,
                thickness: 0.6,
                color: Color(0x14FFFFFF), // ~8% opacity white
              ),
            ),
          ),

        // ── Browse / Category Bar ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: _QuickCategoryBar(
              onShowBrowse: onShowBrowse,
              onSelect: onSelectSection,
            ),
          ),
        ),

        // ── Content Sections ──────────────────────────────────────────────
        buildSectionsSliver(sections),
      ],
    );
  }
}

// ─── Hero Play Button ─────────────────────────────────────────────────────────

class _HeroPlayButton extends StatelessWidget {
  const _HeroPlayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _CinematicHomeBody._playButtonSize,
        height: _CinematicHomeBody._playButtonSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0x1FFFFFFF),
          border: Border.fromBorderSide(
            BorderSide(
              color: Color(0x40FFFFFF),
              width: 0.8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x4D000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

// ─── Cinematic Hero Slide (artwork only, no metadata) ────────────────────────

class _CinematicHeroSlide extends StatelessWidget {
  const _CinematicHeroSlide({
    required this.trailer,
    required this.onOpen,
  });

  final Trailer trailer;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cinematic thumbnail with bottom fade
          TrailerBackdropHero(
            trailerId: trailer.id,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.black, Colors.transparent],
                stops: [0.0, 0.72, 1.0],
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: CinematicImage(
                url: trailer.youtubeThumbnailUrl,
                fallbackUrl: trailer.youtubeHqThumbnailUrl,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          // Subtle cinematic accent glow
          Positioned.fill(
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.4,
                  colors: [
                    Color(0x0FE50914),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Top status bar scrim
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
        ],
      ),
    );
  }
}

// ─── Hero Info Section (below image, natural content row) ────────────────────

class _HeroInfoSection extends StatelessWidget {
  const _HeroInfoSection({
    required this.trailer,
    required this.onTap,
  });

  final Trailer trailer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _CinematicHomeBody._sectionHorizontalPadding,
          vertical: _CinematicHomeBody._sectionVerticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Studio badge
            if (trailer.studio.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: _StudioBadge(label: trailer.studio),
              ),

            // Title
            Text(
              trailer.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.18,
                letterSpacing: 0.05,
              ),
            ),

            // Tagline
            if (trailer.tagline.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                '"${trailer.tagline}"',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0x8CFFFFFF),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Metadata row
            _HeroMetadataRow(trailer: trailer),
          ],
        ),
      ),
    );
  }
}

// ─── Studio Badge ─────────────────────────────────────────────────────────────

class _StudioBadge extends StatelessWidget {
  const _StudioBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x24FFFFFF)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0x99FFFFFF),
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}

// ─── Hero Metadata Row (genre • runtime • popcorn score) ─────────────────────

class _HeroMetadataRow extends StatelessWidget {
  const _HeroMetadataRow({required this.trailer});

  final Trailer trailer;

  @override
  Widget build(BuildContext context) {
    const metaStyle = TextStyle(
      color: Color(0xA6FFFFFF),
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    const dotStyle = TextStyle(
      color: Color(0x4DFFFFFF),
      fontSize: 11,
    );

    return Wrap(
      spacing: 5,
      runSpacing: 3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (trailer.genres.isNotEmpty)
          Text(trailer.genres.take(2).join(' · '), style: metaStyle),
        if (trailer.runtime.isNotEmpty) ...[
          const Text('·', style: dotStyle),
          Text(trailer.runtime, style: metaStyle),
        ],
        const Text('·', style: dotStyle),
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
    );
  }
}

// ─── Progress Bar ─────────────────────────────────────────────────────────────

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
                        ? const Color(0xE6FFFFFF)
                        : const Color(0x2EFFFFFF),
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