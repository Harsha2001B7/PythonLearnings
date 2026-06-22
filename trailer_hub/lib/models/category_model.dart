/// Category Model
/// Represents a trailer category/genre
library;

class CategoryModel {
  final String id;
  final String name;
  final String iconUrl;
  final String description;
  final int trailerCount;
  final DateTime createdDate;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.description,
    required this.trailerCount,
    required this.createdDate,
  });

  /// Factory constructor to create CategoryModel from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      iconUrl: json['iconUrl'] ?? '',
      description: json['description'] ?? '',
      trailerCount: json['trailerCount'] ?? 0,
      createdDate: DateTime.tryParse(json['createdDate'] ?? '') ?? DateTime.now(),
    );
  }

  /// Convert CategoryModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconUrl': iconUrl,
      'description': description,
      'trailerCount': trailerCount,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  /// Create a copy of CategoryModel with optional field changes
  CategoryModel copyWith({
    String? id,
    String? name,
    String? iconUrl,
    String? description,
    int? trailerCount,
    DateTime? createdDate,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      description: description ?? this.description,
      trailerCount: trailerCount ?? this.trailerCount,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CategoryModel(id: $id, name: $name)';
}
