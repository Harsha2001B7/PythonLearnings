import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../core/models/trailer.dart';
import '../../shared/widgets/cinematic_image.dart';
import 'trailer_player_controller.dart';

class TrailerPlayerFeed extends StatefulWidget {
  const TrailerPlayerFeed({
    super.key,
    required this.trailer,
    required this.active,
    this.onInfo,
    this.onFullscreen,
  });

  final Trailer trailer;
  final bool active;
  final VoidCallback? onInfo;
  final VoidCallback? onFullscreen;

  @override
  State<TrailerPlayerFeed> createState() => _TrailerPlayerFeedState();
}

class _TrailerPlayerFeedState extends State<TrailerPlayerFeed> {
  TrailerPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    if (widget.active) {
      _initController();
    }
  }

  @override
  void didUpdateWidget(covariant TrailerPlayerFeed oldWidget) {
    super.didUpdateWidget(oldWidget);

    final trailerChanged = oldWidget.trailer.id != widget.trailer.id;
    final becameActive = widget.active && !oldWidget.active;
    final becameInactive = !widget.active && oldWidget.active;

    if (trailerChanged) {
      _disposeController();
      if (widget.active) _initController();
      return;
    }

    if (becameActive) {
      _initController();
    } else if (becameInactive) {
      _disposeController();
    }
  }

  void _initController() {
    _disposeController();
    _ready = false;
    _controller = TrailerPlayerController(widget.trailer, initialMuted: true);
    if (mounted) setState(() {});

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted && widget.active) {
        setState(() => _ready = true);
      }
    });
  }

  void _disposeController() {
    try {
      _controller?.dispose();
    } catch (_) {}
    _controller = null;
    _ready = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trailer = widget.trailer;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _controller == null
            ? CinematicImage(
                url: trailer.posterUrl,
                fadeInDuration: Duration.zero,
              )
            : AnimatedBuilder(
                animation: _controller!,
                builder: (context, _) {
                  final state = _controller!.state;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 320),
                        opacity: _ready ? 0 : 1,
                        child: CinematicImage(
                          url: trailer.posterUrl,
                          fadeInDuration: Duration.zero,
                        ),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 240),
                        opacity: _ready ? 1 : 0,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            YoutubePlayer(
                              key: ValueKey(trailer.id),
                              controller: _controller!.youtubeController,
                              aspectRatio: 16 / 9,
                              backgroundColor: Colors.black,
                              autoFullScreen: false,
                              enableFullScreenOnVerticalDrag: false,
                              keepAlive: true,
                              initParams: YoutubePlayerParams(
                                showControls: false, // hide controls for inline feed
                                showFullscreenButton: false,
                                mute: state.isMuted,
                                playsInline: true,
                                enableCaption: false,
                                strictRelatedVideos: true,
                                loop: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
