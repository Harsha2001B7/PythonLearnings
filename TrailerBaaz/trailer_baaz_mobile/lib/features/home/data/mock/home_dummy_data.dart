import 'dart:math' as math;

import 'package:dio/dio.dart';

import '../../../../shared/models/trailer_model.dart';

class HomeDummyData {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://www.googleapis.com/youtube/v3',
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      responseType: ResponseType.json,
    ),
  );

  static List<TrailerModel> trailers = <TrailerModel>[];
  static bool _loading = false;
  static DateTime? _loadedAt;

  static const List<_SectionSpec> _sections = [
    _SectionSpec(
      category: 'Trending',
      queries: ['official trailer', 'movie trailer'],
      industry: 'Pan India',
      language: 'Mixed',
      genre: 'Trailer',
      count: 5,
      order: 'viewCount',
      relevanceLanguage: 'en',
    ),
    _SectionSpec(
      category: 'Telugu',
      queries: [
        'Telugu official trailer',
        'Telugu teaser trailer',
        'తెలుగు ట్రైలర్',
      ],
      industry: 'Tollywood',
      language: 'Telugu',
      genre: 'Trailer',
      count: 4,
      order: 'viewCount',
      relevanceLanguage: 'te',
    ),
    _SectionSpec(
      category: 'Hindi',
      queries: ['Hindi official trailer', 'Bollywood trailer'],
      industry: 'Bollywood',
      language: 'Hindi',
      genre: 'Trailer',
      count: 4,
      order: 'viewCount',
      relevanceLanguage: 'hi',
    ),
    _SectionSpec(
      category: 'Web Series',
      queries: ['web series official trailer', 'OTT trailer'],
      industry: 'Streaming',
      language: 'Hindi',
      genre: 'Series',
      count: 4,
      order: 'viewCount',
      relevanceLanguage: 'en',
    ),
    _SectionSpec(
      category: 'Upcoming',
      queries: ['upcoming movie trailer', 'new movie trailer'],
      industry: 'Pan India',
      language: 'Mixed',
      genre: 'Trailer',
      count: 4,
      upcoming: true,
      order: 'date',
      relevanceLanguage: 'en',
    ),
  ];

  static Future<void> preload({required String apiKey}) async {
    if (_loading) return;
    if (trailers.isNotEmpty &&
        _loadedAt != null &&
        DateTime.now().difference(_loadedAt!) < const Duration(minutes: 20)) {
      return;
    }

    _loading = true;
    try {
      final loadedSections = await Future.wait(
        _sections.map((section) => _loadSection(section, apiKey)),
      );

      final seen = <String>{};
      final merged = <TrailerModel>[];
      for (final sectionItems in loadedSections) {
        for (final item in sectionItems) {
          if (seen.add(item.youtubeUrl)) {
            merged.add(item);
          }
        }
      }

      trailers = merged;
      _loadedAt = DateTime.now();
    } finally {
      _loading = false;
    }
  }

  static List<TrailerModel> byCategory(String category) =>
      trailers.where((t) => t.category == category).toList();

  static List<TrailerModel> get featured => trailers.take(5).toList();
  static List<TrailerModel> get upcoming =>
      trailers.where((t) => t.isUpcoming).toList();

  static Future<List<TrailerModel>> _loadSection(
    _SectionSpec section,
    String apiKey,
  ) async {
    try {
      final searchResults = <_SearchHit>[];
      final seenIds = <String>{};
      for (final query in section.queries) {
        final batch = await _searchVideos(
          query: query,
          apiKey: apiKey,
          order: section.order,
          relevanceLanguage: section.relevanceLanguage,
        );
        for (final item in batch) {
          if (seenIds.add(item.videoId)) {
            searchResults.add(item);
          }
          if (searchResults.length >= section.count * 3) {
            break;
          }
        }
        if (searchResults.length >= section.count * 3) {
          break;
        }
      }
      if (searchResults.isEmpty) return const <TrailerModel>[];

      final ids = searchResults.map((item) => item.videoId).toList();
      final details = await _fetchVideoDetails(ids, apiKey);
      final byId = {for (final item in details) item.videoId: item};

      final items = <TrailerModel>[];
      for (final candidate in searchResults) {
        final detail = byId[candidate.videoId];
        if (detail == null || !detail.embeddable) continue;
        items.add(_toTrailer(detail, section));
        if (items.length >= section.count) break;
      }
      return items;
    } catch (_) {
      return const <TrailerModel>[];
    }
  }

  static Future<List<_SearchHit>> _searchVideos({
    required String query,
    required String apiKey,
    required String order,
    required String relevanceLanguage,
  }) async {
    final response = await _dio.get(
      '/search',
      queryParameters: <String, Object?>{
        'part': 'snippet',
        'type': 'video',
        'q': query,
        'maxResults': 12,
        'order': order,
        'regionCode': 'IN',
        'relevanceLanguage': relevanceLanguage,
        'safeSearch': 'none',
        'videoEmbeddable': 'true',
        'videoSyndicated': 'true',
        'key': apiKey,
      },
    );

    final items =
        (response.data['items'] as List<dynamic>? ?? const <dynamic>[]);
    final seenIds = <String>{};
    final hits = <_SearchHit>[];

    for (final raw in items) {
      if (raw is! Map<String, dynamic>) {
        continue;
      }
      final id = raw['id'];
      final snippet = raw['snippet'];
      if (id is! Map<String, dynamic> || snippet is! Map<String, dynamic>) {
        continue;
      }
      final videoId = id['videoId'];
      final title = snippet['title'];
      final description = snippet['description'];
      if (videoId is! String || title is! String || description is! String) {
        continue;
      }
      if (videoId.isEmpty || !seenIds.add(videoId)) {
        continue;
      }
      hits.add(
        _SearchHit(videoId: videoId, title: title, description: description),
      );
    }

    return hits.where(_looksLikeTrailer).toList(growable: false);
  }

  static Future<List<_VideoDetail>> _fetchVideoDetails(
    List<String> ids,
    String apiKey,
  ) async {
    if (ids.isEmpty) return const <_VideoDetail>[];

    final response = await _dio.get(
      '/videos',
      queryParameters: <String, Object?>{
        'part': 'snippet,contentDetails,status',
        'id': ids.join(','),
        'key': apiKey,
      },
    );

    final items =
        (response.data['items'] as List<dynamic>? ?? const <dynamic>[]);
    final details = <_VideoDetail>[];
    for (final raw in items) {
      if (raw is! Map<String, dynamic>) continue;
      final id = raw['id'];
      final snippet = raw['snippet'];
      final contentDetails = raw['contentDetails'];
      final status = raw['status'];
      if (id is! String ||
          snippet is! Map<String, dynamic> ||
          contentDetails is! Map<String, dynamic> ||
          status is! Map<String, dynamic>) {
        continue;
      }
      final embeddable = status['embeddable'] == true;
      if (!embeddable) continue;
      details.add(
        _VideoDetail(
          videoId: id,
          title: snippet['title'] as String? ?? '',
          description: snippet['description'] as String? ?? '',
          publishedAt:
              DateTime.tryParse(snippet['publishedAt'] as String? ?? '') ??
              DateTime.now(),
          thumbnailUrl: _bestThumbnail(snippet['thumbnails']),
          duration: _formatDuration(
            contentDetails['duration'] as String? ?? 'PT0S',
          ),
          embeddable: embeddable,
        ),
      );
    }

    return details;
  }

  static TrailerModel _toTrailer(_VideoDetail detail, _SectionSpec section) {
    final youtubeUrl = 'https://www.youtube.com/watch?v=${detail.videoId}';
    final overview = _truncate(detail.description);
    final releaseYear = detail.publishedAt.year.toString();

    return TrailerModel(
      title: detail.title,
      imageUrl: detail.thumbnailUrl,
      youtubeUrl: youtubeUrl,
      videoUrl: youtubeUrl,
      category: section.category,
      industry: section.industry,
      language: section.language,
      genre: section.genre,
      releaseYear: releaseYear,
      runtime: detail.duration,
      rating: section.upcoming ? 'TBA' : 'NR',
      overview: overview,
      castMembers: const <String>[],
      isUpcoming: section.upcoming,
    );
  }

  static bool _looksLikeTrailer(_SearchHit item) {
    final text = '${item.title} ${item.description}'.toLowerCase();
    return text.contains('trailer') ||
        text.contains('teaser') ||
        text.contains('promo') ||
        text.contains('official');
  }

  static String _bestThumbnail(Object? thumbnails) {
    if (thumbnails is Map<String, dynamic>) {
      final order = <String>['maxres', 'standard', 'high', 'medium', 'default'];
      for (final quality in order) {
        final candidate = thumbnails[quality];
        if (candidate is Map<String, dynamic>) {
          final url = candidate['url'];
          if (url is String && url.isNotEmpty) {
            return url;
          }
        }
      }
    }
    return 'https://img.youtube.com/vi/invalid/maxresdefault.jpg';
  }

  static String _truncate(String input, {int max = 180}) {
    final cleaned = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return 'Official trailer from YouTube.';
    if (cleaned.length <= max) return cleaned;
    return '${cleaned.substring(0, math.max(0, max - 1)).trimRight()}…';
  }

  static String _formatDuration(String iso8601) {
    final hours = _matchIso(iso8601, 'H');
    final minutes = _matchIso(iso8601, 'M');
    final seconds = _matchIso(iso8601, 'S');
    final parts = <String>[];
    if (hours > 0) {
      parts.add('${hours}h');
    }
    if (minutes > 0 || hours > 0) {
      parts.add('${minutes}m');
    }
    if (hours == 0 && minutes == 0 && seconds > 0) {
      parts.add('${seconds}s');
    }
    return parts.isEmpty ? '0s' : parts.join(' ');
  }

  static int _matchIso(String value, String unit) {
    final match = RegExp(r'(\d+)' + unit).firstMatch(value);
    return int.tryParse(match?.group(1) ?? '0') ?? 0;
  }
}

class _SectionSpec {
  final String category;
  final List<String> queries;
  final String industry;
  final String language;
  final String genre;
  final int count;
  final bool upcoming;
  final String order;
  final String relevanceLanguage;

  const _SectionSpec({
    required this.category,
    required this.queries,
    required this.industry,
    required this.language,
    required this.genre,
    required this.count,
    required this.order,
    required this.relevanceLanguage,
    this.upcoming = false,
  });
}

class _SearchHit {
  final String videoId;
  final String title;
  final String description;

  const _SearchHit({
    required this.videoId,
    required this.title,
    required this.description,
  });
}

class _VideoDetail {
  final String videoId;
  final String title;
  final String description;
  final DateTime publishedAt;
  final String thumbnailUrl;
  final String duration;
  final bool embeddable;

  const _VideoDetail({
    required this.videoId,
    required this.title,
    required this.description,
    required this.publishedAt,
    required this.thumbnailUrl,
    required this.duration,
    required this.embeddable,
  });
}
