import 'package:flutter/foundation.dart';

enum NotificationType {
  trailerReleased,
  comingSoon,
  recommendation,
  trending,
  watchReminder,
  system,
}

extension NotificationTypeExtension on NotificationType {
  String get name {
    switch (this) {
      case NotificationType.trailerReleased:
        return 'Trailer Released';
      case NotificationType.comingSoon:
        return 'Coming Soon';
      case NotificationType.recommendation:
        return 'Recommendation';
      case NotificationType.trending:
        return 'Trending';
      case NotificationType.watchReminder:
        return 'Watch Reminder';
      case NotificationType.system:
        return 'System';
    }
  }

  String get emoji {
    switch (this) {
      case NotificationType.trailerReleased:
        return '🔥';
      case NotificationType.comingSoon:
        return '🎬';
      case NotificationType.recommendation:
        return '⭐';
      case NotificationType.trending:
        return '📈';
      case NotificationType.watchReminder:
        return '⏰';
      case NotificationType.system:
        return '🎉';
    }
  }
}

@immutable
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic>? payload;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.payload,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    Map<String, dynamic>? payload,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      payload: payload ?? this.payload,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type.index,
      'isRead': isRead,
      'payload': payload,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: NotificationType.values[json['type'] as int],
      isRead: json['isRead'] as bool? ?? false,
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }
}
