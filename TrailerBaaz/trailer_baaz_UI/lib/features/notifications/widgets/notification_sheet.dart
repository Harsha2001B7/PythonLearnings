import 'dart:ui';
import 'package:flutter/material.dart';
import '../controllers/notification_controller.dart';
import 'notification_header.dart';
import 'notification_tile.dart';
import 'notification_empty_state.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: const Color(0xFF151515).withValues(alpha: 0.9),
              child: ValueListenableBuilder<List>(
                valueListenable: NotificationController.instance.notifications,
                builder: (context, list, _) {
                  final unreadCount = NotificationController.instance.unreadCount;

                  return RefreshIndicator(
                    onRefresh: () async {
                      NotificationController.instance.loadDemoNotifications();
                    },
                    child: Column(
                      children: [
                        // Drag Indicator
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // Header
                        NotificationHeader(
                          unreadCount: unreadCount,
                          onClearAll: () {
                            NotificationController.instance.clearAll();
                          },
                        ),
                        const Divider(height: 1, color: Colors.white10),
                        // List
                        Expanded(
                          child: list.isEmpty
                              ? const NotificationEmptyState()
                              : ListView.builder(
                                  controller: scrollController,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: list.length,
                                  itemBuilder: (context, index) {
                                    return NotificationTile(
                                      key: ValueKey(list[index].id),
                                      item: list[index],
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
