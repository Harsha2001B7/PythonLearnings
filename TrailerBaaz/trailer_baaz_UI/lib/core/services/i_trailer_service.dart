abstract class ITrailerService {
  /// Search for trailers matching [query].
  /// Returns a list of search result items (raw JSON maps).
  Future<List<Map<String, dynamic>>> searchTrailers(
    String query, {
    int maxResults = 5,
  });

  /// Fetch video statistics + content details for a list of video IDs.
  /// Returns a map of {videoId → videoDetails}.
  Future<Map<String, Map<String, dynamic>>> getVideoDetails(
    List<String> ids,
  );
}
