/// Trailer Model
/// Represents a single trailer with all its information
library;

class TrailerModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String thumbnailUrl;
  final String? videoUrl;
  final String category;
  final DateTime releaseDate;
  final double rating;
  final int views;
  final List<String> genres;
  final String language;
  final int durationInSeconds;
  final String productionHouse;
  final bool isWatched;
  final DateTime addedDate;

  TrailerModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.thumbnailUrl,
    this.videoUrl,
    required this.category,
    required this.releaseDate,
    required this.rating,
    required this.views,
    required this.genres,
    required this.language,
    required this.durationInSeconds,
    required this.productionHouse,
    this.isWatched = false,
    required this.addedDate,
  });

  /// Factory constructor to create TrailerModel from JSON
  factory TrailerModel.fromJson(Map<String, dynamic> json) {
    return TrailerModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? json['posterUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? json['imageUrl'] ?? '',
      videoUrl: json['videoUrl'],
      category: json['category'] ?? 'General',
      releaseDate: DateTime.tryParse(json['releaseDate'] ?? '') ?? DateTime.now(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      views: json['views'] ?? 0,
      genres: List<String>.from(json['genres'] ?? []),
      language: json['language'] ?? 'English',
      durationInSeconds: json['durationInSeconds'] ?? 0,
      productionHouse: json['productionHouse'] ?? 'Unknown',
      isWatched: json['isWatched'] ?? false,
      addedDate: DateTime.tryParse(json['addedDate'] ?? '') ?? DateTime.now(),
    );
  }

  /// Convert TrailerModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'category': category,
      'releaseDate': releaseDate.toIso8601String(),
      'rating': rating,
      'views': views,
      'genres': genres,
      'language': language,
      'durationInSeconds': durationInSeconds,
      'productionHouse': productionHouse,
      'isWatched': isWatched,
      'addedDate': addedDate.toIso8601String(),
    };
  }

  /// Create a copy of TrailerModel with optional field changes
  TrailerModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? thumbnailUrl,
    String? videoUrl,
    String? category,
    DateTime? releaseDate,
    double? rating,
    int? views,
    List<String>? genres,
    String? language,
    int? durationInSeconds,
    String? productionHouse,
    bool? isWatched,
    DateTime? addedDate,
  }) {
    return TrailerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      category: category ?? this.category,
      releaseDate: releaseDate ?? this.releaseDate,
      rating: rating ?? this.rating,
      views: views ?? this.views,
      genres: genres ?? this.genres,
      language: language ?? this.language,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      productionHouse: productionHouse ?? this.productionHouse,
      isWatched: isWatched ?? this.isWatched,
      addedDate: addedDate ?? this.addedDate,
    );
  }

  /// Get duration in minutes
  int get durationInMinutes => durationInSeconds ~/ 60;

  /// Format duration as mm:ss
  String get formattedDuration {
    final minutes = durationInSeconds ~/ 60;
    final seconds = durationInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format views count (e.g., 1.2M, 500K)
  String get formattedViews {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    } else {
      return views.toString();
    }
  }

  /// Format rating with star emoji
  String get ratingDisplay => '⭐ $rating';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrailerModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
