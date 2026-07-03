import 'package:flutter/material.dart';

/// A generic empty-state widget: icon, title and optional subtitle.
///
/// Matches the visual pattern of [NotificationEmptyState] so that all
/// empty states across the app share a consistent look.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconSize = 64.0,
    this.iconBackgroundColor,
  });

  /// Icon to display inside the circular container.
  final IconData icon;

  /// Primary heading shown below the icon.
  final String title;

  /// Optional secondary body text.
  final String? subtitle;

  /// Icon size. Defaults to 64.
  final double iconSize;

  /// Background color of the circular icon container. When null,
  /// a subtle white overlay is used.
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        iconBackgroundColor ?? Colors.white.withValues(alpha: 0.05);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
