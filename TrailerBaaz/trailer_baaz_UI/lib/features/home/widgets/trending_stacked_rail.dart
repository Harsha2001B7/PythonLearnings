import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../../core/models/trailer.dart';
import '../../../shared/widgets/trailer_card.dart';

class TrendingStackedRail extends StatefulWidget {
  const TrendingStackedRail({
    super.key,
    required this.title,
    required this.trailers,
    required this.onTap,
    required this.onPlay,
  });

  final String title;
  final List<Trailer> trailers;
  final ValueChanged<Trailer> onTap;
  final ValueChanged<Trailer> onPlay;

  @override
  State<TrendingStackedRail> createState() => _TrendingStackedRailState();
}

class _TrendingStackedRailState extends State<TrendingStackedRail>
    with SingleTickerProviderStateMixin {
  double _page = 0.0;
  AnimationController? _snapCtrl;
  Animation<double>? _snapAnim;

  @override
  void initState() {
    super.initState();
    _snapCtrl =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 340),
        )..addListener(() {
          if (_snapAnim != null) {
            setState(() {
              _page = _snapAnim!.value;
            });
          }
        });
  }

  @override
  void dispose() {
    try {
      _snapCtrl?.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_snapCtrl?.isAnimating == true) _snapCtrl?.stop();
    final delta = -(details.primaryDelta ?? 0);
    setState(() {
      _page += delta / _cardWidth(context);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    double target = _page.roundToDouble();

    if (velocity < -400) {
      target = _page.floor() + 1.0;
    } else if (velocity > 400) {
      target = _page.ceil() - 1.0;
    }

    if (_snapCtrl != null) {
      _snapAnim = Tween<double>(begin: _page, end: target).animate(
        CurvedAnimation(parent: _snapCtrl!, curve: Curves.easeOutCubic),
      );
      _snapCtrl!.forward(from: 0.0);
    }
  }

  double _cardWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width * 0.8;

  @override
  Widget build(BuildContext context) {
    if (widget.trailers.isEmpty) return const SizedBox();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = screenWidth * 0.82;
    final imageHeight = cardWidth * (9 / 16);
    final cardHeight = imageHeight + kCardTextSectionHeight;
    final currentIndex = _page.floor();

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: cardHeight + 20,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (int offset = 3; offset >= 0; offset--)
                    _buildCard(
                      currentIndex + offset,
                      cardWidth,
                      cardHeight,
                      imageHeight,
                    ),
                  _buildCard(
                    currentIndex - 1,
                    cardWidth,
                    cardHeight,
                    imageHeight,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    int index,
    double cardWidth,
    double cardHeight,
    double imageHeight,
  ) {
    final diff = index - _page;
    if (diff <= -1.5 || diff >= 3.5) return const SizedBox.shrink();

    const scaleStep = 0.06;
    final peekWidth = MediaQuery.sizeOf(context).width * 0.055;
    final translationStep = cardWidth * scaleStep + peekWidth;

    double scale;
    double translateX;
    double dimAlpha;

    if (diff <= 0) {
      scale = (1.0 + diff * 0.03).clamp(0.8, 1.0);
      translateX = diff * MediaQuery.sizeOf(context).width * 0.88;
      dimAlpha = 0.0;
    } else {
      scale = (1.0 - diff * scaleStep).clamp(0.0, 1.0);
      translateX = diff * translationStep;
      dimAlpha = (diff * 0.32).clamp(0.0, 0.80);
    }

    final isFront = diff.abs() < 0.5;
    final trailerIndex =
        (index % widget.trailers.length + widget.trailers.length) %
        widget.trailers.length;
    final trailer = widget.trailers[trailerIndex];
    final renderHeight = isFront ? cardHeight : imageHeight;

    return Positioned(
      left: 20,
      top: 10,
      bottom: 10,
      child: Transform(
        transform:
            Matrix4.translationValues(translateX, 0.0, 0.0) *
            Matrix4.diagonal3Values(scale, scale, 1.0),
        alignment: Alignment.centerLeft,
        child: IgnorePointer(
          ignoring: !isFront,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: isFront
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: (0.5 * (1 - dimAlpha)).clamp(0.0, 0.5),
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: (0.25 * (1 - dimAlpha)).clamp(0.0, 0.25),
                        ),
                        blurRadius: 8,
                        offset: const Offset(-3, 0),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                RepaintBoundary(
                  child: TrailerCard(
                    trailer: trailer,
                    width: cardWidth,
                    height: isFront ? imageHeight : renderHeight,
                    showDetails: isFront,
                    onTap: () => widget.onTap(trailer),
                    onPlay: () => widget.onPlay(trailer),
                  ),
                ),
                if (dimAlpha > 0.01)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: dimAlpha),
                      ),
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
