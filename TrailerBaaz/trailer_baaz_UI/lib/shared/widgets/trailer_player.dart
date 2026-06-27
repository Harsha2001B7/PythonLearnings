import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../app/app_theme.dart';
import '../../core/models/trailer.dart';

/// Opens a dedicated fullscreen player screen.
Future<void> showTrailerPlayer(BuildContext context, Trailer trailer) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _TrailerPlayerScreen(trailer: trailer),
    ),
  );
}

class _TrailerPlayerScreen extends StatefulWidget {
  const _TrailerPlayerScreen({required this.trailer});
  final Trailer trailer;

  @override
  State<_TrailerPlayerScreen> createState() => _TrailerPlayerScreenState();
}

class _TrailerPlayerScreenState extends State<_TrailerPlayerScreen> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.trailer.youtubeVideoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false, // We use our own custom button
        mute: false,
        playsInline: true,
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    try {
      _controller?.close();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isPortrait = orientation == Orientation.portrait;

            return Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isPortrait) const Spacer(),

                    // The player remains structurally identical to prevent WebView crashes
                    Flexible(
                      key: const ValueKey('youtube_player_wrapper'),
                      child: InteractiveViewer(
                        clipBehavior: Clip.hardEdge,
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: _controller != null 
                              ? YoutubePlayer(controller: _controller!) 
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),

                    if (isPortrait) const SizedBox(height: 24),

                    // Title + controls (only in portrait)
                    if (isPortrait)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.trailer.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppTheme.accent.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    widget.trailer.studio,
                                    style: const TextStyle(
                                      color: AppTheme.accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${widget.trailer.views} views',
                                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                                ),
                                const Spacer(),
                                _GlassButton(
                                  icon: Icons.fullscreen_rounded,
                                  tooltip: 'Wide screen',
                                  onPressed: () => _controller?.toggleFullScreen(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    if (isPortrait) const Spacer(flex: 2),
                  ],
                ),

                // Floating Top Bar with Back button
                Positioned(
                  top: 16,
                  left: 16,
                  child: _GlassButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    tooltip: 'Go back',
                    onPressed: () => Navigator.of(context).pop(),
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

// ─── Glass button ─────────────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
