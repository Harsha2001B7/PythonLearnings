import 'package:flutter/material.dart';

import '../app_motion.dart';

/// Reusable [PageRouteBuilder] factories and transition builders.
abstract final class AppPageTransitions {
  /// Fade-only route; child is wrapped in [FadeTransition] inside [pageBuilder].
  static Route<T> fade<T>({
    required RouteSettings settings,
    required Widget page,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: transitionDuration ?? AppMotion.routeFadeForward,
      reverseTransitionDuration:
          reverseTransitionDuration ?? AppMotion.routeFadeReverse,
      pageBuilder: (_, animation, _) => FadeTransition(
        opacity: animation,
        child: page,
      ),
    );
  }

  /// Fade + scale route; transition applied in [transitionsBuilder].
  static Route<T> fadeScale<T>({
    required RouteSettings settings,
    required Widget page,
    Duration transitionDuration = AppMotion.routeFadeScale,
    Duration reverseTransitionDuration = AppMotion.routeFadeScale,
    double beginScale = AppMotion.routeScaleBegin,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: AppMotion.cinematic,
        );
        final scale = Tween<double>(begin: beginScale, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: AppMotion.cinematic),
        );
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
    );
  }

  /// Curved fade used by fullscreen player routes.
  static Widget curvedFade({
    required Animation<double> animation,
    required Widget child,
    Curve curve = AppMotion.cinematic,
    Curve reverseCurve = Curves.easeInCubic,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: curve,
        reverseCurve: reverseCurve,
      ),
      child: child,
    );
  }
}
