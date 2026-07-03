import 'package:flutter/material.dart';

/// Applies a [FadeTransition] to [child].
class FadeEntrance extends StatelessWidget {
  const FadeEntrance({
    super.key,
    required this.opacity,
    required this.child,
  });

  final Animation<double> opacity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: opacity, child: child);
  }
}

/// Applies [FadeTransition] + [ScaleTransition] to [child].
class FadeScaleEntrance extends StatelessWidget {
  const FadeScaleEntrance({
    super.key,
    required this.opacity,
    required this.scale,
    required this.child,
  });

  final Animation<double> opacity;
  final Animation<double> scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: ScaleTransition(scale: scale, child: child),
    );
  }
}
