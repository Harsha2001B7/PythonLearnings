import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../services/local_notification_service.dart';
import '../controllers/notification_controller.dart';
import '../../app/app_theme.dart';

class NotificationSimulatorScreen extends StatefulWidget {
  const NotificationSimulatorScreen({super.key});

  @override
  State<NotificationSimulatorScreen> createState() => _NotificationSimulatorScreenState();
}

class _NotificationSimulatorScreenState extends State<NotificationSimulatorScreen> {
  NotificationType _selectedType = NotificationType.trailerReleased;
  String _selectedMovie = 'War 2';
  int _delaySeconds = 0;

  final List<String> _movies = ['War 2', 'KGF Chapter 3', 'Animal', 'Mirzapur'];

  void _sendNotification() {
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    String title = '';
    String body = '';
    Map<String, dynamic> payload = {};

    switch (_selectedType) {
      case NotificationType.trailerReleased:
        title = '🔥 New Trailer Released';
        body = '$_selectedMovie Official Trailer is now streaming.';
        payload = {'trailerId': _selectedMovie == 'War 2' ? '2' : '1'};
        break;
      case NotificationType.comingSoon:
        title = '🎬 Coming Soon';
        body = '$_selectedMovie teaser announced. Stay tuned!';
        break;
      case NotificationType.recommendation:
        title = '⭐ Recommended for You';
        body = 'Because you enjoyed watching $_selectedMovie.';
        break;
      case NotificationType.trending:
        title = '📈 Trending Now';
        body = '$_selectedMovie has crossed 75M views!';
        break;
      case NotificationType.watchReminder:
        title = '⏰ Watch Reminder';
        body = 'Don\'t forget to watch the trailer of $_selectedMovie today.';
        break;
      case NotificationType.system:
        title = '🎉 System Update';
        body = 'Welcome to the premium TrailerBaaz update!';
        break;
    }

    LocalNotificationService.instance.show(
      id: id,
      title: title,
      body: body,
      type: _selectedType,
      payload: payload,
      delay: Duration(seconds: _delaySeconds),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _delaySeconds > 0
              ? 'Notification scheduled in $_delaySeconds seconds.'
              : 'Notification sent instantly.',
        ),
        backgroundColor: AppTheme.accent,
      ),
    );
  }

  void _sendRandomNotification() {
    final types = NotificationType.values;
    final randomType = (types..shuffle()).first;
    final randomMovie = (_movies..shuffle()).first;
    
    setState(() {
      _selectedType = randomType;
      _selectedMovie = randomMovie;
    });

    _sendNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Developer Simulator'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Simulate Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Trigger local push notifications to test badge state, background delivery, and deep links.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
            ),
            const SizedBox(height: 24),
            
            // Notification Type Dropdown
            const Text('Notification Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<NotificationType>(
                  value: _selectedType,
                  dropdownColor: AppTheme.card,
                  isExpanded: true,
                  items: NotificationType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Movie/Trailer Dropdown
            const Text('Select Movie', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMovie,
                  dropdownColor: AppTheme.card,
                  isExpanded: true,
                  items: _movies.map((movie) {
                    return DropdownMenuItem(
                      value: movie,
                      child: Text(movie),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedMovie = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Delay Radios
            const Text('Delay duration', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _delayRadio(0, 'Instant'),
                _delayRadio(5, '5s'),
                _delayRadio(10, '10s'),
                _delayRadio(30, '30s'),
              ],
            ),
            const SizedBox(height: 32),

            // Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _sendNotification,
                child: const Text('Send Notification', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _sendRandomNotification,
                    child: const Text('Random Notification', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      NotificationController.instance.clearAll();
                      LocalNotificationService.instance.cancelAll();
                    },
                    child: const Text('Clear All', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _delayRadio(int val, String label) {
    return Row(
      children: [
        Radio<int>(
          value: val,
          groupValue: _delaySeconds,
          activeColor: AppTheme.accent,
          onChanged: (v) {
            if (v != null) setState(() => _delaySeconds = v);
          },
        ),
        Text(label),
        const SizedBox(width: 8),
      ],
    );
  }
}
