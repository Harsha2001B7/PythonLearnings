import '../../../../core/network/api_endpoints.dart';

/// Mirrors the backend's Brand schema from /api/v1/brands/
class BrandModel {
  const BrandModel({required this.id, required this.name, required this.slug, this.logoUrl});
  final int id;
  final String name;
  final String slug;
  final String? logoUrl;

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    final logo = json['logo_url'] as String?;
    String? fullLogoUrl;
    if (logo != null && logo.isNotEmpty) {
      if (logo.startsWith('http://') || logo.startsWith('https://')) {
        fullLogoUrl = logo;
      } else {
        fullLogoUrl = '${ApiEndpoints.baseUrl}$logo';
      }
    }
    return BrandModel(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? '',
      logoUrl: fullLogoUrl,
    );
  }
}

/// Mirrors the backend's Vehicle schema
class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.name,
    required this.slug,
    this.tagline,
    this.dailyPrice,
    this.badge,
    this.rating = 0.0,
    this.seats,
    this.transmission,
    this.fuel,
    this.images = const [],
    this.brandRel,
    this.categoryRel,
    this.available = true,
    this.featured = false,
  });

  final int id;
  final String name;
  final String slug;
  final String? tagline;
  final double? dailyPrice;
  final String? badge;
  final double rating;
  final int? seats;
  final String? transmission;
  final String? fuel;
  final List<String> images;
  final BrandModel? brandRel;
  final CategoryModel? categoryRel;
  final bool available;
  final bool featured;

  String get primaryImage => images.isNotEmpty ? images.first : '';

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    // Nested images list - prepend baseUrl for relative paths from backend
    final rawImages = json['images'] as List<dynamic>? ?? [];
    final imageUrls = rawImages
        .map((e) {
          final url = (e as Map<String, dynamic>?)?['image_url'] as String? ?? '';
          if (url.isEmpty) return '';
          if (url.startsWith('http://') || url.startsWith('https://')) return url;
          return '${ApiEndpoints.baseUrl}$url';
        })
        .where((u) => u.isNotEmpty)
        .toList();

    // Pricing nested object
    final pricing = json['pricing'] as Map<String, dynamic>?;
    final daily = pricing?['daily'];
    double? dailyPrice;
    if (daily != null) dailyPrice = (daily as num).toDouble();

    // Specs nested
    final specs = json['specifications'] as Map<String, dynamic>?;

    // Brand
    final brandJson = json['brand_rel'] as Map<String, dynamic>?;
    // Category
    final catJson = json['category_rel'] as Map<String, dynamic>?;

    return VehicleModel(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? '',
      tagline: json['tagline'] as String?,
      dailyPrice: dailyPrice,
      badge: json['badge'] as String?,
      rating: ((json['rating'] as num?) ?? 0).toDouble(),
      seats: specs?['seats'] as int?,
      transmission: specs?['transmission'] as String?,
      fuel: specs?['fuel'] as String?,
      images: imageUrls,
      brandRel: brandJson != null ? BrandModel.fromJson(brandJson) : null,
      categoryRel: catJson != null ? CategoryModel.fromJson(catJson) : null,
      available: (json['available'] as bool?) ?? true,
      featured: (json['featured'] as bool?) ?? false,
    );
  }
}

/// Mirrors the backend's Category schema
class CategoryModel {
  const CategoryModel({required this.id, required this.name, required this.slug});
  final int id;
  final String name;
  final String slug;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as int,
        name: (json['name'] as String?) ?? '',
        slug: (json['slug'] as String?) ?? '',
      );
}

/// Mirrors the backend's Offer schema
class OfferModel {
  const OfferModel({
    required this.id,
    required this.title,
    this.description,
    this.discountPercentage,
  });
  final int id;
  final String title;
  final String? description;
  final double? discountPercentage;

  factory OfferModel.fromJson(Map<String, dynamic> json) => OfferModel(
        id: json['id'] as int,
        title: (json['title'] as String?) ?? '',
        description: json['description'] as String?,
        discountPercentage:
            json['discount_percentage'] != null ? (json['discount_percentage'] as num).toDouble() : null,
      );
}

/// Aggregated home data returned by /api/v1/home/
class HomeData {
  const HomeData({
    required this.brands,
    required this.featuredVehicles,
    required this.categories,
    this.offers = const [],
  });

  final List<BrandModel> brands;
  final List<VehicleModel> featuredVehicles;
  final List<CategoryModel> categories;
  final List<OfferModel> offers;
}
