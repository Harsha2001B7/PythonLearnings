import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'notification_service.dart';
import 'notification_sheet.dart';

/// Drop-in replacement for the old `_NotificationBell`.
///
/// Renders a bell icon button and an animated badge showing the unread count.
/// Only rebuilds the badge portion when the notification list changes.
class NotificationBadge extends StatelessWidget {
  const NotificationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List>(
      valueListenable: NotificationService.instance.notifier,
      builder: (context, notifications, _) {
        final unread = NotificationService.instance.unreadCount;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => showNotificationSheet(context),
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            if (unread > 0)
              Positioned(
                top: 0,
                right: 0,
                child: _UnreadBadge(count: unread),
              ),
          ],
        );
      },
    );
  }
}

/// Animated badge chip showing the unread notification count.
class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  String get _label => count > 9 ? '9+' : '$count';

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Container(
        key: ValueKey(count),
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.85),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.5),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Text(
          _label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
