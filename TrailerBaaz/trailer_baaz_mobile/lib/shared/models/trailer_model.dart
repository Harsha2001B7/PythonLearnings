class TrailerModel {
  final String title;
  final String imageUrl;
  final String youtubeUrl;
  final String videoUrl;
  final String category;
  final String language;
  final String genre;
  final bool isUpcoming;

  const TrailerModel({
    required this.title,
    required this.imageUrl,
    required this.youtubeUrl,
    required this.videoUrl,
    required this.category,
    required this.language,
    required this.genre,
    this.isUpcoming = false,
  });

  String get subtitle => '$language • $genre';
}
