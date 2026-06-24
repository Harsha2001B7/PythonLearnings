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
    final titleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);
    return _SpringPress(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 0.72,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: AppColors.amber.withOpacity(0.08), blurRadius: 24, spreadRadius: 2, offset: const Offset(0, 12))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _SafeImage(url: trailer.imageUrl),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xDD000000)],
                          ),
                        ),
                      ),
                      if (showTrendingBadge)
                        const Positioned(top: 8, left: 8, child: _Badge(label: 'TRENDING WORLDWIDE', rounded: 6)),
                      if (trailer.isUpcoming)
                        const Positioned(top: 8, right: 8, child: _Badge(label: 'SOON')),
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: Text('${(trailer.title.length * 17) + 120}K views', style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(trailer.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: titleStyle),
            const SizedBox(height: 4),
            Text(
              trailer.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
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
