import 'package:flutter/material.dart';

class TrailerPlayerIconButton extends StatelessWidget {
  const TrailerPlayerIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 44,
    this.iconSize = 22,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: 0.46),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: size,
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
        ),
      ),
    );
  }
}
