import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class PopcornPanel extends StatelessWidget {
  const PopcornPanel({
    super.key,
    required this.score,
    required this.rating,
    required this.onOpen,
  });

  final int score;
  final int? rating;
  final VoidCallback onOpen;

  String get _ratingLabel {
    if (rating == null) return 'Tap to rate this trailer';
    const labels = ['', 'Hard pass', 'One kernel?', 'Pop me', 'Gift popcorn', 'Feed the bucket'];
    return 'Your pop: ${labels[rating!]}';
  }

  @override
  Widget build(BuildContext context) {
    final rated = rating != null;
    return GestureDetector(
      onTap: onOpen,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: rated
                ? [const Color(0xFF1E1A10), const Color(0xFF151208)]
                : [const Color(0xFF171717), const Color(0xFF111111)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: rated
                ? AppTheme.hype.withValues(alpha: .45)
                : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppTheme.hype.withValues(alpha: .16),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🍿', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$score% Audience Hype',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _ratingLabel,
                    style: TextStyle(
                      color: rated ? AppTheme.hype : AppTheme.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white38, size: 22),
          ],
        ),
      ),
    );
  }
}
