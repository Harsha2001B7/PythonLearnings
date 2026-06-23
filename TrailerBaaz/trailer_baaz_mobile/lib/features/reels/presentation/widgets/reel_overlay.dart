import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/reel_model.dart';

class ReelOverlay extends StatelessWidget {
  final ReelModel reel;
  final bool muted;
  final bool paused;
  final VoidCallback onMute;
  final VoidCallback onPlayPause;

  const ReelOverlay({
    super.key,
    required this.reel,
    required this.muted,
    required this.paused,
    required this.onMute,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: _GlassIcon(icon: muted ? Icons.volume_off_rounded : Icons.volume_up_rounded, onTap: onMute),
            ),
            Align(
              child: AnimatedScale(
                scale: paused ? 1 : 0.92,
                duration: const Duration(milliseconds: 180),
                child: _GlassIcon(icon: paused ? Icons.play_arrow_rounded : Icons.pause_rounded, onTap: onPlayPause, size: 34, padding: 18),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reel.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Text('${reel.genre} • ${reel.language}', style: const TextStyle(color: AppColors.textGrey)),
                    const SizedBox(height: 4),
                    Text(reel.industry, style: const TextStyle(color: AppColors.textGrey)),
                    const SizedBox(height: 4),
                    Text('${reel.views} views • ${reel.releaseYear}', style: const TextStyle(color: AppColors.textGrey)),
                  ],
                ),
              ),
            ),
            const Align(alignment: Alignment.bottomRight, child: _ActionRail()),
          ],
        ),
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail();

  @override
  Widget build(BuildContext context) {
    // TODO: Connect like/save/share flows to Firebase notifications later if needed.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _RailButton(icon: Icons.favorite_border_rounded, label: 'Like'),
        SizedBox(height: 14),
        _RailButton(icon: Icons.bookmark_border_rounded, label: 'Save'),
        SizedBox(height: 14),
        _RailButton(icon: Icons.share_outlined, label: 'Share'),
        SizedBox(height: 14),
        _RailButton(icon: Icons.info_outline_rounded, label: 'Details'),
      ],
    );
  }
}

class _RailButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _RailButton({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [TweenAnimationBuilder<double>(tween: Tween(begin: 0.95, end: 1), duration: const Duration(milliseconds: 220), builder: (_, v, child) => Transform.scale(scale: v, child: child), child: _GlassIcon(icon: icon, onTap: () {})), const SizedBox(height: 6), Text(label, style: const TextStyle(fontSize: 12))]);
}

class _GlassIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double padding;
  const _GlassIcon({required this.icon, required this.onTap, this.size = 24, this.padding = 12});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(99), child: Container(padding: EdgeInsets.all(padding), decoration: const BoxDecoration(color: Color(0x66000000), shape: BoxShape.circle), child: Icon(icon, size: size, color: AppColors.textWhite)));
}
