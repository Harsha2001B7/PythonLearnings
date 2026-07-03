import 'package:flutter/material.dart';

import '../../core/models/trailer.dart';
import '../../features/details/trailer_details_screen.dart';
import '../../features/notifications/simulator/notification_simulator.dart';
import '../../features/shell/app_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../shared/animations/animations.dart';
import '../../shared/trailer_player/trailer_player_fullscreen.dart';
import 'routes.dart';

/// Builds [Route] instances with the same transitions and settings as before
/// centralization.
abstract final class AppRouter {
  static Route<void> splashToShell() {
    return AppPageTransitions.fadeScale<void>(
      settings: const RouteSettings(name: AppRoutes.shell),
      page: const AppShell(),
    );
  }

  static Route<void> trailerDetailsFade(Trailer trailer) {
    return AppPageTransitions.fade<void>(
      settings: RouteSettings(
        name: AppRoutes.trailerDetails,
        arguments: trailer.id,
      ),
      page: TrailerDetailsScreen(trailer: trailer),
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
    return AppPageTransitions.fade<void>(
      settings: RouteSettings(
        name: AppRoutes.trailerDetails,
        arguments: trailer.id,
      ),
      page: TrailerDetailsScreen(trailer: trailer),
      transitionDuration: AppMotion.routeMaterialDefault,
      reverseTransitionDuration: AppMotion.routeMaterialDefault,
    );
  }

  static Route<void> notificationSimulator() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: AppRoutes.notificationSimulator),
      builder: (_) => const NotificationSimulatorScreen(),
    );
  }

  static Route<void> logoutToSplash() {
    return AppPageTransitions.fade<void>(
      settings: const RouteSettings(name: AppRoutes.splash),
      page: const SplashScreen(),
      transitionDuration: AppMotion.routeLogout,
      reverseTransitionDuration: AppMotion.routeLogout,
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
