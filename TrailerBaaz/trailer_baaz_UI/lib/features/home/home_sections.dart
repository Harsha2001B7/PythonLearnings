part of 'home_screen.dart';

class _SectionDetailView extends StatelessWidget {
  const _SectionDetailView({
    required this.sectionKey,
    required this.trailers,
    required this.onBack,
    required this.onOpenDetails,
    required this.onPlay,
    required this.onShowBrowse,
  });

  final String sectionKey;
  final List<Trailer> trailers;
  final VoidCallback onBack;
  final ValueChanged<Trailer> onOpenDetails;
  final ValueChanged<Trailer> onPlay;
  final VoidCallback onShowBrowse;

  @override
  Widget build(BuildContext context) {
    final cat = [..._browseCategories, ..._languageCategories].firstWhere(
      (c) => c.sectionKey == sectionKey,
      orElse: () => const _BrowseCategory(
        label: 'Trailers',
        icon: Icons.movie_rounded,
        color: AppTheme.accent,
        sectionKey: '',
      ),
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 12,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cat.color.withValues(alpha: 0.25),
                  AppTheme.background.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onShowBrowse,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Browse',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: AppTheme.accent,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: cat.flag != null
                          ? Center(
                              child: Text(
                                cat.flag!,
                                style: const TextStyle(fontSize: 26),
                              ),
                            )
                          : Icon(cat.icon, color: cat.color, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          '${trailers.length} trailers',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (trailers.isEmpty)
          const SliverFillRemaining(
            child: NoResults(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            sliver: SliverList.separated(
              itemCount: trailers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final trailer = trailers[index];
                return TrailerCard.large(
                  trailer: trailer,
                  onTap: () => onOpenDetails(trailer),
                  onPlay: () => onPlay(trailer),
                  width: MediaQuery.sizeOf(context).width - 40,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _MostAwaitedCarousel extends StatefulWidget {
  const _MostAwaitedCarousel({
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
  State<_MostAwaitedCarousel> createState() => _MostAwaitedCarouselState();
}

class _MostAwaitedCarouselState extends State<_MostAwaitedCarousel> {
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
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
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
                    return AnimatedBuilder(
                      animation: _pageController,
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

                        final trailer =
                            widget.trailers[index % widget.trailers.length];
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
                                    child: TrailerCard(
                                      trailer: trailer,
                                      width: cardWidth,
                                      height: imageHeight,
                                      showDetails: true,
                                      onTap: () => widget.onTap(trailer),
                                      onPlay: () => widget.onPlay(trailer),
                                    ),
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

class _TrendingStackedRail extends StatefulWidget {
  const _TrendingStackedRail({
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
  State<_TrendingStackedRail> createState() => _TrendingStackedRailState();
}

class _TrendingStackedRailState extends State<_TrendingStackedRail>
    with SingleTickerProviderStateMixin {
  double _page = 0.0;
  AnimationController? _snapCtrl;
  Animation<double>? _snapAnim;

  @override
  void initState() {
    super.initState();
    _snapCtrl =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 340),
        )..addListener(() {
          if (_snapAnim != null) {
            setState(() {
              _page = _snapAnim!.value;
            });
          }
        });
  }

  @override
  void dispose() {
    try {
      _snapCtrl?.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_snapCtrl?.isAnimating == true) _snapCtrl?.stop();
    final delta = -(details.primaryDelta ?? 0);
    setState(() {
      _page += delta / _cardWidth(context);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    double target = _page.roundToDouble();

    if (velocity < -400) {
      target = _page.floor() + 1.0;
    } else if (velocity > 400) {
      target = _page.ceil() - 1.0;
    }

    if (_snapCtrl != null) {
      _snapAnim = Tween<double>(begin: _page, end: target).animate(
        CurvedAnimation(parent: _snapCtrl!, curve: Curves.easeOutCubic),
      );
      _snapCtrl!.forward(from: 0.0);
    }
  }

  double _cardWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width * 0.8;

  @override
  Widget build(BuildContext context) {
    if (widget.trailers.isEmpty) return const SizedBox();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth * 0.82;
    final imageHeight = cardWidth * (9 / 16);
    final cardHeight = imageHeight + kCardTextSectionHeight;
    final currentIndex = _page.floor();

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
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: cardHeight + 20,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (int offset = 3; offset >= 0; offset--)
                    _buildCard(
                      currentIndex + offset,
                      cardWidth,
                      cardHeight,
                      imageHeight,
                    ),
                  _buildCard(
                    currentIndex - 1,
                    cardWidth,
                    cardHeight,
                    imageHeight,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    int index,
    double cardWidth,
    double cardHeight,
    double imageHeight,
  ) {
    final diff = index - _page;
    if (diff <= -1.5 || diff >= 3.5) return const SizedBox.shrink();

    const scaleStep = 0.06;
    final peekWidth = MediaQuery.sizeOf(context).width * 0.055;
    final translationStep = cardWidth * scaleStep + peekWidth;

    double scale;
    double translateX;
    double dimAlpha;

    if (diff <= 0) {
      scale = (1.0 + diff * 0.03).clamp(0.8, 1.0);
      translateX = diff * MediaQuery.sizeOf(context).width * 0.88;
      dimAlpha = 0.0;
    } else {
      scale = (1.0 - diff * scaleStep).clamp(0.0, 1.0);
      translateX = diff * translationStep;
      dimAlpha = (diff * 0.32).clamp(0.0, 0.80);
    }

    final isFront = diff.abs() < 0.5;
    final trailerIndex =
        (index % widget.trailers.length + widget.trailers.length) %
        widget.trailers.length;
    final trailer = widget.trailers[trailerIndex];
    final renderHeight = isFront ? cardHeight : imageHeight;

    return Positioned(
      left: 20,
      top: 10,
      bottom: 10,
      child: Transform(
        transform:
            Matrix4.translationValues(translateX, 0.0, 0.0) *
            Matrix4.diagonal3Values(scale, scale, 1.0),
        alignment: Alignment.centerLeft,
        child: IgnorePointer(
          ignoring: !isFront,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: isFront
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: (0.5 * (1 - dimAlpha)).clamp(0.0, 0.5),
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: (0.25 * (1 - dimAlpha)).clamp(0.0, 0.25),
                        ),
                        blurRadius: 8,
                        offset: const Offset(-3, 0),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                TrailerCard(
                  trailer: trailer,
                  width: cardWidth,
                  height: isFront ? imageHeight : renderHeight,
                  showDetails: isFront,
                  onTap: () => widget.onTap(trailer),
                  onPlay: () => widget.onPlay(trailer),
                ),
                if (dimAlpha > 0.01)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: dimAlpha),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrailerRail extends StatelessWidget {
  const _TrailerRail({
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
                  itemCount: trailers.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) => TrailerCard(
                    trailer: trailers[index],
                    onTap: () => onTap(trailers[index]),
                    onPlay: () => onPlay(trailers[index]),
                    width: railCardWidth,
                    height: imageH,
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
