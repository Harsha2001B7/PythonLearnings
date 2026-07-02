import '../models/rich_notification_content.dart';

abstract class NotificationService {
  Future<void> initialize();
  Future<void> show(RichNotificationContent notification);
  Future<void> cancelAll();
}
