import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../storage/secure_storage.dart';
import '../network/api_endpoints.dart';
import '../router/app_router.dart';
import '../../features/admin/presentation/views/admin_navigation_shell.dart';
import '../../features/profile/presentation/views/my_bookings_screen.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
}

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _currentToken;
  bool _initialized = false;
  BuildContext? _navigatorContext;
  Map<String, dynamic>? _pendingDeepLink;

  void setNavigatorContext(BuildContext context) {
    _navigatorContext = context;
    if (_pendingDeepLink != null) {
      final pending = _pendingDeepLink!;
      _pendingDeepLink = null;
      Future.microtask(() => _handleDeepLink(pending));
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      _initialized = true;

      // 1. Request Permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('FCM Notification permission status: ${settings.authorizationStatus}');

      // 2. Local Notifications Setup for Foreground Popups
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final data = jsonDecode(response.payload!) as Map<String, dynamic>;
              _handleDeepLink(data);
            } catch (e) {
              debugPrint('Error parsing notification payload: $e');
            }
          }
        },
      );

      // Create Android Notification Channel
      const androidChannel = AndroidNotificationChannel(
        'falconview_notifications',
        'FalconView Priority Alerts',
        description: 'Real-time booking updates, approvals, and account notifications',
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      // Set Background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. Foreground Message Listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Foreground Message Received: ${message.notification?.title}');
        _showForegroundNotification(message);
      });

      // 4. Background Click Listener (when app in background and tapped)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM Notification Clicked (Background App): ${message.data}');
        _handleDeepLink(message.data);
      });

      // 5. Terminated State Click Check
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('FCM Notification Clicked (Terminated App): ${initialMessage.data}');
        _handleDeepLink(initialMessage.data);
      }

      // 6. Token Listener
      _messaging.onTokenRefresh.listen((newToken) {
        _currentToken = newToken;
        debugPrint('FCM Token Refreshed: $newToken');
        syncTokenToBackend();
      });

      // Get initial token with timeout
      _currentToken = await _messaging.getToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      debugPrint('FCM Token Obtained: $_currentToken');
    } catch (e) {
      debugPrint('Error initializing FCM service: $e');
    }
  }

  Future<void> syncTokenToBackend() async {
    if (_currentToken == null || _currentToken!.isEmpty) {
      _currentToken = await _messaging.getToken();
    }
    if (_currentToken == null || _currentToken!.isEmpty) return;

    try {
      final dio = await _getDio();
      final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other');
      await dio.post(
        '${ApiEndpoints.baseUrl}/api/v1/notifications/devices',
        data: {
          'fcm_token': _currentToken,
          'platform': platform,
          'device_name': Platform.operatingSystem,
          'app_version': '1.0.0',
        },
      );
      debugPrint('FCM Token successfully synced to backend.');
    } catch (e) {
      debugPrint('Failed to sync FCM token to backend: $e');
    }
  }

  Future<void> unregisterTokenFromBackend() async {
    if (_currentToken == null || _currentToken!.isEmpty) return;
    try {
      final dio = await _getDio();
      await dio.delete('${ApiEndpoints.baseUrl}/api/v1/notifications/devices/$_currentToken');
      debugPrint('FCM Token removed from backend on logout.');
    } catch (e) {
      debugPrint('Failed to unregister FCM token: $e');
    }
  }

  Future<Dio> _getDio() async {
    final dio = Dio();
    final token = await SecureStorage().getAccessToken();
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
    return dio;
  }

  Future<Uint8List?> _downloadImageBytes(String url) async {
    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.data != null) {
        return Uint8List.fromList(response.data!);
      }
    } catch (e) {
      debugPrint('Failed to download notification image: $e');
    }
    return null;
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final imgUrl = message.data['vehicle_image'] ?? message.data['image_url'] ?? notification.android?.imageUrl;
    BigPictureStyleInformation? bigPictureStyle;
    ByteArrayAndroidBitmap? largeIconBitmap;

    if (imgUrl != null && imgUrl.isNotEmpty) {
      final bytes = await _downloadImageBytes(imgUrl);
      if (bytes != null) {
        final bitmap = ByteArrayAndroidBitmap(bytes);
        bigPictureStyle = BigPictureStyleInformation(
          bitmap,
          largeIcon: bitmap,
          contentTitle: notification.title,
          summaryText: notification.body,
        );
        largeIconBitmap = bitmap;
      }
    }

    final androidDetails = AndroidNotificationDetails(
      'falconview_notifications',
      'FalconView Priority Alerts',
      channelDescription: 'Real-time booking updates, approvals, and account notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: largeIconBitmap,
      styleInformation: bigPictureStyle,
      color: const Color(0xFFD4AF37),
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'view_booking',
          'View Reservation',
          showsUserInterface: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
    final notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  void _handleDeepLink(Map<String, dynamic> data) {
    if (_navigatorContext == null || !(_navigatorContext!.mounted)) {
      debugPrint('Navigator context not ready. Caching deep link for instant execution: $data');
      _pendingDeepLink = data;
      return;
    }

    final route = data['action_route'] as String?;
    final nType = data['notification_type'] as String?;
    final isBookingNotif = nType != null && nType.contains('booking');

    if (route == '/admin' || (isBookingNotif && route != '/vehicle')) {
      // Admin notification → switch to Admin Bookings tab
      try {
        final container = ProviderScope.containerOf(_navigatorContext!, listen: false);
        container.read(adminTabProvider.notifier).state = 2;
      } catch (e) {
        debugPrint('Could not update adminTabProvider: $e');
      }
      _navigatorContext!.go(AppRoute.adminHome);
    } else if (isBookingNotif) {
      // Regular user booking notification → go to My Bookings
      Navigator.of(_navigatorContext!).push(
        MaterialPageRoute(
          builder: (context) => const MyBookingsScreen(),
        ),
      );
    } else if (route == '/fleet') {
      _navigatorContext!.go(AppRoute.fleet);
    } else {
      _navigatorContext!.push(AppRoute.notifications);
    }
  }
}
