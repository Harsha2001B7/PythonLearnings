import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/data/youtube_trailers_provider.dart';
import '../../core/models/trailer.dart';
import '../../shared/widgets/cinematic_image.dart';

import '../../shared/widgets/meta_widgets.dart';

import '../../shared/widgets/trailer_card.dart' show TrailerCard, kCardTextSectionHeight;
import '../../shared/widgets/trailer_player.dart';
import '../details/trailer_details_screen.dart';
import '../shell/app_shell.dart';

// ─── Section Categories Configuration ────────────────────────────────────────

const _browseCategories = [
  _BrowseCategory(
    label: 'Trending Now',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFFF6B35),
    sectionKey: 'Trending Now',
  ),
  _BrowseCategory(
    label: 'Most Awaited',
    icon: Icons.star_rounded,
    color: Color(0xFFFFD700),
    sectionKey: 'Most Awaited',
  ),
  _BrowseCategory(
    label: 'Coming Soon',
    icon: Icons.schedule_rounded,
    color: Color(0xFF7C3AED),
    sectionKey: 'Coming Soon',
  ),
];

const _languageCategories = [
  _BrowseCategory(
    label: 'Hollywood',
    icon: Icons.movie_rounded,
    color: Color(0xFF3B82F6),
    sectionKey: 'Hollywood',
    flag: '🎬',
  ),
  _BrowseCategory(
    label: 'Bollywood',
    icon: Icons.music_note_rounded,
    color: Color(0xFFEC4899),
    sectionKey: 'Bollywood',
    flag: '🇮🇳',
  ),
  _BrowseCategory(
    label: 'Telugu',
    icon: Icons.videocam_rounded,
    color: Color(0xFF10B981),
    sectionKey: 'Telugu',
    flag: '🎭',
  ),
  _BrowseCategory(
    label: 'Tamil',
    icon: Icons.theater_comedy_rounded,
    color: Color(0xFFF59E0B),
    sectionKey: 'Tamil',
    flag: '🎥',
  ),
  _BrowseCategory(
    label: 'Korean',
    icon: Icons.subtitles_rounded,
    color: Color(0xFF06B6D4),
    sectionKey: 'Korean',
    flag: '🇰🇷',
  ),
  _BrowseCategory(
    label: 'OTT Originals',
    icon: Icons.play_circle_rounded,
    color: Color(0xFF8B5CF6),
    sectionKey: 'OTT Originals',
    flag: '🌐',
  ),
];

@immutable
class _BrowseCategory {
  final String label;
  final IconData icon;
  final Color color;
  final String sectionKey;
  final String? flag;

  const _BrowseCategory({
    required this.label,
    required this.icon,
    required this.color,
    required this.sectionKey,
    this.flag,
  });
}

// ─── Home Screen ─────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  PageController? _heroController;
  Timer? _timer;
  int _page = 1000;

  String? _selectedSection;

  final _provider = YoutubeTrailersProvider.instance;

  @override
  void initState() {
    super.initState();
    _heroController = PageController(initialPage: _page);
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || _heroController?.hasClients != true) return;
      _heroController?.nextPage(
        duration: const Duration(milliseconds: 640),
        curve: Curves.easeOutCubic,
      );
    });
    _provider.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    try {
      _timer?.cancel();
      _heroController?.dispose();
    } catch (_) {}
    _provider.removeListener(_onDataChanged);
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
            const Text('Could not load trailers',
                style: TextStyle(color: Colors.white54)),
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
                    controller: _heroController,
                    onPageChanged: (v) => setState(() => _page = v),
                    itemBuilder: (context, index) {
                      final trailer =
                          heroTrailers[index % heroTrailers.length];
                      return _HeroSlide(
                        trailer: trailer,
                        onOpen: () => _openDetails(trailer),
                        onPlay: () => _playTrailer(trailer),
                      );
                    },
                  ),
                Positioned(
                  left: 22,
                  right: 22,
                  top: MediaQuery.paddingOf(context).top + 10,
                  child: const _TopBar(),
                ),
                if (heroTrailers.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 18,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(heroTrailers.length, (index) {
                        final selected =
                            _page % heroTrailers.length == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin:
                              const EdgeInsets.symmetric(horizontal: 4),
                          width: selected ? 24 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color:
                                selected ? Colors.white : Colors.white24,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _QuickCategoryBar(
            onShowBrowse: _showBrowseSheet,
            onSelect: _selectSection,
          ),
        ),
        SliverPadding(
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
              return _TrailerRail(
                title: entry.key,
                trailers: entry.value,
                onTap: _openDetails,
                onPlay: _playTrailer,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Quick Category Bar ──────────────────────────────────────────────────────

class _QuickCategoryBar extends StatelessWidget {
  const _QuickCategoryBar({
    required this.onShowBrowse,
    required this.onSelect,
  });

  final VoidCallback onShowBrowse;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final allCats = [..._browseCategories, ..._languageCategories];

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Browse',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onShowBrowse,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
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
                          'All Categories',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
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
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: allCats.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = allCats[i];
                return GestureDetector(
                  onTap: () => onSelect(cat.sectionKey),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cat.color.withValues(alpha: 0.25),
                          cat.color.withValues(alpha: 0.12),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: cat.color.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (cat.flag != null) ...[
                          Text(cat.flag!,
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 5),
                        ] else ...[
                          Icon(cat.icon, color: cat.color, size: 13),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          cat.label,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Browse Bottom Sheet ──────────────────────────────────────────────────────

class _BrowseSheet extends StatelessWidget {
  const _BrowseSheet({
    required this.onSelect,
    required this.selectedSection,
    required this.loadedSections,
  });

  final ValueChanged<String> onSelect;
  final String? selectedSection;
  final Set<String> loadedSections;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.45, 0.72, 0.92],
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0D1117).withValues(alpha: 0.96),
                    const Color(0xFF070A11).withValues(alpha: 0.98),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
              ),
              child: ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + 20,
                ),
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 20),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.accent,
                                AppTheme.accent.withValues(alpha: 0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Browse',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _SheetSectionHeader(label: 'DISCOVER'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      children: _browseCategories.map((cat) {
                        final isSelected = selectedSection == cat.sectionKey;
                        final isLoaded = loadedSections.contains(cat.sectionKey);
                        return _SheetCategoryTile(
                          category: cat,
                          isSelected: isSelected,
                          isLoaded: isLoaded,
                          onTap: () => onSelect(cat.sectionKey),
                        );
                      }).toList(),
                    ),
                  ),
                  const _SheetSectionHeader(label: 'POPULAR LANGUAGES'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.4,
                      children: _languageCategories.map((cat) {
                        final isSelected = selectedSection == cat.sectionKey;
                        final isLoaded = loadedSections.contains(cat.sectionKey);
                        return _SheetLanguageTile(
                          category: cat,
                          isSelected: isSelected,
                          isLoaded: isLoaded,
                          onTap: () => onSelect(cat.sectionKey),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SheetSectionHeader extends StatelessWidget {
  const _SheetSectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _SheetCategoryTile extends StatelessWidget {
  const _SheetCategoryTile({
    required this.category,
    required this.isSelected,
    required this.isLoaded,
    required this.onTap,
  });

  final _BrowseCategory category;
  final bool isSelected;
  final bool isLoaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [
                    category.color.withValues(alpha: 0.35),
                    category.color.withValues(alpha: 0.18),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.05),
                    Colors.white.withValues(alpha: 0.02),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? category.color.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category.icon, color: category.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                category.label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.85),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (isLoaded)
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_ios_rounded,
                color: isSelected
                    ? category.color
                    : Colors.white.withValues(alpha: 0.3),
                size: isSelected ? 20 : 14,
              ),
          ],
        ),
      ),
    );
  }
}

class _SheetLanguageTile extends StatelessWidget {
  const _SheetLanguageTile({
    required this.category,
    required this.isSelected,
    required this.isLoaded,
    required this.onTap,
  });

  final _BrowseCategory category;
  final bool isSelected;
  final bool isLoaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    category.color.withValues(alpha: 0.45),
                    category.color.withValues(alpha: 0.2),
                  ]
                : [
                    category.color.withValues(alpha: 0.15),
                    category.color.withValues(alpha: 0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? category.color.withValues(alpha: 0.7)
                : category.color.withValues(alpha: 0.25),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -4,
              bottom: -4,
              child: Text(
                category.flag ?? '',
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Text(
                    category.flag ?? '',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category.label,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 10,
                child: Icon(Icons.check_circle_rounded,
                    color: category.color, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Detail View ──────────────────────────────────────────────────────

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
    final cat = [
      ..._browseCategories,
      ..._languageCategories,
    ].firstWhere(
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
                            horizontal: 14, vertical: 8),
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
                            Icon(Icons.keyboard_arrow_up_rounded,
                                color: AppTheme.accent, size: 18),
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
                              child: Text(cat.flag!,
                                  style: const TextStyle(fontSize: 26)),
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
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.movie_filter_rounded,
                      size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text(
                    'No trailers available',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            sliver: SliverList.separated(
              itemCount: trailers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final trailer = trailers[index];
                return _LandscapeTrailerTile(
                  trailer: trailer,
                  onTap: () => onOpenDetails(trailer),
                  onPlay: () => onPlay(trailer),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ─── Landscape Trailer Tile ───────────────────────────────────────────────────

class _LandscapeTrailerTile extends StatelessWidget {
  const _LandscapeTrailerTile({
    required this.trailer,
    required this.onTap,
    required this.onPlay,
  });

  final Trailer trailer;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF111520),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CinematicImage(
              url: trailer.youtubeThumbnailUrl,
              alignment: Alignment.center,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xE6000000),
                    Color(0x44000000),
                    Color(0x11000000),
                  ],
                  stops: [0, 0.5, 1.0],
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xCC000000), Colors.transparent],
                  ),
                ),
                child: SizedBox(height: 80, width: double.infinity),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (trailer.studio.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: AppTheme.accent
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              trailer.studio.toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.accent,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        Text(
                          trailer.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              trailer.genres.take(2).join(' · '),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (trailer.runtime.isNotEmpty) ...[
                              Text(
                                ' • ',
                                style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.3)),
                              ),
                              Text(
                                trailer.runtime,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.55),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onPlay,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withValues(alpha: 0.45),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
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

// ─── Loading shimmer ────────────────────────────────────────────────────────

class _LoadingShimmer extends StatefulWidget {
  const _LoadingShimmer();

  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl!, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    try {
      _ctrl?.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final shimmerColor = Color.lerp(
          const Color(0xFF1A1A1A),
          const Color(0xFF2A2A2A),
          _anim.value,
        )!;
        return CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                height: MediaQuery.sizeOf(context).height * .54,
                color: shimmerColor,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
              sliver: SliverList.builder(
                itemCount: 4,
                itemBuilder: (_, _) => Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        height: 16,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 166,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 3,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 14),
                          itemBuilder: (_, _) => Container(
                            width: 260,
                            height: 166,
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Top Bar ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    const logoStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.5,
    );
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Trailer', style: logoStyle.copyWith(color: Colors.white)),
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'Baaz',
                  style: logoStyle.copyWith(
                    color: AppTheme.accent.withValues(alpha: 0.35),
                    shadows: [
                      Shadow(
                        color: AppTheme.accent.withValues(alpha: 0.65),
                        blurRadius: 12,
                      ),
                      Shadow(
                        color: AppTheme.accent.withValues(alpha: 0.3),
                        blurRadius: 28,
                      ),
                    ],
                  ),
                ),
                Text(
                  'Baaz',
                  style: logoStyle.copyWith(
                    color: AppTheme.accent,
                    shadows: [
                      Shadow(
                        color: AppTheme.accent.withValues(alpha: 0.4),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => AppShell.setIndex(context, 4),
          child: ClipOval(
            child: SizedBox(
              width: 38,
              height: 38,
              child: CinematicImage(
                url:
                    'https://images.unsplash.com/photo-1527980965255-d3b416303d12?auto=format&fit=crop&w=200&q=80',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Hero Slide ─────────────────────────────────────────────────────────────

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
          // Thumbnail is clipped to start below the app header area
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
          // Curved header blur — upside-down arc matching the bottom nav curve
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
          // Glowing arc line matching bottom nav style
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
                          const Text('•', style: TextStyle(color: AppTheme.muted, fontSize: 9)),
                          Text(
                            trailer.runtime,
                            style: const TextStyle(color: AppTheme.muted, fontSize: 9),
                          ),
                          const Text('•', style: TextStyle(color: AppTheme.muted, fontSize: 9)),
                          HypeLabel(score: trailer.hypeScore, compact: true),
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

// ─── Trending Stacked Rail ───────────────────────────────────────────────────

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
  // Simple fractional page tracker – NOT tied to PageController so no gesture conflicts
  double _page = 0.0;

  // Used only for the snap animation after drag ends
  AnimationController? _snapCtrl;
  Animation<double>? _snapAnim;

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(
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

  // ─── Gesture handlers (no PageController involved) ──────────────────────────

  void _onDragUpdate(DragUpdateDetails details) {
    if (_snapCtrl?.isAnimating == true) _snapCtrl?.stop();
    final double delta = -(details.primaryDelta ?? 0);
    setState(() {
      _page += delta / _cardWidth(context);
      // Allow large range so infinite loop works; trailer index computed via modulo
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0;
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

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.trailers.isEmpty) return const SizedBox();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth * 0.82;
    // imageHeight = 16:9; cardHeight = image + text strip (for front card layout)
    final double imageHeight = cardWidth * (9 / 16);
    final double cardHeight = imageHeight + kCardTextSectionHeight;
    final int currentIndex = _page.floor();

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
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

          // Card stack — GestureDetector owns ALL horizontal drag
          GestureDetector(
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: cardHeight + 20,
              child: Stack(
                clipBehavior: Clip.none,
                // Render background cards first (behind), front card last (on top)
                children: [
                  for (int offset = 3; offset >= 0; offset--)
                    _buildCard(currentIndex + offset, cardWidth, cardHeight, imageHeight),
                  // Also render the card going off-screen to the left
                  _buildCard(currentIndex - 1, cardWidth, cardHeight, imageHeight),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index, double cardWidth, double cardHeight, double imageHeight) {
    final double diff = index - _page;

    // Only render what is visible: max 3 cards stacked behind, 1 flying left
    if (diff <= -1.5 || diff >= 3.5) return const SizedBox.shrink();

    // ── Transform math ────────────────────────────────────────────────────────
    const double scaleStep = 0.06;
    final double peekWidth = MediaQuery.sizeOf(context).width * 0.055;
    final double translationStep = cardWidth * scaleStep + peekWidth;

    double scale;
    double translateX;
    double dimAlpha; // used for shadow + overlay, NOT Opacity widget

    if (diff <= 0) {
      // Card is departing to the left
      scale = (1.0 + diff * 0.03).clamp(0.8, 1.0);
      translateX = diff * MediaQuery.sizeOf(context).width * 0.88;
      dimAlpha = 0.0; // front card is fully bright
    } else {
      // Card is stacked behind the front
      scale = (1.0 - diff * scaleStep).clamp(0.0, 1.0);
      translateX = diff * translationStep;
      dimAlpha = (diff * 0.32).clamp(0.0, 0.80);
    }

    final bool isFront = diff.abs() < 0.5;
    final int trailerIndex =
        (index % widget.trailers.length + widget.trailers.length) %
            widget.trailers.length;
    final trailer = widget.trailers[trailerIndex];
    // For background cards, only show the image portion (no text strip)
    final double renderHeight = isFront ? cardHeight : imageHeight;

    // ── Render ────────────────────────────────────────────────────────────────
    return Positioned(
      left: 20,
      top: 10,
      bottom: 10,
      child: Transform(
        transform: Matrix4.translationValues(translateX, 0.0, 0.0)
            * Matrix4.diagonal3Values(scale, scale, 1.0),
        alignment: Alignment.centerLeft,
        child: IgnorePointer(
          ignoring: !isFront,
          child: DecoratedBox(
            // Shadow is part of DecoratedBox, NOT inside Opacity →
            // avoids the Impeller "SetInheritedOpacity" error
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: isFront
                  ? [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: (0.5 * (1 - dimAlpha)).clamp(0.0, 0.5)),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: (0.25 * (1 - dimAlpha)).clamp(0.0, 0.25)),
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
                // Dim overlay for background cards — no Opacity widget used
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

// ─── Trailer Rail ───────────────────────────────────────────────────────────

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
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'See All',
                    style: TextStyle(color: AppTheme.muted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final double railCardWidth = MediaQuery.sizeOf(context).width * 0.74;
              final double imageH = railCardWidth * (9 / 16);
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

// ─── Header Curve Clipper ────────────────────────────────────────────────────

/// Clips a region shaped like an upside-down arch of the bottom navigation bar.
/// The top is flat (full width) and the bottom edge curves down in the center.
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
        size.width / 2, headerHeight + curveDepth,
        0, headerHeight,
      )
      ..close();
    return path;
  }

  @override
  bool shouldReclip(_HeaderCurveClipper old) =>
      old.headerHeight != headerHeight || old.curveDepth != curveDepth;
}

// ─── Header Arc Painter ──────────────────────────────────────────────────────

/// Paints a glowing arc line at the bottom of the header — mirrors the bottom nav glow.
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
        size.width / 2, headerHeight + curveDepth,
        size.width, headerHeight,
      );

    final gradient = const LinearGradient(
      colors: [
        Colors.transparent,
        Color(0xFFE50914),
        Colors.transparent,
      ],
      stops: [0.0, 0.5, 1.0],
    );
    final rect = Rect.fromLTWH(0, headerHeight - 20, size.width, curveDepth + 40);

    // Glowing blurred arc
    canvas.drawPath(
      path,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Sharp inner core line
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
