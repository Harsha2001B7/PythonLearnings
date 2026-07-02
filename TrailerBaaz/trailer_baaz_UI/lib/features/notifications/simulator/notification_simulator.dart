import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../../core/data/youtube_trailers_provider.dart';
import '../../../core/models/trailer.dart';
import '../controllers/notification_controller.dart';
import '../models/rich_notification_content.dart';
import '../services/local_notification_service.dart';

class NotificationSimulatorScreen extends StatefulWidget {
  const NotificationSimulatorScreen({super.key});

  @override
  State<NotificationSimulatorScreen> createState() =>
      _NotificationSimulatorScreenState();
}

class _NotificationSimulatorScreenState
    extends State<NotificationSimulatorScreen> {
  final _provider = YoutubeTrailersProvider.instance;

  String? _selectedTrailerId;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _provider.addListener(_onTrailersChanged);
    if (_provider.allTrailers.isEmpty && !_provider.isLoading) {
      _provider.init();
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_onTrailersChanged);
    super.dispose();
  }

  void _onTrailersChanged() {
    if (!mounted) return;
    setState(_syncSelectedTrailer);
  }

  List<Trailer> get _trailers => _provider.allTrailers;

  Trailer? get _selectedTrailer {
    final trailers = _trailers;
    if (trailers.isEmpty) return null;
    final selectedId = _selectedTrailerId;
    if (selectedId == null) return trailers.first;
    return trailers.firstWhere(
      (trailer) => trailer.id == selectedId,
      orElse: () => trailers.first,
    );
  }

  void _syncSelectedTrailer() {
    final trailers = _trailers;
    if (trailers.isEmpty) {
      _selectedTrailerId = null;
      return;
    }

    final selectedId = _selectedTrailerId;
    if (selectedId == null ||
        !trailers.any((trailer) => trailer.id == selectedId)) {
      _selectedTrailerId = trailers.first.id;
    }
  }

  Future<void> _sendNotification() async {
    final trailer = _selectedTrailer;
    if (trailer == null || _isSending) return;

    setState(() => _isSending = true);
    try {
      await LocalNotificationService.instance.show(
        RichNotificationContent.forTrailerRelease(trailer),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Instant notification sent.'),
          backgroundColor: AppTheme.accent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncSelectedTrailer();
    final trailer = _selectedTrailer;
    final content = trailer == null
        ? null
        : RichNotificationContent.forTrailerRelease(trailer);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Notification Simulator'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Instant Preview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a real Android local notification using the Firebase-ready trailer template.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62),
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 22),
            _TriggerMode(),
            const SizedBox(height: 18),
            if (trailer == null || content == null)
              _LoadingState(
                isLoading: _provider.isLoading,
                onRetry: _provider.init,
              )
            else ...[
              _TrailerPicker(
                trailers: _trailers,
                selectedTrailerId: trailer.id,
                onChanged: (id) => setState(() => _selectedTrailerId = id),
              ),
              const SizedBox(height: 20),
              _NotificationPreview(trailer: trailer, content: content),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSending ? null : _sendNotification,
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: const Text(
                    'Send Notification',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    NotificationController.instance.clearAll();
                    LocalNotificationService.instance.cancelAll();
                  },
                  icon: const Icon(Icons.delete_sweep_rounded),
                  label: const Text('Clear All'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TriggerMode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: const Row(
        children: [
          Icon(Icons.bolt_rounded, color: AppTheme.hype),
          SizedBox(width: 10),
          Text(
            'Trigger',
            style: TextStyle(color: AppTheme.muted, fontSize: 13),
          ),
          Spacer(),
          Text('Instant', style: TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _TrailerPicker extends StatelessWidget {
  const _TrailerPicker({
    required this.trailers,
    required this.selectedTrailerId,
    required this.onChanged,
  });

  final List<Trailer> trailers;
  final String selectedTrailerId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trailer', style: TextStyle(fontWeight: FontWeight.w800)),
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
              value: selectedTrailerId,
              dropdownColor: AppTheme.card,
              isExpanded: true,
              items: trailers.map((trailer) {
                return DropdownMenuItem(
                  value: trailer.id,
                  child: Text(trailer.title, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationPreview extends StatelessWidget {
  const _NotificationPreview({required this.trailer, required this.content});

  final Trailer trailer;
  final RichNotificationContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  trailer.youtubeThumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Image.network(
                    trailer.youtubeHqThumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Text(
                    trailer.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/TrailerBaaz5.png',
                        width: 34,
                        height: 34,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'TrailerBaaz',
                        style: TextStyle(
                          color: AppTheme.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.notifications_active_rounded,
                      color: AppTheme.hype,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  content.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content.body,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.play_circle_fill_rounded,
                      color: AppTheme.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      content.actionLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.isLoading, required this.onRetry});

  final bool isLoading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          if (isLoading)
            const CircularProgressIndicator(color: AppTheme.accent)
          else
            const Icon(Icons.wifi_off_rounded, color: AppTheme.muted, size: 32),
          const SizedBox(height: 14),
          Text(
            isLoading ? 'Loading trailers...' : 'No trailers available.',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          if (!isLoading) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
