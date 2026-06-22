import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../widgets/summary_card.dart';
class DashboardScreen extends StatelessWidget {
  final VoidCallback onViewTasks;
  final VoidCallback onAiAssistant;
  final VoidCallback onAddTask;

  const DashboardScreen({
    super.key,
    required this.onViewTasks,
    required this.onAiAssistant,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            Text(
              'Good Morning',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              SampleData.userName,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    label: 'Total Tasks',
                    value: '${SampleData.totalTasks}',
                    icon: Icons.task_alt_rounded,
                    iconColor: scheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    label: 'Pending',
                    value: '${SampleData.pendingTasks}',
                    icon: Icons.pending_actions_rounded,
                    iconColor: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SummaryCard(
              label: 'Completed Tasks',
              value: '${SampleData.completedTasks}',
              icon: Icons.check_circle_outline_rounded,
              iconColor: const Color(0xFF10B981),
            ),
            const SizedBox(height: 32),
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.checklist_rounded,
              title: 'View Tasks',
              subtitle: 'Browse your full task list',
              onTap: onViewTasks,
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.auto_awesome_rounded,
              title: 'AI Assistant',
              subtitle: 'Get smart summaries and insights',
              onTap: onAiAssistant,
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.add_circle_outline_rounded,
              title: 'Add Task',
              subtitle: 'Create a new task quickly',
              onTap: onAddTask,
            ),
            const SizedBox(height: 32),
            Text(
              'Recent Activity',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < SampleData.recentActivity.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    _ActivityItem(activity: SampleData.recentActivity[i]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Map<String, String> activity;

  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    children: [
                      TextSpan(
                        text: activity['title'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: ' ${activity['action']}'),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['time']!,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
