import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

/// A simple circular progress indicator styled with [AppTheme.accent].
///
/// Drop-in replacement for the raw [CircularProgressIndicator] calls
/// scattered across the codebase.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.size = 36.0});

  /// Diameter of the progress ring.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
      ),
    );
  }
}
