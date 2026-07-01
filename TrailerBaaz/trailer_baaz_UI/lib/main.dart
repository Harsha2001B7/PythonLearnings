import 'package:flutter/material.dart';

import 'app/trailer_baaz_app.dart';
import 'core/data/home_experience_provider.dart';
import 'core/data/youtube_trailers_provider.dart';
import 'notification/services/local_notification_service.dart';
import 'notification/controllers/notification_controller.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Notification Service
  await LocalNotificationService.instance.initialize();
  NotificationController.instance.setNavigatorKey(navigatorKey);
  NotificationController.instance.loadDemoNotifications();

  // Kick off background data load immediately
  YoutubeTrailersProvider.instance.init();
  HomeExperienceProvider.instance.init();
  runApp(const TrailerBaazApp());
}
