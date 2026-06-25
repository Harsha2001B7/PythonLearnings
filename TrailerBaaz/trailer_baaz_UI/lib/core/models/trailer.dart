class Trailer {
  const Trailer({
    required this.id,
    required this.title,
    required this.tagline,
    required this.synopsis,
    required this.backdropUrl,
    required this.posterUrl,
    required this.genres,
    required this.language,
    required this.certificate,
    required this.runtime,
    required this.releaseDate,
    required this.releaseCountdown,
    required this.hypeScore,
    required this.views,
    required this.studio,
    required this.director,
    required this.cast,
  });

  final String id;
  final String title;
  final String tagline;
  final String synopsis;
  final String backdropUrl;
  final String posterUrl;
  final List<String> genres;
  final String language;
  final String certificate;
  final String runtime;
  final String releaseDate;
  final String releaseCountdown;
  final int hypeScore;
  final String views;
  final String studio;
  final String director;
  final List<CastMember> cast;
}

class CastMember {
  const CastMember({
    required this.name,
    required this.role,
    required this.imageUrl,
  });

  final String name;
  final String role;
  final String imageUrl;
}
