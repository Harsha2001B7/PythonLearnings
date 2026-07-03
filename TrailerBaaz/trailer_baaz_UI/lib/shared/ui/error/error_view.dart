import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import 'retry_button.dart';

/// A full-area error state with an [icon], [title], optional [subtitle]
/// and an optional Retry action.
///
/// Matches the visual style of the original inline error block in
/// `home_screen.dart` so the UI is identical after the refactor.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.icon = Icons.wifi_off_rounded,
    this.title = 'Could not load content',
    this.subtitle,
    this.onRetry,
  });

  /// Leading icon displayed above the title.
  final IconData icon;

  /// Primary error message.
  final String title;

  /// Optional secondary message shown below the title.
  final String? subtitle;

  /// When non-null a [RetryButton] is rendered and this callback is invoked
  /// when the user taps it.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.white38),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.muted,
                fontSize: 13,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            RetryButton(onPressed: onRetry!),
          ],
        ],
      ),
    );
  }
}
