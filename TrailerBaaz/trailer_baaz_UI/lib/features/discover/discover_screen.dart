import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/data/youtube_trailers_provider.dart';
import '../../core/models/trailer.dart';
import '../../shared/widgets/popcorn_rating.dart';
import '../../shared/trailer_player/trailer_player_feed.dart';
import '../details/trailer_details_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with AutomaticKeepAliveClientMixin {
  PageController? _pageController;
  int _currentPage = 0;
  final _provider = YoutubeTrailersProvider.instance;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _provider.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _provider.removeListener(_onDataChanged);
    try {
      _pageController?.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = YoutubeTrailersProvider.instance;
    // Combine all available trailers or fallback to heroTrailers
    final allTrailers = provider.heroTrailers;

    if (allTrailers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accent),
      );
    }

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: allTrailers.length * 20,
      onPageChanged: (index) {
        setState(() => _currentPage = index);
      },
      itemBuilder: (context, index) {
        final trailer = allTrailers[index % allTrailers.length];
        final isActive = index == _currentPage;
        return _ReelPage(trailer: trailer, isActive: isActive);
      },
    );
  }
}

// ─── Reel Page ──────────────────────────────────────────────────────────────

class _ReelPage extends StatefulWidget {
  const _ReelPage({required this.trailer, required this.isActive});

  final Trailer trailer;
  final bool isActive;

  @override
  State<_ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<_ReelPage> {
  int? _popcornRating;
  bool _bookmarked = false;

  void _openDetails() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrailerDetailsScreen(trailer: widget.trailer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trailer = widget.trailer;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0, -0.25),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOut,
              tween: Tween(begin: 1.15, end: 1.10),
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: TrailerPlayerFeed(
                  trailer: trailer,
                  active: widget.isActive,
                  onInfo: _openDetails,
                ),
              ),
            ),
          ),
        ),

        // ── Gradient overlays (blends video edges and boosts text contrast) ──
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: .85),
                  Colors.black.withValues(alpha: .15),
                  Colors.transparent,
                  Colors.black.withValues(alpha: .25),
                  Colors.black.withValues(alpha: .65),
                  Colors.black.withValues(alpha: .92),
                  Colors.black,
                ],
                stops: const [0.0, 0.12, 0.45, 0.68, 0.82, 0.92, 1.0],
              ),
            ),
          ),
        ),

        // ── Top bar (Discover label + mute) ─────────────────────────
        Positioned(
          top: MediaQuery.paddingOf(context).top + 12,
          left: 20,
          right: 20,
          child: Row(
            children: [
              const Text(
                'Discover',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),

        // ── Bottom info + actions ───────────────────────────────────
        // ── Bottom Movie Info + Horizontal Actions ─────────────────────────────
        // ───────────────── Bottom Movie Info ─────────────────
        //──────────────── Movie Details ────────────────
        Positioned(
          left: 16,
          right: 90,
          bottom: bottomPad + 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  trailer.studio.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                trailer.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                trailer.tagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .75),
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                "${trailer.genres.take(2).join(" • ")} • ${trailer.views} Views",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .5),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),

        //──────────────── Instagram Style Actions ────────────────
        Positioned(
          right: 14,
          bottom: bottomPad + 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ReelAction(
                emoji: "🍿",
                label: "${trailer.hypeScore}%",
                onTap: () => showPopcornRating(
                  context,
                  hypeScore: trailer.hypeScore,
                  currentRating: _popcornRating,
                  onRatingChanged: (r) => setState(() => _popcornRating = r),
                ),
              ),

              const SizedBox(height: 16),

              _ReelAction(
                icon: _bookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                label: "Save",
                active: _bookmarked,
                onTap: () => setState(() => _bookmarked = !_bookmarked),
              ),

              const SizedBox(height: 16),

              _ReelAction(
                icon: Icons.mode_comment_outlined,
                label: "12K",
                onTap: () {},
              ),

              const SizedBox(height: 16),

              _ReelAction(
                icon: Icons.ios_share_rounded,
                label: "Share",
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Compact Reel Action Button ─────────────────────────────────────────────

class _ReelAction extends StatelessWidget {
  const _ReelAction({
    this.icon,
    this.emoji,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData? icon;
  final String? emoji;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? AppTheme.accent.withValues(alpha: .16)
                    : Colors.white.withValues(alpha: .05),
                border: Border.all(
                  color: active
                      ? AppTheme.accent.withValues(alpha: .7)
                      : Colors.white.withValues(alpha: .08),
                ),
              ),
              child: Center(
                child: emoji != null
                    ? Text(emoji!, style: const TextStyle(fontSize: 18))
                    : Icon(
                        icon,
                        color: active ? AppTheme.accent : Colors.white,
                        size: 18,
                      ),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: .70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
