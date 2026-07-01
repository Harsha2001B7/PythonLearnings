import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/notification_item.dart';
import '../controllers/notification_controller.dart';
import 'notification_service.dart';

class LocalNotificationService implements NotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    debugPrint('[Notification] Initializing LocalNotificationService...');
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    final bool? initialized = await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onTapNotification,
    );
    debugPrint('[Notification] flutter_local_notifications initialized status: $initialized');

    // Request permissions for Android 13+ (POST_NOTIFICATIONS)
    await requestPermissions();
  }

  /// Explicitly requests post notification and exact alarm permissions for Android.
  Future<void> requestPermissions() async {
    debugPrint('[Notification] Requesting Android system permissions...');
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      debugPrint('[Notification] Android notifications permission status: $granted');
      
      final bool? exactAlarmGranted = await androidImplementation.requestExactAlarmsPermission();
      debugPrint('[Notification] Android exact alarm permission status: $exactAlarmGranted');
    }
  }

  void _onTapNotification(NotificationResponse details) {
    debugPrint('[Notification] Notification tapped. Payload: ${details.payload}');
    final payloadStr = details.payload;
    if (payloadStr != null && payloadStr.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(payloadStr);
        NotificationController.instance.handleNotificationTap(data);
      } catch (e) {
        debugPrint('[Notification] Error decoding payload: $e');
      }
    }
  }

  @override
  Future<void> show({
    required String id,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? payload,
    Duration? delay,
  }) async {
    final int notificationId = id.hashCode;
    debugPrint('[Notification] Scheduling/Showing notification. ID: $id, Hash: $notificationId, Title: $title, Type: $type, Delay: $delay');
    
    final enrichedPayload = Map<String, dynamic>.from(payload ?? {});
    enrichedPayload['notification_id'] = id;
    enrichedPayload['notification_title'] = title;
    enrichedPayload['notification_body'] = body;
    enrichedPayload['notification_type'] = type.index;

    final String payloadString = jsonEncode(enrichedPayload);

    // Create high importance notification details channel matching OS-level requirements.
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'trailer_updates_channel', // Shared production-quality Channel ID
      'Trailer Updates', // Channel Name
      channelDescription: 'Official Trailer updates and discover alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    if (delay != null && delay.inSeconds > 0) {
      final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);
      debugPrint('[Notification] Scheduling zonedSchedule at $scheduledTime');
      
      await _plugin.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payloadString,
      );

      // Listen for local system delivery side-effects in-memory
      // Note: For background schedules, the OS takes over delivery. We also programmatically insert
      // when the user schedules to make sure the in-app list stays updated immediately.
      NotificationController.instance.addNotification(
        NotificationItem(
          id: id,
          title: title,
          body: body,
          timestamp: DateTime.now().add(delay),
          type: type,
          payload: enrichedPayload,
        ),
      );
      
      debugPrint('[Notification] Notification successfully scheduled with Android OS.');
    } else {
      debugPrint('[Notification] Displaying notification instantly via plugin.show');
      await _plugin.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payloadString,
      );

      NotificationController.instance.addNotification(
        NotificationItem(
          id: id,
          title: title,
          body: body,
          timestamp: DateTime.now(),
          type: type,
          payload: enrichedPayload,
        ),
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    debugPrint('[Notification] Cancelling all active system notifications.');
    await _plugin.cancelAll();
  }
}
