import 'package:flutter/foundation.dart';

/// Enum representing the category of a notification.
enum NotificationType {
  trailerReleased,
  comingSoon,
  recommendation,
  trending,
  system,
}

/// Immutable model for a single in-app notification.
@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.emoji,
    required this.type,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime timestamp;

  /// Display emoji used as the notification icon.
  final String emoji;

  final NotificationType type;
  final bool isRead;

  /// Returns a copy of this notification with the given fields replaced.
  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    String? emoji,
    NotificationType? type,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotification &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isRead == other.isRead;

  @override
  int get hashCode => Object.hash(id, isRead);
}
