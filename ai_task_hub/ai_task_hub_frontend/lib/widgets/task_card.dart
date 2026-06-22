import 'package:flutter/material.dart';

import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  Color _priorityColor(BuildContext context) {
    switch (task.priority) {
      case 'High':
        return const Color(0xFFEF4444);
      case 'Low':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  Color _statusColor(BuildContext context) {
    switch (task.status) {
      case 'Completed':
        return const Color(0xFF10B981);
      case 'In Progress':
        return Theme.of(context).colorScheme.primary;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  IconData _statusIcon() {
    switch (task.status) {
      case 'Completed':
        return Icons.check_circle_outline_rounded;
      case 'In Progress':
        return Icons.timelapse_rounded;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = _priorityColor(context);
    final statusColor = _statusColor(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 12),
                _Badge(
                  label: task.priority,
                  color: priorityColor,
                  icon: Icons.flag_outlined,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              task.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(_statusIcon(), size: 16, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  task.status,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  task.updatedAt,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Badge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
