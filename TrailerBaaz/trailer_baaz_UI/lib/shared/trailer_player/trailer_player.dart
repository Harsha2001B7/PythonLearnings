import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../app/app_theme.dart';
import '../../core/models/trailer.dart';
import '../../features/details/trailer_details_screen.dart';
import 'trailer_player_buttons.dart';
import 'trailer_player_controller.dart';
import 'trailer_player_fullscreen.dart';
import 'trailer_player_state.dart';

_TrailerPlayerScreenState? _activePlayer;
Future<void>? _activePlayerFuture;

Future<void> showTrailerPlayer(BuildContext context, Trailer trailer, {bool startFullscreen = false}) async {
  final launchedFromDetails = context
      .findAncestorWidgetOfExactType<TrailerDetailsScreen>();
  final launchedFromDetailsId = launchedFromDetails?.trailer.id;

  if (_activePlayer != null) {
    await _activePlayer!._replaceTrailer(trailer, launchedFromDetailsId);
    return _activePlayerFuture;
  }

  final route = TrailerPlayerRoute(
    trailerId: trailer.id,
    builder: (_) => _TrailerPlayerScreen(
      trailer: trailer,
      launchedFromDetailsId: launchedFromDetailsId,
      startFullscreen: startFullscreen,
    ),
  );

  _activePlayerFuture = Navigator.of(context, rootNavigator: true).push(route);
  try {
    await _activePlayerFuture;
  } finally {
    _activePlayerFuture = null;
  }
}

class _TrailerPlayerScreen extends StatefulWidget {
  const _TrailerPlayerScreen({
    required this.trailer,
    required this.launchedFromDetailsId,
    this.startFullscreen = false,
  });

  final Trailer trailer;
  final String? launchedFromDetailsId;
  final bool startFullscreen;

  @override
  State<_TrailerPlayerScreen> createState() => _TrailerPlayerScreenState();
}

class _TrailerPlayerScreenState extends State<_TrailerPlayerScreen> {
  late final TrailerPlayerController _controller;
  String? _launchedFromDetailsId;
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    _activePlayer = this;
    _launchedFromDetailsId = widget.launchedFromDetailsId;
    _controller = TrailerPlayerController(widget.trailer);

    if (widget.startFullscreen) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      await _controller.enterFullscreen();
    });
  }
  }

  Future<void> _replaceTrailer(
    Trailer trailer,
    String? launchedFromDetailsId,
  ) async {
    _launchedFromDetailsId = launchedFromDetailsId;
    await _controller.replaceTrailer(trailer);
  }

  @override
  void dispose() {
    if (_activePlayer == this) _activePlayer = null;
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBack() async {
    if (_controller.state.isFullscreen) {
      await _controller.exitFullscreen();
      return;
    }
    await _closePlayer();
  }

  Future<void> _closePlayer() async {
    await _controller.restorePortraitChrome();
    if (!mounted) return;
    setState(() => _allowPop = true);
    Navigator.of(context).pop();
  }

  Future<void> _openInfo() async {
    final trailer = _controller.state.trailer;
    await _controller.exitFullscreen();
    if (!mounted) return;

    setState(() => _allowPop = true);
    if (_launchedFromDetailsId == trailer.id) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TrailerDetailsScreen(trailer: trailer)),
    );
  }

  Future<void> _toggleFullscreen() async {
    if (_controller.state.isFullscreen) {
      await _controller.exitFullscreen();
    } else {
      await _controller.enterFullscreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final state = _controller.state;
              return _EmbeddedPlayerView(
                controller: _controller,
                state: state,
                onClose: _closePlayer,
                onInfo: _openInfo,
                onFullscreen: _toggleFullscreen,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmbeddedPlayerView extends StatelessWidget {
  const _EmbeddedPlayerView({
    required this.controller,
    required this.state,
    required this.onClose,
    required this.onInfo,
    required this.onFullscreen,
  });

  final TrailerPlayerController controller;
  final TrailerPlayerState state;
  final VoidCallback onClose;
  final VoidCallback onInfo;
  final VoidCallback onFullscreen;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
  children: [
    _RoundHeaderButton(
      icon: Icons.close_rounded,
      tooltip: 'Close',
      onPressed: onClose,
    ),
    Expanded(
      child: Text(
        state.trailer.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  ],
),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(
                  key: const ValueKey('trailer-player'),
                  controller: controller.youtubeController,
                  aspectRatio: 16 / 9,
                  backgroundColor: Colors.black,
                  autoFullScreen: false,
                  enableFullScreenOnVerticalDrag: false,
                  keepAlive: true,
                  controlsBuilder: (context, isFullscreen) {
                    if (!isFullscreen) return const SizedBox.shrink();
                    return SafeArea(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12, top: 12),
                          child: TrailerPlayerIconButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            tooltip: 'Exit fullscreen',
                            onPressed: onFullscreen,
                          ),
                        ),
                      ),
                    );
                  },
                  initParams: const YoutubePlayerParams(
                    showControls: true,
                    showFullscreenButton: false,
                    mute: false,
                    playsInline: true,
                    enableCaption: true,
                    strictRelatedVideos: true,
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Text(
              state.trailer.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                height: 1.12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                if (state.trailer.studio.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.32),
                      ),
                    ),
                    child: Text(
                      state.trailer.studio.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                if (state.trailer.studio.isNotEmpty) const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${state.trailer.views} views',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.start,
              children: [
                _TrailerActionButton(
                  icon: Icons.info_outline_rounded,
                  label: 'Info',
                  tooltip: 'Trailer info',
                  onPressed: onInfo,
                ),
                _TrailerActionButton(
                  icon: Icons.fullscreen_rounded,
                  label: 'Fullscreen',
                  tooltip: 'Fullscreen',
                  onPressed: onFullscreen,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TrailerActionButton extends StatelessWidget {
  const _TrailerActionButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: 28,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundHeaderButton extends StatelessWidget {
  const _RoundHeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TrailerPlayerIconButton(
      icon: icon,
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
