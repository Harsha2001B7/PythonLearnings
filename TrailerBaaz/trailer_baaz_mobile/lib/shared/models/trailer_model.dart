class TrailerModel {
  final String title;
  final String imageUrl;
  final String youtubeUrl;
  final String category;
  final String subtitle;
  final bool isUpcoming;

  const TrailerModel({
    required this.title,
    required this.imageUrl,
    required this.youtubeUrl,
    required this.category,
    required this.subtitle,
    this.isUpcoming = false,
  });
}
