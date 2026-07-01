import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'notification_model.dart';
import 'notification_service.dart';
import 'notification_tile.dart';

/// Shows the premium notification bottom sheet.
///
/// Call this instead of the old `showModalBottomSheet` in `_NotificationBell`.
void showNotificationSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => const _NotificationSheet(),
  );
}

// ── Sheet root ───────────────────────────────────────────────────────────────

class _NotificationSheet extends StatefulWidget {
  const _NotificationSheet();

  @override
  State<_NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<_NotificationSheet> {
  final _service = NotificationService.instance;

  /// Key used to drive AnimatedList insertions/removals.
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  /// Local snapshot mirrored from the service for AnimatedList coordination.
  late List<AppNotification> _items;

  @override
  void initState() {
    super.initState();
    _items = List<AppNotification>.from(_service.notifications);
    _service.notifier.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _service.notifier.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (!mounted) return;
    final fresh = _service.notifications;

    // Find items removed from service and animate them out.
    final removedIds =
        _items.map((e) => e.id).toSet().difference(fresh.map((e) => e.id).toSet());

    for (final id in removedIds) {
      final index = _items.indexWhere((n) => n.id == id);
      if (index == -1) continue;
      final removed = _items[index];
      _items.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildRemovingTile(removed, animation),
        duration: const Duration(milliseconds: 300),
      );
    }

    // Rebuild for read-state changes (badge update, tile restyle).
    setState(() {
      // Sync read state without re-ordering.
      for (int i = 0; i < _items.length; i++) {
        final updated = fresh.firstWhere(
          (n) => n.id == _items[i].id,
          orElse: () => _items[i],
        );
        _items[i] = updated;
      }
    });
  }

  // ── Pull-to-refresh ────────────────────────────────────────────────────────

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final before = _items.length;
    _service.resetToDemo();
    final after = _service.notifications;

    // Re-populate the AnimatedList.
    setState(() => _items = List<AppNotification>.from(after));

    // If items were previously cleared, insert them one by one.
    if (before == 0) {
      for (int i = 0; i < _items.length; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 60));
        _listKey.currentState?.insertItem(i);
      }
    }
  }

  // ── Dismiss (swipe or programmatic) ────────────────────────────────────────

  void _dismissItem(String id) {
    _service.dismiss(id);
    // _onServiceChanged handles the AnimatedList removal.
  }

  // ── Clear all ──────────────────────────────────────────────────────────────

  void _clearAll() {
    // Remove all items in reverse order for a staggered visual effect.
    final ids = _items.map((n) => n.id).toList();
    _service.clearAll(); // clears the service
    for (int i = ids.length - 1; i >= 0; i--) {
      final index = i;
      final removed = _items[index];
      _items.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildRemovingTile(removed, animation),
        duration: const Duration(milliseconds: 260),
      );
    }
    setState(() {});
  }

  // ── Widget builders ────────────────────────────────────────────────────────

  Widget _buildRemovingTile(
    AppNotification notification,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: FadeTransition(
        opacity: animation,
        child: NotificationTile(
          notification: notification,
          onDismissed: () {},
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    final notification = _items[index];
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: FadeTransition(
        opacity: animation,
        child: NotificationTile(
          key: ValueKey(notification.id),
          notification: notification,
          onDismissed: () => _dismissItem(notification.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.70,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.45, 0.70, 0.95],
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF111111).withValues(alpha: 0.96),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(22)),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 0.8,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // ── Drag handle ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),

                  // ── Header ────────────────────────────────────────────
                  _SheetHeader(
                    unreadCount: _service.unreadCount,
                    hasItems: _items.isNotEmpty,
                    onClearAll: _clearAll,
                  ),

                  // ── Divider ───────────────────────────────────────────
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.white.withValues(alpha: 0.07),
                    indent: 16,
                    endIndent: 16,
                  ),

                  // ── List or empty state ────────────────────────────────
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOut,
                      child: _items.isEmpty
                          ? const _EmptyState()
                          : _NotificationList(
                              key: const ValueKey('list'),
                              listKey: _listKey,
                              scrollController: scrollController,
                              buildTile: _buildTile,
                              itemCount: _items.length,
                              onRefresh: _onRefresh,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Sheet header ─────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.unreadCount,
    required this.hasItems,
    required this.onClearAll,
  });

  final int unreadCount;
  final bool hasItems;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(width: 10),

          // Unread count badge
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: unreadCount > 0
                ? Container(
                    key: ValueKey(unreadCount),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '$unreadCount unread',
                      style: TextStyle(
                        color: AppTheme.accent.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey(0)),
          ),

          const Spacer(),

          // Clear all button
          if (hasItems)
            TextButton(
              onPressed: onClearAll,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withValues(alpha: 0.45),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Notification list ─────────────────────────────────────────────────────────

class _NotificationList extends StatelessWidget {
  const _NotificationList({
    super.key,
    required this.listKey,
    required this.scrollController,
    required this.buildTile,
    required this.itemCount,
    required this.onRefresh,
  });

  final GlobalKey<AnimatedListState> listKey;
  final ScrollController scrollController;
  final Widget Function(BuildContext, int, Animation<double>) buildTile;
  final int itemCount;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.accent,
      backgroundColor: const Color(0xFF1E1E1E),
      strokeWidth: 2,
      child: AnimatedList(
        key: listKey,
        controller: scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.only(top: 10, bottom: 32),
        initialItemCount: itemCount,
        itemBuilder: buildTile,
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.45,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bell icon in layered glow container
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.03),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.09),
                    ),
                  ),
                ),
                Icon(
                  Icons.notifications_none_rounded,
                  size: 34,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'You\'re all caught up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'New trailer updates and recommendations\nwill appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
