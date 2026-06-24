import 'package:dio/dio.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../home/data/mock/home_dummy_data.dart';
import '../../domain/models/reel_model.dart';

class ReelsDummyData {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://www.googleapis.com/youtube/v3',
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      responseType: ResponseType.json,
    ),
  );

  static List<ReelModel> reels = <ReelModel>[];

  static Future<void> preload({required String apiKey}) async {
    if (HomeDummyData.trailers.isEmpty) {
      reels = <ReelModel>[];
      return;
    }

    final source = HomeDummyData.trailers.take(8).toList();
    final ids = source
        .map(
          (trailer) =>
              YoutubePlayerController.convertUrlToId(trailer.youtubeUrl),
        )
        .whereType<String>()
        .toList(growable: false);

    if (ids.isEmpty) {
      reels = <ReelModel>[];
      return;
    }

    try {
      final response = await _dio.get(
        '/videos',
        queryParameters: <String, Object?>{
          'part': 'snippet,statistics',
          'id': ids.join(','),
          'key': apiKey,
        },
      );

      final items =
          (response.data['items'] as List<dynamic>? ?? const <dynamic>[]);
      final statsById = <String, Map<String, dynamic>>{};
      for (final raw in items) {
        if (raw is! Map<String, dynamic>) {
          continue;
        }
        final id = raw['id'];
        final statistics = raw['statistics'];
        if (id is String && statistics is Map<String, dynamic>) {
          statsById[id] = statistics;
        }
      }

      reels = source
          .map((trailer) {
            final videoId = YoutubePlayerController.convertUrlToId(
              trailer.youtubeUrl,
            );
            final stats = videoId == null ? null : statsById[videoId];
            final views = _formatViews(stats?['viewCount']?.toString());
            return ReelModel(
              title: trailer.title,
              industry: trailer.industry,
              language: trailer.language,
              views: views,
              videoUrl: trailer.youtubeUrl,
              thumbnailUrl: trailer.imageUrl,
              genre: trailer.genre,
              releaseYear: trailer.releaseYear,
            );
          })
          .toList(growable: false);
    } catch (_) {
      reels = source
          .map((trailer) {
            return ReelModel(
              title: trailer.title,
              industry: trailer.industry,
              language: trailer.language,
              views: '—',
              videoUrl: trailer.youtubeUrl,
              thumbnailUrl: trailer.imageUrl,
              genre: trailer.genre,
              releaseYear: trailer.releaseYear,
            );
          })
          .toList(growable: false);
    }
  }

  static String _formatViews(String? raw) {
    final value = int.tryParse(raw ?? '');
    if (value == null) return '—';
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    }
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }
}
