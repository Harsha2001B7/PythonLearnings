import '../../core/models/trailer.dart';
import 'notification_item.dart';

class RichNotificationContent {
  const RichNotificationContent({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.payload,
    required this.actionLabel,
    this.imageUrls = const [],
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> payload;
  final String actionLabel;
  final List<String> imageUrls;

  factory RichNotificationContent.forTrailerRelease(Trailer trailer) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final displayTitle = _compactTitle(trailer.title);
    final title = '🔥 $displayTitle is Now Streaming';
    const body = 'Watch the official trailer now on TrailerBaaz.';

    return RichNotificationContent(
      id: id,
      title: title,
      body: body,
      type: NotificationType.trailerReleased,
      actionLabel: 'Watch Now',
      imageUrls: _candidateImages(trailer),
      payload: {
        'trailerId': trailer.id,
        'trailerTitle': trailer.title,
        'notification_source': 'local_simulator',
        'notification_cta': 'Watch Now',
      },
    );
  }

  factory RichNotificationContent.fromRemotePayload(Map<String, dynamic> data) {
    final id =
        data['notification_id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final title =
        data['title']?.toString() ??
        data['notification_title']?.toString() ??
        '🔥 New Trailer is Now Streaming';
    final body =
        data['body']?.toString() ??
        data['notification_body']?.toString() ??
        'Watch the official trailer now on TrailerBaaz.';

    final imageUrls = <String?>[
      data['imageUrl']?.toString(),
      data['posterUrl']?.toString(),
      data['thumbnailUrl']?.toString(),
      data['notification_image']?.toString(),
    ].whereType<String>().where((url) => url.trim().isNotEmpty).toList();

    return RichNotificationContent(
      id: id,
      title: title,
      body: body,
      type: NotificationType.trailerReleased,
      actionLabel: data['notification_cta']?.toString() ?? 'Watch Now',
      imageUrls: imageUrls,
      payload: Map<String, dynamic>.from(data),
    );
  }

  Map<String, dynamic> enrichedPayload() {
    return {
      ...payload,
      'notification_id': id,
      'notification_title': title,
      'notification_body': body,
      'notification_type': type.index,
      'notification_cta': actionLabel,
      if (imageUrls.isNotEmpty) 'notification_image': imageUrls.first,
    };
  }

  static List<String> _candidateImages(Trailer trailer) {
    return <String>[
      trailer.backdropUrl,
      trailer.youtubeThumbnailUrl,
      trailer.posterUrl,
      trailer.youtubeHqThumbnailUrl,
    ].where((url) => url.trim().isNotEmpty).toSet().toList();
  }

  static String _compactTitle(String title) {
    final cleaned = title.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length <= 68) return cleaned;
    return '${cleaned.substring(0, 65)}...';
  }
}
