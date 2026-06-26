import 'package:flutter/foundation.dart';
import '../models/trailer.dart';
import '../services/youtube_service.dart';

/// Dummy cast used as fallback (YouTube API doesn't return cast).
const _fallbackCast = [
  CastMember(
    name: 'Ryan G.',
    role: 'Lead',
    imageUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
  ),
  CastMember(
    name: 'Ana D.',
    role: 'Supporting',
    imageUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
  ),
  CastMember(
    name: 'Leo K.',
    role: 'Villain',
    imageUrl:
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=300&q=80',
  ),
  CastMember(
    name: 'Maya R.',
    role: 'Ally',
    imageUrl:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
  ),
];

/// Section query config: section title → (search query, genres, language)
const _sectionConfig = [
  (
    'Trending Now',
    'best movie trailer 2025',
    ['Action', 'Drama'],
    'English',
  ),
  (
    'Most Awaited',
    'most anticipated movie trailer 2025',
    ['Adventure', 'Sci-Fi'],
    'English',
  ),
  (
    'Coming Soon',
    'coming soon movie trailer 2025',
    ['Thriller', 'Drama'],
    'English',
  ),
  (
    'Hollywood',
    'Hollywood blockbuster trailer 2025',
    ['Hollywood', 'Action'],
    'English',
  ),
  (
    'Bollywood',
    'Bollywood movie trailer 2025',
    ['Bollywood', 'Drama'],
    'Hindi',
  ),
  (
    'Telugu',
    'Telugu movie trailer 2025',
    ['Telugu', 'Action'],
    'Telugu',
  ),
  (
    'Tamil',
    'Tamil movie trailer 2025',
    ['Tamil', 'Thriller'],
    'Tamil',
  ),
  (
    'Korean',
    'Korean movie trailer 2025',
    ['Korean', 'Drama'],
    'Korean',
  ),
  (
    'OTT Originals',
    'Netflix Amazon Prime OTT original trailer 2025',
    ['OTT', 'Drama'],
    'English',
  ),
];

class YoutubeTrailersProvider extends ChangeNotifier {
  YoutubeTrailersProvider._();
  static final YoutubeTrailersProvider instance = YoutubeTrailersProvider._();

  bool isLoading = true;
  String? error;
  Map<String, List<Trailer>> sections = {};
  List<Trailer> heroTrailers = [];

  final _service = YouTubeService.instance;

  /// Call once at app startup.
  Future<void> init() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Fire all section searches in parallel
      final futures = _sectionConfig.map(
        (cfg) => _fetchSection(cfg.$1, cfg.$2, cfg.$3, cfg.$4),
      );
      final results = await Future.wait(futures);

      final Map<String, List<Trailer>> built = {};
      for (var i = 0; i < _sectionConfig.length; i++) {
        if (results[i].isNotEmpty) {
          built[_sectionConfig[i].$1] = results[i];
        }
      }

      sections = built;
      // Hero carousel uses Trending Now, falling back to first available
      heroTrailers = built['Trending Now'] ??
          built.values.firstOrNull ??
          [];
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<List<Trailer>> _fetchSection(
    String sectionTitle,
    String query,
    List<String> genres,
    String language,
  ) async {
    final searchItems = await _service.searchTrailers(query, maxResults: 6);
    if (searchItems.isEmpty) return [];

    final videoIds = searchItems
        .map((item) => (item['id'] as Map?)?['videoId'] as String?)
        .whereType<String>()
        .toList();

    final detailsMap = await _service.getVideoDetails(videoIds);

    return searchItems
        .map((item) {
          final videoId =
              (item['id'] as Map?)?['videoId'] as String?;
          if (videoId == null || videoId.isEmpty) return null;
          return Trailer.fromYouTube(
            searchItem: item,
            videoDetails: detailsMap[videoId],
            genres: genres,
            language: language,
            cast: _fallbackCast,
          );
        })
        .whereType<Trailer>()
        .toList();
  }
}
