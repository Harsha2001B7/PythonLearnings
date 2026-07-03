import 'package:flutter/material.dart';

import '../app_motion.dart';

/// Paired fade + upward slide animations driven by the same curved parent.
class FadeSlideAnimations {
  const FadeSlideAnimations({
    required this.fade,
    required this.slide,
  });

  final Animation<double> fade;
  final Animation<Offset> slide;

  /// Builds matched fade/slide animations from a controller interval.
  factory FadeSlideAnimations.fromInterval({
    required Animation<double> parent,
    required Interval interval,
    Offset slideBegin = AppMotion.slideUpSmall,
  }) {
    final curved = CurvedAnimation(parent: parent, curve: interval);
    return FadeSlideAnimations(
      fade: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
      slide: Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(curved),
    );
  }
}

/// Applies [FadeTransition] + [SlideTransition] to [child].
class FadeSlideEntrance extends StatelessWidget {
  const FadeSlideEntrance({
    super.key,
    required this.opacity,
    required this.position,
    required this.child,
  });

  FadeSlideEntrance.from({
    super.key,
    required FadeSlideAnimations animations,
    required this.child,
  })  : opacity = animations.fade,
        position = animations.slide;

  final Animation<double> opacity;
  final Animation<Offset> position;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(position: position, child: child),
    );
  }
}
