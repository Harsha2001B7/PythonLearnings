import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../../../core/di/locator.dart';
import '../controllers/notification_controller.dart';
import '../../../app/app_theme.dart';

class NotificationTile extends StatelessWidget {
  final NotificationItem item;

  const NotificationTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !item.isRead;
    
    return Dismissible(
      key: Key(item.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.green.withValues(alpha: 0.2),
        child: const Icon(Icons.check_circle_outline, color: Colors.green),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.accent.withValues(alpha: 0.2),
        child: const Icon(Icons.delete_outline, color: AppTheme.accent),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe Right: Mark as Read
          locator<NotificationController>().markAsRead(item.id);
          return false; // Do not dismiss from UI list
        } else if (direction == DismissDirection.endToStart) {
          // Swipe Left: Delete
          locator<NotificationController>().deleteNotification(item.id);
          return true; // Perform dismissal
        }
        return false;
      },
      child: InkWell(
        onTap: () {
          if (item.payload != null) {
            locator<NotificationController>().handleNotificationTap(item.payload!);
          } else {
            locator<NotificationController>().markAsRead(item.id);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUnread
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isUnread ? AppTheme.accent : Colors.transparent,
                width: 3,
              ),
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    item.type.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.type.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isUnread ? AppTheme.accent : AppTheme.muted,
                          ),
                        ),
                        Text(
                          _formatTime(item.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                        color: isUnread ? Colors.white : Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.body,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
