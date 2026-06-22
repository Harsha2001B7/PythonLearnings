import 'package:flutter/material.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Assistant',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Your intelligent productivity companion',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Ask anything about your tasks',
                            style: theme.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Summaries, priorities, and insights will appear here once connected to the backend.',
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _SuggestionChip(label: 'Summarize my week'),
                              _SuggestionChip(label: 'What should I focus on?'),
                              _SuggestionChip(label: 'Review pending tasks'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Ask AI Task Hub...',
                  prefixIcon: const Icon(Icons.auto_awesome_outlined),
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.send_rounded),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;

  const _SuggestionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActionChip(
      label: Text(label),
      labelStyle: theme.textTheme.bodySmall,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      side: BorderSide(color: theme.colorScheme.outline),
      onPressed: () {},
    );
  }
}
