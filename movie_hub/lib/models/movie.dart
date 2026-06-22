class Movie {
  final int id;

  final String title;

  final double rating;
  final String posterPath;
  const Movie({
    required this.id,

    required this.title,

    required this.rating,

    required this.posterPath,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],

      title: json['title'],

      rating: json['vote_average'].toDouble(),

      posterPath: json['poster_path'] ?? '',
    );
  }
}
