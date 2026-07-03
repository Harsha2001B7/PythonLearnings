import 'package:flutter/material.dart';

import 'error_view.dart';

/// A pre-configured network / data error widget.
///
/// Shows a wifi-off icon with "Could not load trailers" copy and an optional
/// Retry button — matching the original inline error in `home_screen.dart`
/// exactly.
class NetworkError extends StatelessWidget {
  const NetworkError({
    super.key,
    this.title = 'Could not load trailers',
    this.onRetry,
  });

  /// Primary error message.
  final String title;

  /// When non-null, a Retry button is displayed.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      icon: Icons.wifi_off_rounded,
      title: title,
      onRetry: onRetry,
    );
  }
}
