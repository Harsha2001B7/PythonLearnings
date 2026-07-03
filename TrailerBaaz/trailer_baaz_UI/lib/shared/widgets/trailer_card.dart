import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/models/trailer.dart';
import '../../shared/animations/animations.dart';
import 'cinematic_image.dart';

import 'popcorn_rating.dart';

// Height of the text strip below the thumbnail.
const double kCardTextSectionHeight = 76.0;
const double _kCardMetadataHeight = 20.0;
const double _kCardMetadataTitleGap = 6.0;
const TextStyle _kCardTitleStyle = TextStyle(
  color: Colors.white,
  fontSize: 13,
  fontWeight: FontWeight.w700,
  height: 1.25,
  decoration: TextDecoration.none,
);

enum TrailerCardVariant { home, large }

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
    this.variant = TrailerCardVariant.home,
  });

  const TrailerCard.large({
    super.key,
    required this.trailer,
    required this.onTap,
    required this.onPlay,
    required this.width,
    this.showPlay = true,
    this.showDetails = true,
  }) : height = width * (9 / 16),
       variant = TrailerCardVariant.large;

  final Trailer trailer;
  final VoidCallback onTap;
  final VoidCallback? onPlay;
  final double width;
  // Image height only (not including text section).
  final double height;
  final bool showPlay;
  final bool showDetails;
  final TrailerCardVariant variant;

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
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final memCacheWidth = (widget.width * dpr).round();
    final memCacheHeight = (widget.height * dpr).round();

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: PressScale(
        pressed: _pressed,
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
                      CinematicImage(
                        url: imageUrl,
                        memCacheWidth: memCacheWidth,
                        memCacheHeight: memCacheHeight,
                      ),

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
                              horizontal: 8,
                              vertical: 4,
                            ),
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
                      if (widget.showDetails && widget.onPlay != null)
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
                                  color: Colors.white60,
                                  width: 1.5,
                                ),
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
                      // Metadata always owns a fixed row, so long titles can
                      // only use the remaining space and never push badges out.
                      SizedBox(
                        height: _kCardMetadataHeight,
                        child: Row(
                          children: [
                            if (widget.trailer.studio.isNotEmpty) ...[
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accent.withValues(
                                        alpha: 0.18,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppTheme.accent.withValues(
                                          alpha: 0.45,
                                        ),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      widget.trailer.studio.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: const TextStyle(
                                        color: AppTheme.accent,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ] else
                              const Spacer(),
                            PopcornBadge(
                              score: widget.trailer.hypeScore,
                              compact: true,
                              onTap: () => showPopcornRating(
                                context,
                                hypeScore: widget.trailer.hypeScore,
                                currentRating: null,
                                onRatingChanged: (_) {},
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: _kCardMetadataTitleGap),
                      Expanded(
                        child: _FadingTrailerTitle(
                          title: widget.trailer.title,
                          style: _kCardTitleStyle,
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

class _FadingTrailerTitle extends StatelessWidget {
  const _FadingTrailerTitle({required this.title, required this.style});

  final String title;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final lineHeight = (style.fontSize ?? 13) * (style.height ?? 1.0);
        final maxLines = (constraints.maxHeight / lineHeight)
            .floor()
            .clamp(1, 4);
        final textDirection = Directionality.of(context);
        final titleText = Text(
          title,
          maxLines: maxLines,
          overflow: TextOverflow.clip,
          softWrap: true,
          style: style,
        );
        final painter = TextPainter(
          text: TextSpan(text: title, style: style),
          maxLines: maxLines,
          textDirection: textDirection,
        )..layout(maxWidth: constraints.maxWidth);

        if (!painter.didExceedMaxLines) {
          return Align(alignment: Alignment.topLeft, child: titleText);
        }

        // Match the Hero's cinematic softness: the last available title line
        // dissolves downward instead of ending with a hard ellipsis.
        final fadeStart = ((maxLines - 0.55) / maxLines).clamp(0.0, 0.92);
        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Colors.white, Colors.white, Colors.transparent],
            stops: [0.0, fadeStart, 1.0],
          ).createShader(bounds),
          child: Align(alignment: Alignment.topLeft, child: titleText),
        );
      },
    );
  }
}
