import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../app/app_theme.dart';
import '../../core/data/youtube_trailers_provider.dart';
import '../../core/models/trailer.dart';
import '../../shared/widgets/popcorn_rating.dart';
import '../../shared/widgets/trailer_player.dart';
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
        return _ReelPage(
          trailer: trailer,
          isActive: isActive,
        );
      },
    );
  }
}

// ─── Reel Page ──────────────────────────────────────────────────────────────

class _ReelPage extends StatefulWidget {
  const _ReelPage({
    required this.trailer,
    required this.isActive,
  });

  final Trailer trailer;
  final bool isActive;

  @override
  State<_ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<_ReelPage> {
  YoutubePlayerController? _controller;
  int? _popcornRating;
  bool _bookmarked = false;
  bool _muted = true; // Autoplay requires mute in WebViews
  bool _playerReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _initPlayer();
    }
  }

  @override
  void didUpdateWidget(covariant _ReelPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _initPlayer();
    } else if (!widget.isActive && oldWidget.isActive) {
      _disposePlayer();
    }
  }

  void _initPlayer() {
    _controller?.close();
    _playerReady = false;
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.trailer.youtubeVideoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        mute: true, // Must be true for reliable autoplay in WebView
        playsInline: true,
        enableCaption: false,
        loop: true,
      ),
    );
    if (mounted) setState(() {});

    // Small delay then mark player as ready for smooth transition
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && widget.isActive) {
        setState(() => _playerReady = true);
      }
    });
  }

  void _disposePlayer() {
    try {
      _controller?.close();
    } catch (_) {}
    _controller = null;
    _playerReady = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    try {
      _controller?.close();
    } catch (_) {}
    super.dispose();
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    if (_muted) {
      _controller?.mute();
    } else {
      _controller?.unMute();
    }
  }

  void _openDetails() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrailerDetailsScreen(trailer: widget.trailer),
      ),
    );
  }

  Future<void> _openFullPlayer() async {
    _disposePlayer();
    await showTrailerPlayer(context, widget.trailer);
    if (mounted && widget.isActive) {
      _initPlayer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final trailer = widget.trailer;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Background: pitch black ──────────────────
        const Positioned.fill(
          child: ColoredBox(color: Colors.black),
        ),

        // ── YouTube Player (contained in a 16:9 box) ──────────
        if (_controller != null)
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _playerReady ? 1.0 : 0.0,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: IgnorePointer(
                    child: YoutubePlayer(controller: _controller!),
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
                  Colors.black.withValues(alpha: 0.8),
                  Colors.black.withValues(alpha: 0.1),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black.withValues(alpha: 0.95),
                  Colors.black,
                ],
                stops: const [0.0, 0.15, 0.5, 0.75, 0.9, 1.0],
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
              if (_controller != null && _playerReady) ...[
                GestureDetector(
                  onTap: _openFullPlayer,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: const Icon(
                      Icons.fullscreen_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              GestureDetector(
                onTap: _toggleMute,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Icon(
                    _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Bottom info + actions ───────────────────────────────────
        Positioned(
          left: 16,
          right: 16,
          bottom: bottomPad + 96, // tucked neatly above the bottom nav (80 + 16 padding)
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ── Left: Movie info (small & compact) ──────────────
              Expanded(
                child: GestureDetector(
                  onTap: _openDetails,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Studio badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          trailer.studio.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title (small)
                      Text(
                        trailer.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Tagline
                      Text(
                        trailer.tagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Genres + views row
                      Row(
                        children: [
                          ...trailer.genres.take(2).map((g) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                                  ),
                                  child: Text(
                                    g.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withValues(alpha: 0.7),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              )),
                          Text(
                            '${trailer.views} views',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.45),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ── Right: Action buttons (compact column) ──────────
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => showPopcornRating(
                      context,
                      hypeScore: trailer.hypeScore,
                      currentRating: _popcornRating,
                      onRatingChanged: (r) => setState(() => _popcornRating = r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _popcornRating != null
                                ? AppTheme.hype.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.4),
                            border: Border.all(
                              color: _popcornRating != null
                                  ? AppTheme.hype
                                  : Colors.white24,
                            ),
                          ),
                          child: const Center(
                            child: Text('🍿', style: TextStyle(fontSize: 22)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${trailer.hypeScore}%',
                          style: TextStyle(
                            color: _popcornRating != null ? AppTheme.hype : Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ReelAction(
                    icon: _bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    label: 'Save',
                    active: _bookmarked,
                    onTap: () => setState(() => _bookmarked = !_bookmarked),
                  ),
                  _ReelAction(
                    icon: Icons.mode_comment_outlined,
                    label: '12K',
                    onTap: () {},
                  ),
                  _ReelAction(
                    icon: Icons.ios_share_rounded,
                    label: 'Share',
                    onTap: () {},
                  ),
                ],
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
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Icon(
                icon,
                color: active ? AppTheme.accent : Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
