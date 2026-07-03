import 'package:flutter/material.dart';

import 'app/trailer_baaz_app.dart';
import 'core/data/home_experience_provider.dart';
import 'core/data/youtube_trailers_provider.dart';
import 'core/di/locator.dart';
import 'features/notifications/services/local_notification_service.dart';
import 'features/notifications/controllers/notification_controller.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  setupLocator();

  await locator<LocalNotificationService>().initialize();
  locator<NotificationController>().setNavigatorKey(navigatorKey);
  locator<NotificationController>().loadDemoNotifications();

  // Initialize providers
  locator<YoutubeTrailersProvider>().init();
  locator<HomeExperienceProvider>().init();
  runApp(const TrailerBaazApp());
}
