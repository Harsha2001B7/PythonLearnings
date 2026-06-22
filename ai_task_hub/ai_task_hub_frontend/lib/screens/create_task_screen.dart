import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'Medium';

  static const _priorities = ['Low', 'Medium', 'High'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Task',
                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 6),
              Text(
                'Add details to organize your work.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 28),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: _titleController,
                        label: 'Title',
                        hint: 'Enter task title',
                        prefixIcon: Icons.title_rounded,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'What needs to be done?',
                        prefixIcon: Icons.notes_rounded,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Priority',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      InputDecorator(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.flag_outlined),
                          labelText: 'Priority',
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _priority,
                            isExpanded: true,
                            items: _priorities
                                .map(
                                  (priority) => DropdownMenuItem(
                                    value: priority,
                                    child: Text(priority),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _priority = value);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Save Task',
                icon: Icons.check_rounded,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
