import '../models/notification_item.dart';

abstract class NotificationService {
  Future<void> initialize();
  Future<void> show({
    required String id,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? payload,
    Duration? delay,
  });
  Future<void> cancelAll();
}
