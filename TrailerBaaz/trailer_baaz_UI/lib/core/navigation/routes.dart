/// Named route identifiers and shell tab indices used across the app.
abstract final class AppRoutes {
  static const splash = '/';
  static const shell = '/shell';
  static const trailerDetails = '/trailer/details';
  static const trailerPlayer = '/trailer/player';
  static const notificationSimulator = '/dev/notifications';

  static String trailerPlayerName(String trailerId) => 'trailer-player:$trailerId';
}

/// Bottom-nav and hidden shell tabs. Index values match [AppShell] PageView order.
enum ShellTab {
  home(0),
  discover(1),
  search(2),
  preferences(3),
  profile(4);

  const ShellTab(this.tabIndex);

  final int tabIndex;
}
