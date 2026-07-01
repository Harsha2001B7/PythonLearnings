import 'package:flutter/foundation.dart';

import 'notification_model.dart';

/// In-memory singleton notification service.
///
/// Exposes a [ValueNotifier] so that widgets can rebuild reactively
/// without any external state-management library.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  /// The single source of truth for all notifications.
  final ValueNotifier<List<AppNotification>> notifier =
      ValueNotifier<List<AppNotification>>(List.unmodifiable(_demoData()));

  // ── Computed helpers ────────────────────────────────────────────────────────

  List<AppNotification> get notifications => notifier.value;

  int get unreadCount =>
      notifier.value.where((n) => !n.isRead).length;

  bool get hasUnread => unreadCount > 0;

  // ── Mutations ───────────────────────────────────────────────────────────────

  /// Marks a single notification as read by [id].
  void markAsRead(String id) {
    final updated = notifier.value.map((n) {
      return n.id == id ? n.copyWith(isRead: true) : n;
    }).toList();
    notifier.value = List.unmodifiable(updated);
  }

  /// Marks every notification as read.
  void markAllRead() {
    final updated =
        notifier.value.map((n) => n.copyWith(isRead: true)).toList();
    notifier.value = List.unmodifiable(updated);
  }

  /// Removes a notification by [id].
  void dismiss(String id) {
    final updated = notifier.value.where((n) => n.id != id).toList();
    notifier.value = List.unmodifiable(updated);
  }

  /// Removes all notifications.
  void clearAll() {
    notifier.value = const [];
  }

  /// Reloads the original 5 demo notifications (used for pull-to-refresh).
  void resetToDemo() {
    notifier.value = List.unmodifiable(_demoData());
  }

  // ── Demo data factory ───────────────────────────────────────────────────────

  static List<AppNotification> _demoData() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'n1',
        title: 'Trailer Released',
        body: 'War 2 Official Trailer is now live. Hrithik vs John.',
        timestamp: now.subtract(const Duration(minutes: 2)),
        emoji: '🔥',
        type: NotificationType.trailerReleased,
      ),
      AppNotification(
        id: 'n2',
        title: 'Coming Soon',
        body: 'KGF Chapter 3 teaser announced. The empire rises again.',
        timestamp: now.subtract(const Duration(hours: 1)),
        emoji: '🎬',
        type: NotificationType.comingSoon,
      ),
      AppNotification(
        id: 'n3',
        title: 'Recommended for You',
        body: 'Because you watched Animal — check out Kabir Singh.',
        timestamp: now.subtract(const Duration(days: 1)),
        emoji: '⭐',
        type: NotificationType.recommendation,
      ),
      AppNotification(
        id: 'n4',
        title: 'Trending Now',
        body: 'Mirzapur Season 3 crossed 75M views in 48 hours.',
        timestamp: now.subtract(const Duration(hours: 5)),
        emoji: '📈',
        type: NotificationType.trending,
      ),
      AppNotification(
        id: 'n5',
        title: 'Welcome to TrailerBaaz',
        body:
            'Your cinematic journey starts here. Discover the latest trailers.',
        timestamp: now.subtract(const Duration(days: 3)),
        emoji: '🎉',
        type: NotificationType.system,
      ),
    ];
  }
}
