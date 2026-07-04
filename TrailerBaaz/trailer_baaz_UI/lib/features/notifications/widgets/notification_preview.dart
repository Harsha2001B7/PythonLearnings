import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../../core/models/trailer.dart';
import '../../../shared/widgets/cinematic_image.dart';
import '../models/rich_notification_content.dart';

class NotificationPreview extends StatelessWidget {
  const NotificationPreview({
    super.key,
    required this.trailer,
    required this.content,
  });

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
                CinematicImage(
                  url: trailer.youtubeThumbnailUrl,
                  fallbackUrl: trailer.youtubeHqThumbnailUrl,
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
