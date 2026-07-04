import 'package:flutter/material.dart';

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.size = 56,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0x14FFFFFF),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x24FFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x47000000),
                blurRadius: 22,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: size * .42),
        ),
      ),
    );
  }
}
