import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'notification_model.dart';
import 'notification_service.dart';

/// A single notification card in the list.
///
/// - Unread: brighter background, bold title, left accent bar.
/// - Read: slightly faded, normal weight.
/// - Swipe left to dismiss (delete).
/// - Tap to mark as read.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onDismissed,
  });

  final AppNotification notification;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: _DismissBackground(),
      child: _TileBody(notification: notification),
    );
  }
}

// ── Dismissal background ────────────────────────────────────────────────────

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.accent.withValues(alpha: 0.15),
            AppTheme.accent.withValues(alpha: 0.85),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: const Icon(
        Icons.delete_outline_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}

// ── Tile body ───────────────────────────────────────────────────────────────

class _TileBody extends StatelessWidget {
  const _TileBody({required this.notification});

  final AppNotification notification;

  Color get _accentBarColor {
    return switch (notification.type) {
      NotificationType.trailerReleased => const Color(0xFFFF6B35),
      NotificationType.comingSoon      => const Color(0xFF7C3AED),
      NotificationType.recommendation  => const Color(0xFFFFD700),
      NotificationType.trending        => const Color(0xFF10B981),
      NotificationType.system          => AppTheme.accent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => NotificationService.instance.markAsRead(notification.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: isUnread
              ? Colors.white.withValues(alpha: 0.065)
              : Colors.white.withValues(alpha: 0.025),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.04),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent bar — only visible for unread items
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isUnread ? 3 : 0,
                  color: _accentBarColor,
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Emoji icon container
                        _EmojiIcon(
                          emoji: notification.emoji,
                          color: _accentBarColor,
                          isUnread: isUnread,
                        ),
                        const SizedBox(width: 12),

                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.title,
                                      style: TextStyle(
                                        color: isUnread
                                            ? Colors.white
                                            : Colors.white
                                                .withValues(alpha: 0.6),
                                        fontSize: 13.5,
                                        fontWeight: isUnread
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _TimeLabel(timestamp: notification.timestamp),
                                ],
                              ),
                              const SizedBox(height: 4),
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: isUnread ? 0.75 : 0.45,
                                child: Text(
                                  notification.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Emoji icon ───────────────────────────────────────────────────────────────

class _EmojiIcon extends StatelessWidget {
  const _EmojiIcon({
    required this.emoji,
    required this.color,
    required this.isUnread,
  });

  final String emoji;
  final Color color;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isUnread
            ? color.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isUnread
              ? color.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.06),
          width: 0.8,
        ),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// ── Relative timestamp ───────────────────────────────────────────────────────

class _TimeLabel extends StatelessWidget {
  const _TimeLabel({required this.timestamp});

  final DateTime timestamp;

  String get _relativeTime {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _relativeTime,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.35),
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
