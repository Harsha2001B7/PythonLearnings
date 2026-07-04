import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class ReelAction extends StatelessWidget {
  const ReelAction({
    super.key,
    this.icon,
    this.emoji,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData? icon;
  final String? emoji;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? AppTheme.accent.withValues(alpha: .16)
                    : Colors.white.withValues(alpha: .05),
                border: Border.all(
                  color: active
                      ? AppTheme.accent.withValues(alpha: .7)
                      : Colors.white.withValues(alpha: .08),
                ),
              ),
              child: Center(
                child: emoji != null
                    ? Text(emoji!, style: const TextStyle(fontSize: 18))
                    : Icon(
                        icon,
                        color: active ? AppTheme.accent : Colors.white,
                        size: 18,
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: .70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
