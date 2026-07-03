import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../core/di/locator.dart';
import '../../core/models/trailer.dart';
import '../../core/navigation/app_router.dart';
import '../../core/navigation/navigation_service.dart';
import '../../features/details/trailer_details_screen.dart';
import 'trailer_player_buttons.dart';
import 'trailer_player_controller.dart';

_TrailerPlayerScreenState? _activePlayer;
Future<void>? _activePlayerFuture;

Future<void> showTrailerPlayer(BuildContext context, Trailer trailer, {bool startFullscreen = true}) async {
  final launchedFromDetails = context.findAncestorWidgetOfExactType<TrailerDetailsScreen>();
  final launchedFromDetailsId = launchedFromDetails?.trailer.id;

  if (_activePlayer != null) {
    await _activePlayer!._replaceTrailer(trailer, launchedFromDetailsId);
    return _activePlayerFuture;
  }

  final route = AppRouter.trailerPlayer(
    trailerId: trailer.id,
    builder: (_) => _TrailerPlayerScreen(
      trailer: trailer,
      launchedFromDetailsId: launchedFromDetailsId,
    ),
  );

  _activePlayerFuture = locator<NavigationService>().pushRoute(
    context,
    route,
    rootNavigator: true,
  );
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
  });

  final Trailer trailer;
  final String? launchedFromDetailsId;

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      await _controller.enterFullscreen();
    });
  }

  Future<void> _replaceTrailer(Trailer trailer, String? launchedFromDetailsId) async {
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
    await _closePlayer();
  }

  Future<void> _closePlayer() async {
    await _controller.restorePortraitChrome();
    if (!mounted) return;
    setState(() => _allowPop = true);
    locator<NavigationService>().pop(context);
  }

  Future<void> _openInfo() async {
    final trailer = _controller.state.trailer;
    await _controller.exitFullscreen();
    await _controller.restorePortraitChrome();
    if (!mounted) return;

    setState(() => _allowPop = true);
    
    if (_launchedFromDetailsId == trailer.id) {
      locator<NavigationService>().pop(context);
      return;
    }

    locator<NavigationService>().replaceWithTrailerDetailsFromPlayer(
      context,
      trailer,
    );
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
        body: Center(
          child: YoutubePlayer(
            key: const ValueKey('trailer-player'),
            controller: _controller.youtubeController,
            aspectRatio: 16 / 9,
            backgroundColor: Colors.black,
            autoFullScreen: false,
            enableFullScreenOnVerticalDrag: false,
            keepAlive: true,
            controlsBuilder: (context, isFullscreen) {
              return SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, top: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TrailerPlayerIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          tooltip: 'Close player',
                          onPressed: _closePlayer,
                        ),
                        const SizedBox(height: 8),
                        TrailerPlayerIconButton(
                          icon: Icons.info_outline_rounded,
                          tooltip: 'Trailer details',
                          onPressed: _openInfo,
                        ),
                      ],
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
    );
  }
}
