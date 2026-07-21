import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/theme_toggle_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../profile/presentation/views/my_bookings_screen.dart';
import '../../data/models/notification_models.dart';
import '../../data/repositories/notification_repository.dart';

final notificationsListProvider = FutureProvider.autoDispose<List<NotificationItemModel>>((ref) async {
  final repo = ref.read(notificationRepositoryProvider);
  return repo.fetchNotifications();
});

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.read(notificationRepositoryProvider);
  return repo.fetchUnreadCount();
});

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends ConsumerState<NotificationCenterScreen> {
  String _activeFilter = 'All'; // 'All' or 'Unread'

  @override
  Widget build(BuildContext context) {
    final asyncNotifications = ref.watch(notificationsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final surface2 = isDark ? AppColors.surface2Dark : AppColors.surface2Light;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: AppColors.orange, size: 20),
            tooltip: 'Mark all as read',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref.read(notificationRepositoryProvider).markAllAsRead();
                ref.invalidate(notificationsListProvider);
                ref.invalidate(unreadCountProvider);
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text('All notifications marked as read'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              } catch (_) {}
            },
          ),
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ─── Filter Tabs Header ─────────────────────────────────────────────
          Container(
            color: surface,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: ['All', 'Unread'].map((filter) {
                final isSelected = _activeFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _activeFilter = filter),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.orange : surface2,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: isSelected ? AppColors.orange : borderColor),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ─── Notification List ──────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: AppColors.orange,
              onRefresh: () async {
                ref.invalidate(notificationsListProvider);
                ref.invalidate(unreadCountProvider);
              },
              child: asyncNotifications.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.orange)),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Failed to load notifications:\n$err',
                      style: TextStyle(color: textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (allList) {
                  final list = _activeFilter == 'Unread'
                      ? allList.where((n) => !n.isRead).toList()
                      : allList;

                  if (list.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.notifications_none_rounded, size: 56, color: textMuted),
                              const SizedBox(height: 16),
                              Text(
                                _activeFilter == 'Unread' ? 'No Unread Notifications' : 'No Notifications Yet',
                                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'You will receive updates about your bookings and account here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: textMuted, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Date Grouping (Today, Yesterday, Earlier)
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final yesterday = today.subtract(const Duration(days: 1));

                  final Map<String, List<NotificationItemModel>> grouped = {
                    'Today': [],
                    'Yesterday': [],
                    'Earlier': [],
                  };

                  for (final item in list) {
                    final itemDate = DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day);
                    if (itemDate.isAtSameMomentAs(today)) {
                      grouped['Today']!.add(item);
                    } else if (itemDate.isAtSameMomentAs(yesterday)) {
                      grouped['Yesterday']!.add(item);
                    } else {
                      grouped['Earlier']!.add(item);
                    }
                  }

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      for (final section in ['Today', 'Yesterday', 'Earlier'])
                        if (grouped[section]!.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 12),
                            child: Text(
                              section.toUpperCase(),
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          ...grouped[section]!.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _NotificationCardItem(
                                  item: item,
                                  isDark: isDark,
                                  surface2: surface2,
                                  textColor: textColor,
                                  textMuted: textMuted,
                                  borderColor: borderColor,
                                  onTap: () async {
                                    final router = GoRouter.of(context);
                                    final navigator = Navigator.of(context);
                                    if (!item.isRead) {
                                      await ref.read(notificationRepositoryProvider).markAsRead(item.id);
                                      ref.invalidate(notificationsListProvider);
                                      ref.invalidate(unreadCountProvider);
                                    }
                                    final isBookingNotif = item.notificationType.contains('booking') || item.bookingId != null;
                                    if (isBookingNotif || item.actionRoute == '/admin') {
                                      final authState = ref.read(authControllerProvider);
                                      final isAdmin = authState is AuthAuthenticated && authState.user.isAdmin;
                                      if (isAdmin) {
                                        router.go(AppRoute.adminHome);
                                      } else {
                                        navigator.push(
                                          MaterialPageRoute(builder: (context) => const MyBookingsScreen()),
                                        );
                                      }
                                    } else if (item.actionRoute == '/fleet') {
                                      router.go(AppRoute.fleet);
                                    }
                                  },
                                ),
                              )),
                        ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCardItem extends StatelessWidget {
  const _NotificationCardItem({
    required this.item,
    required this.isDark,
    required this.surface2,
    required this.textColor,
    required this.textMuted,
    required this.borderColor,
    required this.onTap,
  });

  final NotificationItemModel item;
  final bool isDark;
  final Color surface2;
  final Color textColor;
  final Color textMuted;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(item.createdAt);

    IconData typeIcon = Icons.notifications_rounded;
    Color iconColor = AppColors.orange;
    if (item.notificationType.contains('approved')) {
      typeIcon = Icons.check_circle_rounded;
      iconColor = AppColors.success;
    } else if (item.notificationType.contains('rejected') || item.notificationType.contains('cancelled')) {
      typeIcon = Icons.cancel_rounded;
      iconColor = AppColors.error;
    } else if (item.notificationType.contains('welcome')) {
      typeIcon = Icons.waving_hand_rounded;
      iconColor = AppColors.warning;
    }

    return Dismissible(
      key: Key('notif-${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.orange.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.mark_email_read_rounded, color: AppColors.orange),
      ),
      onDismissed: (_) => onTap(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.isRead ? surface2 : AppColors.orange.withValues(alpha: isDark ? 0.08 : 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isRead ? borderColor : AppColors.orange.withValues(alpha: 0.3),
              width: item.isRead ? 1.0 : 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon or Vehicle Thumbnail Image
                  item.vehicleImage != null && item.vehicleImage!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: CachedNetworkImage(
                              imageUrl: item.vehicleImage!,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Icon(typeIcon, color: iconColor, size: 24),
                            ),
                          ),
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(typeIcon, color: iconColor, size: 20),
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                                ),
                              ),
                            ),
                            if (!item.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(left: 6),
                                decoration: const BoxDecoration(
                                  color: AppColors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.message,
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              timeStr,
                              style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w500),
                            ),
                            if (item.bookingReference != null)
                              Text(
                                item.bookingReference!,
                                style: const TextStyle(
                                  color: AppColors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
