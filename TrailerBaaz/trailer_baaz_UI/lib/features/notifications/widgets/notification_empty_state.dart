import 'package:flutter/material.dart';

import '../../../shared/ui/empty/empty_state.dart';

/// Empty state shown in the notifications sheet when there are no items.
///
/// Delegates to [EmptyState] so the layout is consistent with other
/// empty states in the app. Public API is unchanged.
class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.notifications_off_outlined,
      title: "You're all caught up",
      subtitle:
          "We'll notify you when new trailers match your interests.",
    );
  }
}
