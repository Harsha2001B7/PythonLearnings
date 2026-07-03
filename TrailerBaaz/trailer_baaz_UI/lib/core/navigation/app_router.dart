import 'package:flutter/material.dart';

import '../../core/models/trailer.dart';
import '../../features/details/trailer_details_screen.dart';
import '../../features/notifications/simulator/notification_simulator.dart';
import '../../features/shell/app_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../shared/trailer_player/trailer_player_fullscreen.dart';
import 'routes.dart';

/// Builds [Route] instances with the same transitions and settings as before
/// centralization.
abstract final class AppRouter {
  static Route<void> splashToShell() {
    return PageRouteBuilder<void>(
      settings: const RouteSettings(name: AppRoutes.shell),
      transitionDuration: const Duration(milliseconds: 700),
      reverseTransitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const AppShell();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        final scaleIn = Tween<double>(begin: 0.96, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );

        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scaleIn, child: child),
        );
      },
    );
  }

  static Route<void> trailerDetailsFade(Trailer trailer) {
    return PageRouteBuilder<void>(
      settings: RouteSettings(
        name: AppRoutes.trailerDetails,
        arguments: trailer.id,
      ),
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, animation, _) => FadeTransition(
        opacity: animation,
        child: TrailerDetailsScreen(trailer: trailer),
      ),
    );
  }

  static Route<void> trailerDetails(Trailer trailer) {
    return MaterialPageRoute<void>(
      settings: RouteSettings(
        name: AppRoutes.trailerDetails,
        arguments: trailer.id,
      ),
      builder: (_) => TrailerDetailsScreen(trailer: trailer),
    );
  }

  static Route<void> trailerDetailsReplacement(Trailer trailer) {
    return PageRouteBuilder<void>(
      settings: RouteSettings(
        name: AppRoutes.trailerDetails,
        arguments: trailer.id,
      ),
      pageBuilder: (_, animation, _) => FadeTransition(
        opacity: animation,
        child: TrailerDetailsScreen(trailer: trailer),
      ),
    );
  }

  static Route<void> notificationSimulator() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: AppRoutes.notificationSimulator),
      builder: (_) => const NotificationSimulatorScreen(),
    );
  }

  static Route<void> logoutToSplash() {
    return PageRouteBuilder<void>(
      settings: const RouteSettings(name: AppRoutes.splash),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
        opacity: animation,
        child: const SplashScreen(),
      ),
    );
  }

  static Route<void> trailerPlayer({
    required String trailerId,
    required WidgetBuilder builder,
  }) {
    return TrailerPlayerRoute(
      trailerId: trailerId,
      builder: builder,
    );
  }
}
