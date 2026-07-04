import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

class GenreChip extends StatelessWidget {
  const GenreChip(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x21FFFFFF)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class HypeLabel extends StatelessWidget {
  const HypeLabel({super.key, required this.score, this.compact = false});

  final int score;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.local_fire_department, color: AppTheme.hype, size: 16),
        const SizedBox(width: 3),
        Text(
          '$score%',
          style: TextStyle(
            color: compact ? AppTheme.hype : Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: compact ? 12 : 16,
          ),
        ),
      ],
    );
  }
}

class StatItem extends StatelessWidget {
  const StatItem({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.valueColor = Colors.white,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 19, color: valueColor),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: .2,
            ),
          ),
        ],
      ),
    );
  }
}
