class Trailer {
  const Trailer({
    required this.id,
    required this.youtubeVideoId,
    required this.title,
    required this.tagline,
    required this.synopsis,
    required this.backdropUrl,
    required this.posterUrl,
    required this.genres,
    required this.language,
    required this.certificate,
    required this.runtime,
    required this.releaseDate,
    required this.releaseCountdown,
    required this.hypeScore,
    required this.views,
    required this.studio,
    required this.director,
    required this.cast,
  });

  final String id;
  final String youtubeVideoId; // YouTube video ID for playback & thumbnail
  final String title;
  final String tagline;
  final String synopsis;
  final String backdropUrl;
  final String posterUrl;
  final List<String> genres;
  final String language;
  final String certificate;
  final String runtime;
  final String releaseDate;
  final String releaseCountdown;
  final int hypeScore;
  final String views;
  final String studio;
  final String director;
  final List<CastMember> cast;

  /// YouTube maxres thumbnail as backdrop
  String get youtubeThumbnailUrl =>
      'https://img.youtube.com/vi/$youtubeVideoId/maxresdefault.jpg';

  /// YouTube hq thumbnail as poster (fallback)
  String get youtubeHqThumbnailUrl =>
      'https://img.youtube.com/vi/$youtubeVideoId/hqdefault.jpg';

  /// Factory to build a Trailer from a YouTube API search+video response
  factory Trailer.fromYouTube({
    required Map<String, dynamic> searchItem,
    required Map<String, dynamic>? videoDetails,
    required List<String> genres,
    required String language,
    required List<CastMember> cast,
  }) {
    final videoId = (searchItem['id'] as Map?)?['videoId'] as String? ?? '';
    final snippet = searchItem['snippet'] as Map<String, dynamic>? ?? {};
    final stats = videoDetails?['statistics'] as Map<String, dynamic>? ?? {};
    final contentDetails =
        videoDetails?['contentDetails'] as Map<String, dynamic>? ?? {};

    final title = snippet['title'] as String? ?? 'Unknown';
    final channelTitle = snippet['channelTitle'] as String? ?? 'Unknown';
    final description = snippet['description'] as String? ?? '';
    final publishedAt = snippet['publishedAt'] as String? ?? '';

    // Parse view count
    final viewCountRaw = int.tryParse(stats['viewCount'] as String? ?? '0') ?? 0;
    final String views;
    if (viewCountRaw >= 1000000) {
      views = '${(viewCountRaw / 1000000).toStringAsFixed(1)}M';
    } else if (viewCountRaw >= 1000) {
      views = '${(viewCountRaw / 1000).toStringAsFixed(0)}K';
    } else {
      views = viewCountRaw.toString();
    }

    // Parse ISO 8601 duration e.g. PT2M30S
    final durationStr = contentDetails['duration'] as String? ?? 'PT0S';
    final runtime = _parseDuration(durationStr);

    // Parse release date
    String releaseDate = '';
    if (publishedAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(publishedAt);
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        releaseDate = '${months[dt.month - 1]} ${dt.day}';
      } catch (_) {}
    }

    final hypeScore = 70 + (videoId.hashCode.abs() % 29);

    return Trailer(
      id: videoId,
      youtubeVideoId: videoId,
      title: title,
      tagline: description.length > 80
          ? '${description.substring(0, 80)}…'
          : description,
      synopsis: description.isEmpty
          ? 'Watch the official trailer on TrailerBaaz.'
          : description,
      backdropUrl: 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
      posterUrl: 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
      genres: genres,
      language: language,
      certificate: 'UA',
      runtime: runtime,
      releaseDate: releaseDate,
      releaseCountdown: 'Now Streaming',
      hypeScore: hypeScore,
      views: views,
      studio: channelTitle,
      director: channelTitle,
      cast: cast,
    );
  }

  static String _parseDuration(String iso) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(iso);
    if (match == null) return '0m';
    final h = int.tryParse(match.group(1) ?? '') ?? 0;
    final m = int.tryParse(match.group(2) ?? '') ?? 0;
    final s = int.tryParse(match.group(3) ?? '') ?? 0;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }
}

class CastMember {
  const CastMember({
    required this.name,
    required this.role,
    required this.imageUrl,
  });

  final String name;
  final String role;
  final String imageUrl;
}
