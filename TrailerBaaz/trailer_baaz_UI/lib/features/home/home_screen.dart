import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/data/home_experience_provider.dart';
import '../../core/data/youtube_trailers_provider.dart';
import '../../core/models/trailer.dart';
import '../../shared/widgets/cinematic_image.dart';
import '../../shared/widgets/popcorn_rating.dart';
import '../../shared/widgets/trailer_card.dart'
    show TrailerCard, kCardTextSectionHeight;
import '../../shared/widgets/trailer_player.dart';
import '../details/trailer_details_screen.dart';
import '../shell/app_shell.dart';
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = _provider;

    if (provider.isLoading) return const _LoadingShimmer();

    if (provider.error != null && provider.sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.white38),
            const SizedBox(height: 12),
            const Text(
              'Could not load trailers',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => provider.init(),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.accent),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final heroTrailers = provider.heroTrailers;
    final sections = provider.sections;

    if (_selectedSection != null) {
      final sectionTrailers = sections[_selectedSection] ?? [];
      return _SectionDetailView(
        sectionKey: _selectedSection!,
        trailers: sectionTrailers,
        onBack: () => _selectSection(null),
        onOpenDetails: _openDetails,
        onPlay: _playTrailer,
        onShowBrowse: _showBrowseSheet,
      );
    }

    return _CinematicHomeBody(
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
    );
  }
}
