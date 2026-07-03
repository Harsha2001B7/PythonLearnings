import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/data/home_experience_provider.dart';
import '../../core/data/youtube_trailers_provider.dart';
import '../../core/models/trailer.dart';
import '../../shared/ui/ui.dart';
import '../../shared/widgets/cinematic_image.dart';
import '../../shared/widgets/popcorn_rating.dart';
import '../../shared/widgets/trailer_card.dart'
    show TrailerCard, kCardTextSectionHeight;
import '../../shared/widgets/trailer_player.dart';
import '../details/trailer_details_screen.dart';
import 'widgets/home_header.dart';

part 'home_categories.dart';
part 'home_hero.dart';
part 'home_sections.dart';
part 'home_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late final ValueNotifier<int> _pageNotifier;
  PageController? _heroController;
  Timer? _timer;
  String? _selectedSection;

  final _provider = YoutubeTrailersProvider.instance;
  final _experienceProvider = HomeExperienceProvider.instance;

  @override
  void initState() {
    super.initState();
    _pageNotifier = ValueNotifier<int>(1000);
    _heroController = PageController(initialPage: _pageNotifier.value);
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || _heroController?.hasClients != true) return;
      _heroController?.nextPage(
        duration: const Duration(milliseconds: 640),
        curve: Curves.easeOutCubic,
      );
    });
    _provider.addListener(_onDataChanged);
    _experienceProvider.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    try {
      _timer?.cancel();
      _heroController?.dispose();
      _pageNotifier.dispose();
    } catch (_) {}
    _provider.removeListener(_onDataChanged);
    _experienceProvider.removeListener(_onDataChanged);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _openDetails(Trailer trailer) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, _) => FadeTransition(
          opacity: animation,
          child: TrailerDetailsScreen(trailer: trailer),
        ),
      ),
    );
  }

  void _playTrailer(Trailer trailer) {
    showTrailerPlayer(context, trailer);
  }

  void _selectSection(String? sectionKey) {
    setState(() => _selectedSection = sectionKey);
  }

  void _showBrowseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => _BrowseSheet(
        onSelect: (sectionKey) {
          Navigator.pop(ctx);
          _selectSection(sectionKey);
        },
        selectedSection: _selectedSection,
        loadedSections: _provider.sections.keys.toSet(),
      ),
    );
  }

  Widget _buildSectionsSliver(Map<String, List<Trailer>> sections) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 96),
      sliver: SliverList.builder(
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final entry = sections.entries.elementAt(index);
          if (entry.key == 'Trending Now') {
            return _TrendingStackedRail(
              title: entry.key,
              trailers: entry.value,
              onTap: _openDetails,
              onPlay: _playTrailer,
            );
          }
          if (entry.key == 'Most Awaited') {
            return _MostAwaitedCarousel(
              title: entry.key,
              trailers: entry.value,
              onTap: _openDetails,
              onPlay: _playTrailer,
            );
          }
          return _TrailerRail(
            title: entry.key,
            trailers: entry.value,
            onTap: _openDetails,
            onPlay: _playTrailer,
          );
        },
      ),
    );
  }

  Widget _wrapWithBackdrop(Widget child) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(child: IgnorePointer(child: _WarmHueBackdrop())),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = _provider;

    if (provider.isLoading) return _wrapWithBackdrop(const _LoadingShimmer());

    if (provider.error != null && provider.sections.isEmpty) {
      return _wrapWithBackdrop(
        NetworkError(onRetry: provider.init),
      );
    }

    final heroTrailers = provider.heroTrailers;
    final sections = provider.sections;

    if (_selectedSection != null) {
      final sectionTrailers = sections[_selectedSection] ?? [];
      return _wrapWithBackdrop(
        _SectionDetailView(
          sectionKey: _selectedSection!,
          trailers: sectionTrailers,
          onBack: () => _selectSection(null),
          onOpenDetails: _openDetails,
          onPlay: _playTrailer,
          onShowBrowse: _showBrowseSheet,
        ),
      );
    }

    return _wrapWithBackdrop(
      _CinematicHomeBody(
        heroTrailers: heroTrailers,
        sections: sections,
        heroController: _heroController!,
        pageListenable: _pageNotifier,
        onPageChanged: (v) => _pageNotifier.value = v,
        onOpenDetails: _openDetails,
        onPlayTrailer: _playTrailer,
        onShowBrowse: _showBrowseSheet,
        onSelectSection: _selectSection,
        buildSectionsSliver: _buildSectionsSliver,
      ),
    );
  }
}
class _WarmHueBackdrop extends StatefulWidget {
  const _WarmHueBackdrop();

  @override
  State<_WarmHueBackdrop> createState() => _WarmHueBackdropState();
}

class _WarmHueBackdropState extends State<_WarmHueBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final t = Curves.easeInOut.transform(_controller.value);

        final glowA = Alignment.lerp(
          const Alignment(-1.3, -1.15),
          const Alignment(1.15, -0.45),
          t,
        )!;

        final glowB = Alignment.lerp(
          const Alignment(1.15, 0.55),
          const Alignment(-0.8, 0.95),
          t,
        )!;

        return Stack(
          fit: StackFit.expand,
          children: [
            //----------------------------------------------------
            // Base
            //----------------------------------------------------
            const ColoredBox(
              color: Color(0xFF030303),
            ),

            //----------------------------------------------------
            // Huge cinematic red glow
            //----------------------------------------------------
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: glowA,
                    radius: 2.8,
                    colors: const [
                      Color(0xB3FF2D2D),
                      Color(0x66D11F1F),
                      Color(0x22A41212),
                      Colors.transparent,
                    ],
                    stops: [0.0, .28, .58, 1.0],
                  ),
                ),
              ),
            ),

            //----------------------------------------------------
            // Orange cinematic light
            //----------------------------------------------------
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: glowB,
                    radius: 2.1,
                    colors: const [
                      Color(0x66FF8A3C),
                      Color(0x22FF5A1F),
                      Colors.transparent,
                    ],
                    stops: [0.0, .42, 1.0],
                  ),
                ),
              ),
            ),

            //----------------------------------------------------
            // Purple premium glow
            //----------------------------------------------------
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.lerp(
                      const Alignment(-0.2, 0.9),
                      const Alignment(0.35, 0.6),
                      t,
                    )!,
                    radius: 1.8,
                    colors: const [
                      Color(0x553B3BFF),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            //----------------------------------------------------
            // Soft white spotlight behind hero
            //----------------------------------------------------
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -.35),
                    radius: 1.25,
                    colors: [
                      Colors.white.withValues(alpha: .08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            //----------------------------------------------------
            // Top cinematic wash
            //----------------------------------------------------
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const [
                      Color(0xCC000000),
                      Color(0x66000000),
                      Colors.transparent,
                    ],
                    stops: [0.0, .18, .7],
                  ),
                ),
              ),
            ),

            //----------------------------------------------------
            // Bottom fade
            //----------------------------------------------------
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: const [
                      Color(0xFF000000),
                      Color(0xDD000000),
                      Colors.transparent,
                    ],
                    stops: [0.0, .20, .7],
                  ),
                ),
              ),
            ),

            //----------------------------------------------------
            // Left vignette
            //----------------------------------------------------
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: const [
                      Color(0xCC000000),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            //----------------------------------------------------
            // Right vignette
            //----------------------------------------------------
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: const [
                      Color(0xCC000000),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            //----------------------------------------------------
            // Extra top glow
            //----------------------------------------------------
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0x66C62828),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            //----------------------------------------------------
            // Heavy blur
            //----------------------------------------------------
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 70,
                  sigmaY: 70,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        );
      },
    );
  }
}