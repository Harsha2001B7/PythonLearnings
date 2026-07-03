import 'package:flutter/material.dart';

/// Shared motion tokens used across the app.
///
/// Values mirror the durations and curves already in use — not a redesign.
abstract final class AppMotion {
  static const Curve cinematic = Curves.easeOutCubic;

  static const Duration pressScaleFast = Duration(milliseconds: 140);
  static const Duration pressScaleForward = Duration(milliseconds: 150);
  static const Duration pressScaleReverse = Duration(milliseconds: 200);

  static const Duration routeFadeForward = Duration(milliseconds: 420);
  static const Duration routeFadeReverse = Duration(milliseconds: 280);
  static const Duration routeMaterialDefault = Duration(milliseconds: 300);
  static const Duration routeFadeScale = Duration(milliseconds: 700);
  static const Duration routeLogout = Duration(milliseconds: 500);
  static const Duration routePlayerForward = Duration(milliseconds: 260);
  static const Duration routePlayerReverse = Duration(milliseconds: 200);

  static const Duration fadeSwitcher = Duration(milliseconds: 400);
  static const Duration glowOpacity = Duration(milliseconds: 120);
  static const Duration buttonColumnOpacity = Duration(milliseconds: 180);

  static const double routeScaleBegin = 0.96;
  static const double pressScaleCard = 0.97;
  static const double pressScaleButton = 0.95;
  static const Offset slideUpSmall = Offset(0, 0.18);
  static const Offset slideUpMedium = Offset(0, 0.24);
}
