import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Connect notify-me flows to Firebase notifications later.
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: const [
        _ActionChip(icon: Icons.favorite_border_rounded, label: 'Like'),
        _ActionChip(icon: Icons.bookmark_border_rounded, label: 'Save'),
        _ActionChip(icon: Icons.share_outlined, label: 'Share'),
        _ActionChip(icon: Icons.notifications_none_rounded, label: 'Notify Me'),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: () {},
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textWhite,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
