import 'package:flutter/material.dart';

import 'loading_indicator.dart';

/// A full-screen overlay that blocks interaction and shows a centered
/// [LoadingIndicator].
///
/// Wrap a [Stack] with this as the top layer, or place it as the body
/// of a [Scaffold] while content is unavailable.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.indicatorSize = 42.0});

  final double indicatorSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingIndicator(size: indicatorSize),
    );
  }
}
