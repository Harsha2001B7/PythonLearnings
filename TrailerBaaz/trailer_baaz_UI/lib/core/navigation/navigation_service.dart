import 'package:flutter/material.dart';

import '../../core/models/trailer.dart';
import '../../features/shell/app_shell.dart';
import 'app_router.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Single entry point for imperative navigation across the app.
class NavigationService {
  NavigationService(this._navigatorKey);

  final GlobalKey<NavigatorState> _navigatorKey;

  NavigatorState? get _globalNavigator => _navigatorKey.currentState;

  void setShellTab(BuildContext context, ShellTab tab) {
    AppShell.setIndex(context, tab.tabIndex);
  }

  void replaceWithShell(BuildContext context) {
    Navigator.of(context).pushReplacement(AppRouter.splashToShell());
  }

  void pushTrailerDetailsFade(BuildContext context, Trailer trailer) {
    Navigator.of(context).push(AppRouter.trailerDetailsFade(trailer));
  }

  void pushTrailerDetails(BuildContext context, Trailer trailer) {
    Navigator.of(context).push(AppRouter.trailerDetails(trailer));
  }

  void replaceTrailerDetails(BuildContext context, Trailer trailer) {
    Navigator.of(context).pushReplacement(
      AppRouter.trailerDetailsReplacement(trailer),
    );
  }

  void pushTrailerDetailsGlobal(Trailer trailer) {
    _globalNavigator?.push(AppRouter.trailerDetails(trailer));
  }

  void openNotificationSimulator(BuildContext context) {
    Navigator.of(context).push(AppRouter.notificationSimulator());
  }

  void logoutToSplash(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      AppRouter.logoutToSplash(),
      (route) => false,
    );
  }

  Future<T?> pushRoute<T extends Object?>(
    BuildContext context,
    Route<T> route, {
    bool rootNavigator = false,
  }) {
    return Navigator.of(context, rootNavigator: rootNavigator).push(route);
  }

  void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  void replaceWithTrailerDetailsFromPlayer(
    BuildContext context,
    Trailer trailer,
  ) {
    Navigator.of(context).pushReplacement(AppRouter.trailerDetails(trailer));
  }
}
