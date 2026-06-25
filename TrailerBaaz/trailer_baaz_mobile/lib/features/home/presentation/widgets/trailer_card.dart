import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';
import '../../../../shared/widgets/glass_surfaces.dart';

class TrailerCard extends StatelessWidget {
  final TrailerModel trailer;
  final double width;
  final VoidCallback? onTap;
  final bool showTrendingBadge;

  const TrailerCard({
    super.key,
    required this.trailer,
    this.width = 260,
    this.onTap,
    this.showTrendingBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = width.clamp(240.0, 320.0).toDouble();
    final posterHeight = (cardWidth * 0.62).clamp(156.0, 188.0).toDouble();
    final infoHeight = (cardWidth * 0.18).clamp(56.0, 72.0).toDouble();

    return _PressableCard(
      onTap: onTap,
      child: SizedBox(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: posterHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _SafeImage(url: trailer.imageUrl),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x14000000),
                            Color(0x06000000),
                            Color(0xC9000000),
                          ],
                          stops: [0.0, 0.58, 1.0],
                        ),
                      ),
                    ),
                    if (showTrendingBadge)
                      Positioned(
                        left: 12,
                        top: 12,
                        child: _Badge(
                          label: 'TRENDING',
                          icon: Icons.bolt_rounded,
                        ),
                      ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: GlassIconButton(
                        size: 36,
                        padding: const EdgeInsets.all(7),
                        icon: const Text('🍿', style: TextStyle(fontSize: 16)),
                        onTap: () => showReactionBottomSheet(context, trailer),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            trailer.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              height: 1.05,
                              shadows: [
                                Shadow(
                                  color: Colors.black87,
                                  blurRadius: 12,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _MetaPill(label: trailer.language.toUpperCase()),
                              const SizedBox(width: 8),
                              _MetaPill(label: _viewsLabel(trailer)),
                              const Spacer(),
                              Icon(
                                Icons.play_circle_fill_rounded,
                                color: Colors.white.withValues(alpha: 0.92),
                                size: 22,
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
            const SizedBox(height: 10),
            SizedBox(
              height: infoHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      trailer.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trailer.industry,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textGrey.withValues(alpha: 0.72),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Badge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.amber.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.background),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.background,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;

  const _MetaPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressableCard({required this.child, this.onTap});

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapCancel: widget.onTap == null
          ? null
          : () => setState(() => _pressed = false),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _SafeImage extends StatefulWidget {
  final String url;

  const _SafeImage({required this.url});

  @override
  State<_SafeImage> createState() => _SafeImageState();
}

class _SafeImageState extends State<_SafeImage> {
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    final valid = widget.url.startsWith('http') && widget.url.contains('/t/p/');
    if (_failed || !valid) {
      return const ColoredBox(
        color: AppColors.card,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.textGrey,
            size: 40,
          ),
        ),
      );
    }

    return Image.network(
      widget.url,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
      errorBuilder: (context, error, stackTrace) {
        if (!_failed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _failed = true);
          });
        }
        return const ColoredBox(
          color: AppColors.card,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.textGrey,
              size: 40,
            ),
          ),
        );
      },
    );
  }
}

String _viewsLabel(TrailerModel trailer) {
  final seed = trailer.title.codeUnits.fold<int>(0, (sum, code) => sum + code);
  final value = 100 + (seed % 900);
  return '${value}K views';
}
