import 'package:flutter/material.dart';

import '../app_motion.dart';

/// [AnimatedSwitcher] with the app's standard fade transition.
class AnimatedFadeSwitcher extends StatelessWidget {
  const AnimatedFadeSwitcher({
    super.key,
    required this.child,
    this.duration = AppMotion.fadeSwitcher,
    this.switchInCurve = Curves.easeIn,
    this.switchOutCurve = Curves.easeOut,
    this.layoutBuilder = AnimatedSwitcher.defaultLayoutBuilder,
  });

  final Widget child;
  final Duration duration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final AnimatedSwitcherLayoutBuilder layoutBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      layoutBuilder: layoutBuilder,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: child,
    );
  }
}
