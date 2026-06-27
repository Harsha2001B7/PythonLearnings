import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/models/trailer.dart';
import 'cinematic_image.dart';
import 'meta_widgets.dart';

class TrailerCard extends StatefulWidget {
  const TrailerCard({
    super.key,
    required this.trailer,
    required this.onTap,
    this.onPlay,
    this.width = 250,
    this.height = 150,
    this.showPlay = false,
    this.showDetails = true,
  });

  final Trailer trailer;
  final VoidCallback onTap;
  final VoidCallback? onPlay;
  final double width;
  final double height;
  final bool showPlay;
  final bool showDetails;

  @override
  State<TrailerCard> createState() => _TrailerCardState();
}

class _TrailerCardState extends State<TrailerCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    // Prefer YouTube thumbnail, fall back to posterUrl
    final imageUrl = widget.trailer.youtubeVideoId.isNotEmpty
        ? widget.trailer.youtubeHqThumbnailUrl
        : widget.trailer.posterUrl;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        scale: _pressed ? .97 : 1,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CinematicImage(url: imageUrl),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xBB000000),
                        Color(0xEE000000),
                      ],
                    ),
                  ),
                ),
                // Play button overlay (tappable)
                if (widget.showDetails && (widget.onPlay != null || widget.showPlay))
                  Center(
                    child: GestureDetector(
                      onTap: widget.onPlay,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .55),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white38),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                if (widget.showDetails)
                  Positioned(
                    left: 14,
                    right: 12,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.trailer.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            HypeLabel(
                              score: widget.trailer.hypeScore,
                              compact: true,
                            ),
                            const Spacer(),
                            Flexible(
                              child: Text(
                                widget.trailer.views,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: AppTheme.muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.none,
                                ),
                              ),
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
      ),
    );
  }
}
