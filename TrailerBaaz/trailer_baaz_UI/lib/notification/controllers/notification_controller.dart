import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../../core/data/youtube_trailers_provider.dart';
import '../../features/details/trailer_details_screen.dart';

class NotificationController {
  NotificationController._();
  static final NotificationController instance = NotificationController._();

  final ValueNotifier<List<NotificationItem>> notifications =
      ValueNotifier<List<NotificationItem>>([]);

  GlobalKey<NavigatorState>? _navigatorKey;
  Map<String, dynamic>? _pendingTapPayload;
  bool _listeningForTrailerData = false;

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) => _flushPendingTap());
  }

  int get unreadCount => notifications.value.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  void loadDemoNotifications() {
    final now = DateTime.now();
    notifications.value = [
      NotificationItem(
        id: 'demo1',
        title: '🔥 Trailer Released',
        body: 'War 2 Official Trailer is now live.',
        timestamp: now.subtract(const Duration(minutes: 2)),
        type: NotificationType.trailerReleased,
        payload: {'trailerId': '2'},
      ),
      NotificationItem(
        id: 'demo2',
        title: '🎬 Coming Soon',
        body: 'KGF Chapter 3 teaser announced.',
        timestamp: now.subtract(const Duration(hours: 1)),
        type: NotificationType.comingSoon,
      ),
      NotificationItem(
        id: 'demo3',
        title: '⭐ Recommendation',
        body: 'Because you watched Animal.',
        timestamp: now.subtract(const Duration(days: 1)),
        type: NotificationType.recommendation,
      ),
      NotificationItem(
        id: 'demo4',
        title: '📈 Trending',
        body: 'Mirzapur crossed 75M views.',
        timestamp: now,
        type: NotificationType.trending,
      ),
      NotificationItem(
        id: 'demo5',
        title: '🎉 Welcome',
        body: 'Welcome to TrailerBaaz.',
        timestamp: now,
        type: NotificationType.system,
      ),
    ];
  }

  void addNotification(NotificationItem item) {
    final list = List<NotificationItem>.from(notifications.value);
    // Avoid duplicates if added from background action
    if (list.any((n) => n.id == item.id)) return;
    list.insert(0, item);
    notifications.value = list;
  }

  void markAsRead(String id) {
    notifications.value = notifications.value.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
  }

  void markAllRead() {
    notifications.value = notifications.value.map((n) {
      return n.copyWith(isRead: true);
    }).toList();
  }

  void deleteNotification(String id) {
    notifications.value = notifications.value.where((n) => n.id != id).toList();
  }

  void clearAll() {
    notifications.value = [];
  }

  void handleNotificationTap(Map<String, dynamic> payload) {
    final notificationId = payload['notification_id'] as String?;
    if (notificationId != null) {
      markAsRead(notificationId);
    } else {
      // Direct notification tapped from background/payload init
      final title = payload['notification_title'] as String? ?? 'Notification';
      final body = payload['notification_body'] as String? ?? '';
      final typeIndex = payload['notification_type'] as int? ?? 5;
      final newNotif = NotificationItem(
        id: notificationId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        timestamp: DateTime.now(),
        type: NotificationType.values[typeIndex],
        isRead: true,
        payload: payload,
      );
      addNotification(newNotif);
    }

    _openTrailerFromPayload(payload);
  }

  void _openTrailerFromPayload(Map<String, dynamic> payload) {
    final trailerId = payload['trailerId']?.toString();
    if (trailerId == null || trailerId.isEmpty) return;

    final navigator = _navigatorKey?.currentState;
    final trailers = YoutubeTrailersProvider.instance.allTrailers;

    if (navigator == null || trailers.isEmpty) {
      _queuePendingTap(payload);
      return;
    }

    final trailer = trailers.firstWhere(
      (t) => t.id == trailerId,
      orElse: () => trailers.first,
    );

    navigator.push(
      MaterialPageRoute(builder: (_) => TrailerDetailsScreen(trailer: trailer)),
    );
  }

  void _queuePendingTap(Map<String, dynamic> payload) {
    _pendingTapPayload = Map<String, dynamic>.from(payload);
    if (!_listeningForTrailerData) {
      _listeningForTrailerData = true;
      YoutubeTrailersProvider.instance.addListener(_flushPendingTap);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _flushPendingTap());
  }

  void _flushPendingTap() {
    final payload = _pendingTapPayload;
    if (payload == null) return;

    final navigator = _navigatorKey?.currentState;
    final trailers = YoutubeTrailersProvider.instance.allTrailers;
    if (navigator == null || trailers.isEmpty) return;

    _pendingTapPayload = null;
    if (_listeningForTrailerData) {
      _listeningForTrailerData = false;
      YoutubeTrailersProvider.instance.removeListener(_flushPendingTap);
    }

    _openTrailerFromPayload(payload);
  }
}
