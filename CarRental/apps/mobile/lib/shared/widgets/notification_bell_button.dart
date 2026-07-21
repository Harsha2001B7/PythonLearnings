import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../features/notifications/presentation/views/notification_center_screen.dart';

class NotificationBellButton extends ConsumerWidget {
  const NotificationBellButton({super.key, this.iconColor});
  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadAsync = ref.watch(unreadCountProvider);
    final count = unreadAsync.maybeWhen(data: (c) => c, orElse: () => 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = iconColor ?? (isDark ? AppColors.textDark : AppColors.textLight);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, color: defaultColor, size: 22),
          tooltip: 'Notifications',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationCenterScreen()),
            );
          },
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
