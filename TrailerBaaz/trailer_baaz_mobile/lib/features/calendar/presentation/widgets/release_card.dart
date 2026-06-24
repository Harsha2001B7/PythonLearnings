import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';

class ReleaseCard extends StatelessWidget {
  final TrailerModel trailer;
  final int index;

  const ReleaseCard({super.key, required this.trailer, required this.index});

  @override
  Widget build(BuildContext context) {
    return _SpringPress(
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: AppColors.amber.withOpacity(0.06), blurRadius: 28, spreadRadius: 1, offset: const Offset(0, 16))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(width: 76, height: 104, child: _SafeImage(url: trailer.imageUrl)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trailer.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w500, fontSize: 16)),
                  const SizedBox(height: 7),
                  Text('June ${12 + index * 5}, 2026', style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  const SizedBox(height: 5),
                  Text('${trailer.language} / ${trailer.genre}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      const _SoonBadge(),
                      _HypeBadge(score: 53 + index * 8),
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
}

class _SoonBadge extends StatelessWidget {
  const _SoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(20)),
      child: const Text('SOON', style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }
}

class _HypeBadge extends StatelessWidget {
  final int score;

  const _HypeBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.amber)),
      child: Text('HYPE $score', style: const TextStyle(color: AppColors.amber, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }
}

class _SpringPress extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _SpringPress({required this.child, required this.onTap});

  @override
  State<_SpringPress> createState() => _SpringPressState();
}

class _SpringPressState extends State<_SpringPress> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(scale: _pressed ? 0.95 : 1, duration: const Duration(milliseconds: 420), curve: Curves.elasticOut, child: widget.child),
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
    if (_failed || !valid) return const ColoredBox(color: AppColors.chip, child: Center(child: Icon(Icons.movie_outlined, color: AppColors.textGrey)));
    return Image.network(
      widget.url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        if (!_failed) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) setState(() => _failed = true); });
        return const ColoredBox(color: AppColors.chip, child: Center(child: Icon(Icons.movie_outlined, color: AppColors.textGrey)));
      },
    );
  }
}
