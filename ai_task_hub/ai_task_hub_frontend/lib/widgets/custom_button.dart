import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool expand;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final child = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(label),
            ],
          )
        : Text(label);

    if (isOutlined) {
      final button = OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: theme.colorScheme.outline),
          foregroundColor: theme.colorScheme.onSurface,
        ),
        child: child,
      );

      return expand ? SizedBox(width: double.infinity, child: button) : button;
    }

    final button = ElevatedButton(
      onPressed: onPressed,
      child: child,
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
