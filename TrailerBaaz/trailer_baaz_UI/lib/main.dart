import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/trailer_baaz_app.dart';
import 'core/data/home_experience_provider.dart';
import 'core/data/youtube_trailers_provider.dart';
import 'core/di/locator.dart';
import 'core/services/image_cache_service.dart';
import 'features/notifications/services/local_notification_service.dart';
import 'features/notifications/controllers/notification_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup logging / error handling for production
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[Error] Unhandled Flutter framework exception: ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('[Error] Unhandled platform exception: $error\n$stack');
    return true; // Prevent app termination on minor errors
  };

  // Premium Error Fallback Widget
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: const Color(0xFF090909),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🍿',
                    style: TextStyle(fontSize: 54),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'An unexpected rendering error occurred. Please try reloading the app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0x99FFFFFF), // AppTheme.muted
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700), // AppTheme.accent
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(140, 48),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  };

  // Lock default layout orientation to Portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  setupLocator();
  locator<ImageCacheService>().configure();

  await locator<LocalNotificationService>().initialize();
  locator<NotificationController>().loadDemoNotifications();

  // Initialize providers
  locator<YoutubeTrailersProvider>().init();
  locator<HomeExperienceProvider>().init();
  runApp(const TrailerBaazApp());
}
