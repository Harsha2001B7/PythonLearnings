import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

/// A standalone retry button.
///
/// Styled identically to the inline `FilledButton` used for error recovery
/// throughout the app (background: [AppTheme.accent], label: "Retry").
class RetryButton extends StatelessWidget {
  const RetryButton({super.key, required this.onPressed, this.label = 'Retry'});

  /// Called when the button is tapped.
  final VoidCallback onPressed;

  /// Button label. Defaults to "Retry".
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(backgroundColor: AppTheme.accent),
      child: Text(label),
    );
  }
}
