import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/models/trailer.dart';
import 'cinematic_image.dart';
import 'meta_widgets.dart';

// Height of the text strip below the thumbnail.
const double kCardTextSectionHeight = 76.0;

class TrailerCard extends StatefulWidget {
  const TrailerCard({
    super.key,
    required this.trailer,
    required this.onTap,
    this.onPlay,
    this.width = 260,
    // height = image height. Text strip is added automatically when showDetails = true.
    this.height = 160,
    this.showPlay = false,
    this.showDetails = true,
  });

  final Trailer trailer;
  final VoidCallback onTap;
  final VoidCallback? onPlay;
  final double width;
  // Image height only (not including text section).
  final double height;
  final bool showPlay;
  final bool showDetails;

  /// Total rendered height: image + optional text strip.
  double get totalHeight =>
      showDetails ? height + kCardTextSectionHeight : height;

  @override
  State<TrailerCard> createState() => _TrailerCardState();
}

class _TrailerCardState extends State<TrailerCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.trailer.youtubeVideoId.isNotEmpty
        ? widget.trailer.youtubeHqThumbnailUrl
        : widget.trailer.posterUrl;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        scale: _pressed ? 0.97 : 1.0,
        child: SizedBox(
          width: widget.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Thumbnail ──────────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Full-bleed 16:9 thumbnail – the STAR of the show
                      CinematicImage(url: imageUrl),

                      // Subtle top vignette so view-count badge is readable
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                            colors: [Color(0x66000000), Colors.transparent],
                          ),
                        ),
                      ),

                      // View count badge – top-left
                      if (widget.trailer.views.isNotEmpty)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.60),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.trailer.views,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),

                      // Play button – centered on image
                      if (widget.showDetails &&
                          (widget.onPlay != null || widget.showPlay))
                        Center(
                          child: GestureDetector(
                            onTap: widget.onPlay,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.52),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white60, width: 1.5),
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Text strip below thumbnail ─────────────────────────────────
              if (widget.showDetails) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: widget.width,
                  height: kCardTextSectionHeight - 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Studio badge row
                      Row(
                        children: [
                          if (widget.trailer.studio.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: AppTheme.accent
                                        .withValues(alpha: 0.45),
                                    width: 0.8),
                              ),
                              child: Text(
                                widget.trailer.studio.toUpperCase(),
                                style: const TextStyle(
                                  color: AppTheme.accent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          const Spacer(),
                          HypeLabel(
                              score: widget.trailer.hypeScore, compact: true),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Title – full text, up to 2 lines, no overlay
                      Text(
                        widget.trailer.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
