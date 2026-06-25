import 'package:flutter/material.dart';

import '../../../../shared/widgets/glass_surfaces.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Connect notify-me flows to Firebase notifications later.
    return Wrap(
      spacing: 10,
      runSpacing: 10,
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
    return GlassPillButton(label: label, icon: icon, onTap: () {});
  }
}
