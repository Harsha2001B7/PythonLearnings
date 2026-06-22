import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';

class HeroCarousel extends StatelessWidget {
  final List<TrailerModel> trailers;

  const HeroCarousel({super.key, required this.trailers});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.92),
        itemCount: trailers.length,
        itemBuilder: (_, index) => _HeroSlide(trailer: trailers[index]),
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  final TrailerModel trailer;

  const _HeroSlide({required this.trailer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(trailer.imageUrl, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black]),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(trailer.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(trailer.subtitle, style: const TextStyle(color: AppColors.textGrey)),
                const SizedBox(height: 16),
                Row(children: const [_ActionButton(icon: Icons.play_arrow, label: 'Play', filled: true), SizedBox(width: 12), _ActionButton(icon: Icons.info_outline, label: 'More Info')]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;

  const _ActionButton({required this.icon, required this.label, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton.tonalIcon(
        onPressed: () {},
        style: FilledButton.styleFrom(
          backgroundColor: filled ? AppColors.textWhite : Colors.white12,
          foregroundColor: filled ? Colors.black : AppColors.textWhite,
        ),
        icon: Icon(icon, size: 20),
        label: Text(label),
      ),
    );
  }
}
