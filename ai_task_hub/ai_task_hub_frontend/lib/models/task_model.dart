class TaskModel {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final String updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.updatedAt,
  });
}

class SampleData {
  static const String userName = 'Alex Morgan';

  static const int totalTasks = 12;
  static const int pendingTasks = 5;
  static const int completedTasks = 7;

  static const List<TaskModel> tasks = [
    TaskModel(
      id: '1',
      title: 'Review Q2 product roadmap',
      description: 'Align priorities with the engineering and design teams.',
      priority: 'High',
      status: 'In Progress',
      updatedAt: '2 hours ago',
    ),
    TaskModel(
      id: '2',
      title: 'Update onboarding documentation',
      description: 'Refresh screenshots and workflow steps for new users.',
      priority: 'Medium',
      status: 'Pending',
      updatedAt: '5 hours ago',
    ),
    TaskModel(
      id: '3',
      title: 'Prepare sprint retrospective',
      description: 'Collect feedback and summarize action items.',
      priority: 'Low',
      status: 'Pending',
      updatedAt: 'Yesterday',
    ),
    TaskModel(
      id: '4',
      title: 'Ship mobile UI polish',
      description: 'Finalize spacing, typography, and navigation patterns.',
      priority: 'High',
      status: 'Completed',
      updatedAt: 'Yesterday',
    ),
    TaskModel(
      id: '5',
      title: 'Sync with marketing team',
      description: 'Review launch timeline and campaign assets.',
      priority: 'Medium',
      status: 'Completed',
      updatedAt: '2 days ago',
    ),
  ];

  static const List<Map<String, String>> recentActivity = [
    {
      'title': 'Ship mobile UI polish',
      'action': 'marked as completed',
      'time': '2 hours ago',
    },
    {
      'title': 'Review Q2 product roadmap',
      'action': 'updated to In Progress',
      'time': '5 hours ago',
    },
    {
      'title': 'Update onboarding documentation',
      'action': 'created',
      'time': 'Yesterday',
    },
  ];
}
