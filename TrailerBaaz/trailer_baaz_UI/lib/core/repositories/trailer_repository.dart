import '../models/trailer.dart';
import '../services/i_trailer_service.dart';
import 'i_trailer_repository.dart';

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

class TrailerRepository implements ITrailerRepository {
  final ITrailerService _service;

  TrailerRepository(this._service);

  @override
  Future<List<Trailer>> fetchSection(
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
          final videoId = (item['id'] as Map?)?['videoId'] as String?;
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
