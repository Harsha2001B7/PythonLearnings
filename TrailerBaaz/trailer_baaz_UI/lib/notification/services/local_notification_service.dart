import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import '../controllers/notification_controller.dart';
import '../models/notification_item.dart';
import '../models/rich_notification_content.dart';
import 'notification_service.dart';

class LocalNotificationService implements NotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  static const _notificationIcon = 'ic_launcher_foreground';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    debugPrint('[Notification] Initializing LocalNotificationService...');

    const androidSettings = AndroidInitializationSettings(_notificationIcon);

    const initSettings = InitializationSettings(android: androidSettings);

    final initialized = await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onTapNotification,
    );
    debugPrint(
      '[Notification] flutter_local_notifications initialized status: $initialized',
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final launchPayload = launchDetails?.notificationResponse?.payload;
    if (launchDetails?.didNotificationLaunchApp == true &&
        launchPayload != null &&
        launchPayload.isNotEmpty) {
      _handlePayload(launchPayload);
    }

    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    debugPrint('[Notification] Requesting Android notification permission...');
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      final granted = await androidImplementation
          .requestNotificationsPermission();
      debugPrint(
        '[Notification] Android notifications permission status: $granted',
      );
    }
  }

  void _onTapNotification(NotificationResponse details) {
    debugPrint(
      '[Notification] Notification tapped. Payload: ${details.payload}',
    );
    final payloadStr = details.payload;
    if (payloadStr != null && payloadStr.isNotEmpty) {
      _handlePayload(payloadStr);
    }
  }

  void _handlePayload(String payloadStr) {
    try {
      final data = jsonDecode(payloadStr) as Map<String, dynamic>;
      NotificationController.instance.handleNotificationTap(data);
    } catch (error) {
      debugPrint('[Notification] Error decoding payload: $error');
    }
  }

  @override
  Future<void> show(RichNotificationContent notification) async {
    final notificationId = notification.id.hashCode;
    debugPrint(
      '[Notification] Showing instant notification. ID: ${notification.id}, Hash: $notificationId, Title: ${notification.title}, Type: ${notification.type}',
    );

    final enrichedPayload = notification.enrichedPayload();
    final payloadString = jsonEncode(enrichedPayload);
    final styleInformation = await _buildStyleInformation(notification);

    final androidDetails = AndroidNotificationDetails(
      'trailer_baaz_premiere_channel',
      'TrailerBaaz Premieres',
      channelDescription: 'Premium trailer drops and personalized watch alerts',
      icon: _notificationIcon,
      importance: Importance.max,
      priority: Priority.max,
      styleInformation: styleInformation,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      color: const Color(0xFFE50914),
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.recommendation,
      ticker: notification.title,
      subText: 'TrailerBaaz',
      largeIcon: const DrawableResourceAndroidBitmap(_notificationIcon),
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'open_trailer',
          notification.actionLabel,
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    await _plugin.show(
      id: notificationId,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(android: androidDetails),
      payload: payloadString,
    );

    NotificationController.instance.addNotification(
      NotificationItem(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        timestamp: DateTime.now(),
        type: notification.type,
        payload: enrichedPayload,
      ),
    );
  }

  Future<StyleInformation> _buildStyleInformation(
    RichNotificationContent notification,
  ) async {
    final image = await _downloadFirstAvailableImage(notification.imageUrls);
    if (image != null) {
      return BigPictureStyleInformation(
        image,
        contentTitle: notification.title,
        summaryText: '${notification.body} ${notification.actionLabel}.',
        largeIcon: const DrawableResourceAndroidBitmap(_notificationIcon),
        hideExpandedLargeIcon: true,
      );
    }

    return BigTextStyleInformation(
      '${notification.body}\n\n${notification.actionLabel}',
      contentTitle: notification.title,
    );
  }

  Future<ByteArrayAndroidBitmap?> _downloadFirstAvailableImage(
    List<String> imageUrls,
  ) async {
    for (final imageUrl in imageUrls) {
      final uri = Uri.tryParse(imageUrl);
      if (uri == null || !uri.hasScheme) continue;

      try {
        final response = await http
            .get(uri)
            .timeout(const Duration(seconds: 4));
        final contentType = response.headers['content-type'] ?? '';
        if (response.statusCode >= 200 &&
            response.statusCode < 300 &&
            response.bodyBytes.isNotEmpty &&
            contentType.startsWith('image/')) {
          return ByteArrayAndroidBitmap(response.bodyBytes);
        }
      } catch (error) {
        debugPrint(
          '[Notification] Could not load notification image $imageUrl: $error',
        );
      }
    }

    return null;
  }

  @override
  Future<void> cancelAll() async {
    debugPrint('[Notification] Cancelling all active system notifications.');
    await _plugin.cancelAll();
  }
}
