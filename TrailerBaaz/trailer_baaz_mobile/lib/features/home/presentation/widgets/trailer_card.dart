import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';

class TrailerCard extends StatelessWidget {
  final TrailerModel trailer;
  final double width;
  final VoidCallback? onTap;
  final bool showTrendingBadge;

  const TrailerCard({
    super.key,
    required this.trailer,
    this.width = 150,
    this.onTap,
    this.showTrendingBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = width.clamp(240.0, 280.0).toDouble();
    final imageHeight = (cardWidth / 1.78).clamp(136.0, 156.0).toDouble();
    final titleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textWhite);
    return _SpringPress(
      onTap: onTap,
      child: SizedBox(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailer.isUpcoming)
              _TrailerThumb(
                trailer: trailer,
                width: cardWidth,
                height: imageHeight + 42,
                showTrendingBadge: showTrendingBadge,
              )
            else ...[
              _TrailerThumb(
                trailer: trailer,
                width: cardWidth,
                height: imageHeight,
                showTrendingBadge: showTrendingBadge,
              ),
              _TrailerTextBlock(
                trailer: trailer,
                width: cardWidth,
                titleStyle: titleStyle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final double rounded;

  const _Badge({required this.label, this.rounded = 999});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(rounded)),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
    );
  }
}

class _TrailerThumb extends StatelessWidget {
  final TrailerModel trailer;
  final double width;
  final double height;
  final bool showTrendingBadge;

  const _TrailerThumb({
    required this.trailer,
    required this.width,
    required this.height,
    required this.showTrendingBadge,
  });

  @override
  Widget build(BuildContext context) {
    if (trailer.isUpcoming) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: [BoxShadow(color: AppColors.amber.withValues(alpha: 0.08), blurRadius: 24, spreadRadius: 2, offset: const Offset(0, 12))],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _SafeImage(url: trailer.imageUrl),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xE6000000)],
                    stops: [0.45, 1],
                  ),
                ),
              ),
              if (showTrendingBadge)
                const Positioned(
                  top: 10,
                  left: 10,
                  child: _Badge(label: 'TRENDING WORLDWIDE', rounded: 6),
                ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trailer.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const _MiniBadge(
                          label: 'LAUNCHES IN X DAYS',
                          background: AppColors.amber,
                          foreground: AppColors.textWhite,
                        ),
                        const SizedBox(width: 8),
                        const _MiniBadge(
                          label: 'HYPE XX',
                          background: Color(0xFF1A1A1A),
                          foreground: AppColors.amber,
                          borderColor: AppColors.amber,
                        ),
                        const Spacer(),
                        Text(
                          '${(trailer.title.length * 17) + 120}K views',
                          style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        boxShadow: [BoxShadow(color: AppColors.amber.withValues(alpha: 0.08), blurRadius: 24, spreadRadius: 2, offset: const Offset(0, 12))],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _SafeImage(url: trailer.imageUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xE6000000)],
                  stops: [0.48, 1],
                ),
              ),
            ),
            if (showTrendingBadge)
              const Positioned(
                top: 10,
                left: 10,
                child: _Badge(label: 'TRENDING WORLDWIDE', rounded: 6),
              ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Text(
                '${(trailer.title.length * 17) + 120}K views',
                style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrailerTextBlock extends StatelessWidget {
  final TrailerModel trailer;
  final double width;
  final TextStyle? titleStyle;

  const _TrailerTextBlock({
    required this.trailer,
    required this.width,
    required this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trailer.language.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.amber, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            trailer.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: titleStyle?.copyWith(height: 1.15),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final Color? borderColor;

  const _MiniBadge({
    required this.label,
    required this.background,
    required this.foreground,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SpringPress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _SpringPress({required this.child, this.onTap});

  @override
  State<_SpringPress> createState() => _SpringPressState();
}

class _SpringPressState extends State<_SpringPress> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
      onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap!();
            },
      child: AnimatedScale(scale: _pressed ? 0.96 : 1, duration: const Duration(milliseconds: 420), curve: Curves.elasticOut, child: widget.child),
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
    if (_failed || !valid) return const ColoredBox(color: AppColors.card, child: Center(child: Icon(Icons.image_not_supported_outlined, color: AppColors.textGrey)));
    return Image.network(
      widget.url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        if (!_failed) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) setState(() => _failed = true); });
        return const ColoredBox(color: AppColors.card, child: Center(child: Icon(Icons.image_not_supported_outlined, color: AppColors.textGrey)));
      },
    );
  }
}
