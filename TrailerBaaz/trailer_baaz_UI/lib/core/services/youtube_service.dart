import 'dart:convert';
import 'package:http/http.dart' as http;

/// Lightweight wrapper around the YouTube Data API v3.
class YouTubeService {
  YouTubeService._();
  static final YouTubeService instance = YouTubeService._();

  static const _apiKey = 'AIzaSyCdEO48zEmJRLz_g_ONfho2tcGCtjKuSDk';
  static const _baseUrl = 'https://www.googleapis.com/youtube/v3';

  final _client = http.Client();

  /// Search for trailers matching [query].
  /// Returns a list of search result items (raw JSON maps).
  Future<List<Map<String, dynamic>>> searchTrailers(
    String query, {
    int maxResults = 5,
  }) async {
    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
      'part': 'snippet',
      'q': '$query official trailer',
      'type': 'video',
      'videoCategoryId': '1', // Film & Animation
      'order': 'relevance',
      'maxResults': '$maxResults',
      'key': _apiKey,
    });

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) return [];
      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List? ?? [];
      return items.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Fetch video statistics + content details for a list of video IDs.
  /// Returns a map of {videoId → videoDetails}.
  Future<Map<String, Map<String, dynamic>>> getVideoDetails(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return {};
    final uri = Uri.parse('$_baseUrl/videos').replace(queryParameters: {
      'part': 'snippet,statistics,contentDetails',
      'id': ids.join(','),
      'key': _apiKey,
    });

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) return {};
      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List? ?? [];
      return {
        for (final item in items.cast<Map<String, dynamic>>())
          item['id'] as String: item,
      };
    } catch (_) {
      return {};
    }
  }
}
