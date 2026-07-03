import 'package:flutter/foundation.dart';
import '../models/trailer.dart';
import '../repositories/i_trailer_repository.dart';

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
  YoutubeTrailersProvider(this._repository);

  bool isLoading = true;
  String? error;
  Map<String, List<Trailer>> sections = {};
  List<Trailer> heroTrailers = [];

  List<Trailer> get allTrailers {
    final Map<String, Trailer> unique = {};
    for (final t in heroTrailers) {
      unique[t.id] = t;
    }
    for (final list in sections.values) {
      for (final t in list) {
        unique[t.id] = t;
      }
    }
    return unique.values.toList();
  }

  final ITrailerRepository _repository;

  /// Call once at app startup.
  Future<void> init() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Fire all section searches in parallel
      final futures = _sectionConfig.map(
        (cfg) => _repository.fetchSection(cfg.$1, cfg.$2, cfg.$3, cfg.$4),
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


}
