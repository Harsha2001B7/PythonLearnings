import '../models/trailer.dart';

abstract class ITrailerRepository {
  /// Fetches a list of trailers for a specific section based on the query.
  Future<List<Trailer>> fetchSection(
    String sectionTitle,
    String query,
    List<String> genres,
    String language,
  );
}
