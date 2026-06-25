import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';
import '../../../../shared/widgets/glass_surfaces.dart';
import '../../../../shared/widgets/premium_network_image.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../data/mock/home_dummy_data.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/trailer_section.dart';
import '../widgets/trending_now.dart';
import 'trailer_details_screen.dart';
import 'trailer_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _languages = <String>[
    'English',
    'Hindi',
    'Telugu',
    'Tamil',
    'Kannada',
    'Malayalam',
    'Korean',
  ];

  static const _industries = <String>['HW', 'BW', 'KR', 'TE', 'TM', 'KN'];

  String _selectedLanguage = 'English';
  int _selectedIndustry = 0;

  void _openSearch() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
  }

  void _openLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _openPreferences() {
    showPreferencesModal(context);
  }

  Future<void> _openLanguageMenu() async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu<String>(
      context: context,
      color: const Color(0xFF17171A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      position: RelativeRect.fromLTRB(overlay.size.width - 210, 88, 16, 0),
      items: _languages.map((language) {
        final active = language == _selectedLanguage;
        return PopupMenuItem<String>(
          value: language,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  language,
                  style: const TextStyle(color: AppColors.textWhite),
                ),
              ),
              if (active)
                const Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: AppColors.amber,
                ),
            ],
          ),
        );
      }).toList(),
    );

    if (selected != null && mounted) {
      setState(() => _selectedLanguage = selected);
    }
  }

  void _openTrailerPlayer(TrailerModel trailer) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TrailerPlayerScreen(trailer: trailer)),
    );
  }

  void _openTrailerDetails(TrailerModel trailer) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TrailerDetailsScreen(trailer: trailer)),
    );
  }

  List<TrailerModel> get _featured => HomeDummyData.featured;

  List<TrailerModel> get _trending =>
      HomeDummyData.byCategory('Trending').take(6).toList(growable: false);

  List<TrailerModel> get _telugu =>
      HomeDummyData.byCategory('Telugu').take(6).toList(growable: false);

  List<TrailerModel> get _hindi =>
      HomeDummyData.byCategory('Hindi').take(6).toList(growable: false);

  List<TrailerModel> get _webSeries =>
      HomeDummyData.byCategory('Web Series').take(6).toList(growable: false);

  List<TrailerModel> get _mostAwaited {
    final upcoming = HomeDummyData.upcoming.take(5).toList(growable: false);
    if (upcoming.isNotEmpty) return upcoming;
    return HomeDummyData.trailers.take(5).toList(growable: false);
  }

  List<TrailerModel> get _comingSoon {
    final upcoming = HomeDummyData.upcoming;
    if (upcoming.length > 2) {
      return upcoming.skip(2).take(6).toList(growable: false);
    }
    return HomeDummyData.trailers.take(6).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: HeroCarousel(
                  trailers: _featured,
                  onPlay: _openTrailerPlayer,
                  onDetails: _openTrailerDetails,
                  fullBleed: true,
                ),
              ),
              SliverToBoxAdapter(
                child: TrendingNow(
                  trailers: _trending,
                  onTap: _openTrailerDetails,
                ),
              ),
              SliverToBoxAdapter(
                child: _ReleaseRail(
                  title: 'MOST AWAITED',
                  subtitle: 'Big releases, high buzz, and countdown energy.',
                  trailers: _mostAwaited,
                  mode: _ReleaseRailMode.awaited,
                  onTap: _openTrailerDetails,
                ),
              ),
              SliverToBoxAdapter(
                child: _ReleaseRail(
                  title: 'COMING SOON',
                  subtitle:
                      'Compact drops, quick scans, and release dates at a glance.',
                  trailers: _comingSoon,
                  mode: _ReleaseRailMode.soon,
                  onTap: _openTrailerDetails,
                ),
              ),
              SliverToBoxAdapter(
                child: TrailerSection(
                  title: 'TELUGU',
                  subtitle: 'The latest Telugu trailers and launches.',
                  trailers: _telugu,
                  cardWidth: 276,
                  onTap: _openTrailerDetails,
                ),
              ),
              SliverToBoxAdapter(
                child: TrailerSection(
                  title: 'HINDI',
                  subtitle: 'Curated Bollywood and Hindi trailer buzz.',
                  trailers: _hindi,
                  cardWidth: 276,
                  onTap: _openTrailerDetails,
                ),
              ),
              SliverToBoxAdapter(
                child: TrailerSection(
                  title: 'WEB SERIES',
                  subtitle: 'OTT trailers, sneak peeks, and series drops.',
                  trailers: _webSeries,
                  cardWidth: 276,
                  onTap: _openTrailerDetails,
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 24 + bottomPadding)),
            ],
          ),
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: _FloatingHomeChrome(
              selectedIndustry: _selectedIndustry,
              industries: _industries,
              onSearch: _openSearch,
              onLanguage: _openLanguageMenu,
              onPreferences: _openPreferences,
              onLogin: _openLogin,
              onIndustrySelected: (index) {
                if (_selectedIndustry == index) return;
                setState(() => _selectedIndustry = index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingHomeChrome extends StatelessWidget {
  final List<String> industries;
  final int selectedIndustry;
  final VoidCallback onSearch;
  final VoidCallback onLanguage;
  final VoidCallback onPreferences;
  final VoidCallback onLogin;
  final ValueChanged<int> onIndustrySelected;

  const _FloatingHomeChrome({
    required this.industries,
    required this.selectedIndustry,
    required this.onSearch,
    required this.onLanguage,
    required this.onPreferences,
    required this.onLogin,
    required this.onIndustrySelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xCC0D0D0F), Color(0x330D0D0F), Color(0x000D0D0F)],
              stops: [0.0, 0.70, 1.0],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeaderRow(
                    onSearch: onSearch,
                    onLanguage: onLanguage,
                    onPreferences: onPreferences,
                    onLogin: onLogin,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 34,
                    child: _IndustryPills(
                      selectedIndex: selectedIndustry,
                      industries: industries,
                      onSelected: onIndustrySelected,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final VoidCallback onSearch;
  final VoidCallback onLanguage;
  final VoidCallback onPreferences;
  final VoidCallback onLogin;

  const _HeaderRow({
    required this.onSearch,
    required this.onLanguage,
    required this.onPreferences,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/images/trailerbaaz_logo.png',
              width: 88,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _HeaderIconButton(icon: Icons.search_rounded, onTap: onSearch),
        _HeaderIconButton(icon: Icons.language_rounded, onTap: onLanguage),
        _HeaderIconButton(icon: Icons.tune_rounded, onTap: onPreferences),
        const SizedBox(width: 8),
        _PressablePill(
          onTap: onLogin,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IndustryPills extends StatelessWidget {
  final List<String> industries;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _IndustryPills({
    required this.industries,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: industries.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final active = index == selectedIndex;
        return _PressablePill(
          onTap: () => onSelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.amber
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: active
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.10),
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.amber.withValues(alpha: 0.24),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              industries[index],
              style: TextStyle(
                color: active ? AppColors.background : AppColors.textGrey,
                fontSize: 11,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GlassIconButton(
        size: 36,
        padding: const EdgeInsets.all(8),
        icon: Icon(icon, size: 18, color: AppColors.textWhite),
        onTap: onTap,
      ),
    );
  }
}

class _PressablePill extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressablePill({required this.child, required this.onTap});

  @override
  State<_PressablePill> createState() => _PressablePillState();
}

class _PressablePillState extends State<_PressablePill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

enum _ReleaseRailMode { awaited, soon }

class _ReleaseRail extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<TrailerModel> trailers;
  final _ReleaseRailMode mode;
  final ValueChanged<TrailerModel> onTap;

  const _ReleaseRail({
    required this.title,
    required this.subtitle,
    required this.trailers,
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (trailers.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isAwaited = mode == _ReleaseRailMode.awaited;
    final cardHeight = isAwaited ? 224.0 : 118.0;
    final cardWidth = isAwaited
        ? (screenWidth * 0.42).clamp(148.0, 176.0).toDouble()
        : (screenWidth * 0.78).clamp(286.0, 346.0).toDouble();

    return Padding(
      padding: EdgeInsets.only(top: isAwaited ? 22 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeSectionHeading(
            title: title,
            subtitle: subtitle,
            color: isAwaited ? AppColors.amber : AppColors.textWhite,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: trailers.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final trailer = trailers[index];
                if (isAwaited) {
                  return _AwaitedPosterCard(
                    trailer: trailer,
                    width: cardWidth,
                    onTap: () => onTap(trailer),
                  );
                }

                return _ComingSoonWideCard(
                  trailer: trailer,
                  width: cardWidth,
                  onTap: () => onTap(trailer),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _HomeSectionHeading({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 2.4,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textGrey.withValues(alpha: 0.68),
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _AwaitedPosterCard extends StatelessWidget {
  final TrailerModel trailer;
  final double width;
  final VoidCallback onTap;

  const _AwaitedPosterCard({
    required this.trailer,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final seed = _seed(trailer);
    final countdown = 3 + (seed % 18);
    final hype = 74 + (seed % 22);
    final views = 140 + (seed % 860);

    return _TapCard(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              PremiumNetworkImage(url: trailer.imageUrl),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.40, 0.72, 1.0],
                    colors: [
                      Color(0x30000000),
                      Colors.transparent,
                      Color(0x99000000),
                      Color(0xF0000000),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 8,
                top: 8,
                child: _SmallBadge(label: '$countdown DAYS', filled: true),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trailer.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 13,
                        height: 1.06,
                        fontWeight: FontWeight.w800,
                        shadows: [Shadow(color: Colors.black, blurRadius: 12)],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _SmallBadge(label: trailer.language.toUpperCase()),
                        _SmallBadge(label: 'HYPE $hype'),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${views}K views',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textGrey.withValues(alpha: 0.86),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.card_giftcard_rounded,
                          color: AppColors.amber,
                          size: 18,
                        ),
                      ],
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

class _ComingSoonWideCard extends StatelessWidget {
  final TrailerModel trailer;
  final double width;
  final VoidCallback onTap;

  const _ComingSoonWideCard({
    required this.trailer,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final seed = _seed(trailer);
    final daysLeft = 2 + (seed % 15);
    final views = 120 + (seed % 880);

    return _TapCard(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              PremiumNetworkImage(url: trailer.imageUrl),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1.2, sigmaY: 1.2),
                child: const SizedBox.expand(),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xEE0D0D0F),
                      Color(0xB80D0D0F),
                      Color(0x210D0D0F),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 12,
                bottom: 12,
                width: 74,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: PremiumNetworkImage(url: trailer.imageUrl),
                ),
              ),
              Positioned(
                left: 98,
                right: 48,
                top: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      trailer.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 14,
                        height: 1.08,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Row(
                      children: [
                        _SmallBadge(label: trailer.language.toUpperCase()),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '$daysLeft days left',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textGrey.withValues(alpha: 0.82),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${views}K views',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textGrey.withValues(alpha: 0.78),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                right: 12,
                bottom: 12,
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.amber,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final bool filled;

  const _SmallBadge({required this.label, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: filled ? AppColors.amber : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: filled
              ? Colors.transparent
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? AppColors.background : AppColors.textWhite,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _TapCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TapCard({required this.child, required this.onTap});

  @override
  State<_TapCard> createState() => _TapCardState();
}

class _TapCardState extends State<_TapCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

int _seed(TrailerModel trailer) =>
    trailer.title.codeUnits.fold<int>(0, (sum, code) => sum + code);
