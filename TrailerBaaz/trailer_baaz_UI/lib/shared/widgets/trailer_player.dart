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
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
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
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with Back button
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _GlassButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  tooltip: 'Go back',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            const Spacer(),

            // YouTube player in 16:9
            AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(controller: _controller),
            ),

            const SizedBox(height: 24),

            // Title + controls
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
                        onPressed: () => _controller.toggleFullScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),
          ],
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
