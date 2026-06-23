class TrailerModel {
  final String title;
  final String imageUrl;
  final String youtubeUrl;
  final String videoUrl;
  final String category;
  final String industry;
  final String language;
  final String genre;
  final String releaseYear;
  final String runtime;
  final String rating;
  final String overview;
  final List<String> castMembers;
  final bool isUpcoming;

  const TrailerModel({
    required this.title,
    required this.imageUrl,
    required this.youtubeUrl,
    required this.videoUrl,
    required this.category,
    required this.industry,
    required this.language,
    required this.genre,
    required this.releaseYear,
    required this.runtime,
    required this.rating,
    required this.overview,
    required this.castMembers,
    this.isUpcoming = false,
  });

  String get subtitle => '$language • $genre';
}
