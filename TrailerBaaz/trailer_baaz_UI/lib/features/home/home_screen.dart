import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/data/dummy_trailers.dart';
import '../../core/models/trailer.dart';
import '../../shared/widgets/cinematic_image.dart';
import '../../shared/widgets/glass_icon_button.dart';
import '../../shared/widgets/meta_widgets.dart';
import '../../shared/widgets/trailer_action_button.dart';
import '../../shared/widgets/trailer_card.dart';
import '../details/trailer_details_screen.dart';
import '../shell/app_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _heroController;
  late final Timer _timer;
  int _page = 1000;

  @override
  void initState() {
    super.initState();
    _heroController = PageController(initialPage: _page);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_heroController.hasClients) return;
      _heroController.nextPage(
        duration: const Duration(milliseconds: 640),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _heroController.dispose();
    super.dispose();
  }

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
                PageView.builder(
                  controller: _heroController,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, index) {
                    final trailer = trailers[index % trailers.length];
                    return _HeroSlide(
                      trailer: trailer,
                      onOpen: () => _openDetails(trailer),
                    );
                  },
                ),
                Positioned(
                  left: 22,
                  right: 22,
                  top: MediaQuery.paddingOf(context).top + 10,
                  child: const _TopBar(),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 18,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(trailers.length, (index) {
                      final selected = _page % trailers.length == index;
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
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 96),
          sliver: SliverList.builder(
            itemCount: homeSections.length,
            itemBuilder: (context, index) {
              final entry = homeSections.entries.elementAt(index);
              return _TrailerRail(
                title: entry.key,
                trailers: entry.value,
                onTap: _openDetails,
              );
            },
          ),
        ),
      ],
    );
  }
}

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
        // Same glowing TrailerBaaz logo as splash screen
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Trailer', style: logoStyle.copyWith(color: Colors.white)),
            Stack(
              alignment: Alignment.center,
              children: [
                // glow layer
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
                // sharp top layer
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

class _HeroSlide extends StatelessWidget {
  const _HeroSlide({required this.trailer, required this.onOpen});

  final Trailer trailer;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return GestureDetector(
      onTap: onOpen,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'backdrop-${trailer.id}',
            child: CinematicImage(
              url: trailer.backdropUrl,
              alignment: Alignment.topCenter,
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x55000000),
                  Color(0x11000000),
                  Color(0xD9000000),
                  AppTheme.background,
                ],
                stops: [0, .32, .72, 1],
              ),
            ),
          ),
          Positioned(
            left: 28,
            right: 28,
            bottom: 52,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .62),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    trailer.studio.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  trailer.title.toUpperCase(),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width < 380 ? 34 : 40,
                    height: .94,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '"${trailer.tagline}"',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 9,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      trailer.genres.take(2).join(' / '),
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text('•', style: TextStyle(color: AppTheme.muted)),
                    Text(
                      trailer.runtime,
                      style: const TextStyle(color: AppTheme.muted),
                    ),
                    const Text('•', style: TextStyle(color: AppTheme.muted)),
                    HypeLabel(score: trailer.hypeScore, compact: true),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    TrailerActionButton(
                      label: 'Watch Trailer',
                      icon: Icons.play_arrow_rounded,
                      onPressed: onOpen,
                      expanded: true,
                    ),
                    const SizedBox(width: 14),
                    GlassIconButton(
                      icon: Icons.bookmark_border_rounded,
                      tooltip: 'Bookmark',
                      onPressed: () {},
                    ),
                    const SizedBox(width: 10),
                    GlassIconButton(
                      icon: Icons.ios_share_rounded,
                      tooltip: 'Share',
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrailerRail extends StatelessWidget {
  const _TrailerRail({
    required this.title,
    required this.trailers,
    required this.onTap,
  });

  final String title;
  final List<Trailer> trailers;
  final ValueChanged<Trailer> onTap;

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
                      // accent left-bar indicator
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
          SizedBox(
            height: 166,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: trailers.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) => TrailerCard(
                trailer: trailers[index],
                onTap: () => onTap(trailers[index]),
                width: MediaQuery.sizeOf(context).width * .72,
                height: 166,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
