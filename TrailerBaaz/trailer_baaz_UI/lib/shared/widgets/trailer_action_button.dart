import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

class TrailerActionButton extends StatelessWidget {
  const TrailerActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.expanded = false,
    this.dark = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool expanded;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: dark
            ? Colors.white.withValues(alpha: .1)
            : Colors.white,
        foregroundColor: dark ? Colors.white : Colors.black,
        minimumSize: const Size(0, 58),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(
            color: dark
                ? Colors.white.withValues(alpha: .16)
                : Colors.transparent,
          ),
        ),
        shadowColor: AppTheme.accent.withValues(alpha: .35),
        elevation: dark ? 0 : 8,
      ),
    );
    return expanded ? Expanded(child: button) : button;
  }
}
