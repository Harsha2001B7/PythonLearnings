import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/home_models.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.read(dioProvider));
});

/// Fetches all home screen data.
/// - /api/v1/home/ provides: featured_vehicles, categories, brands
/// - /api/v1/offers/ provides promo banners [available endpoint]
/// 
/// ⚠ PENDING: Recent bookings endpoint `/api/v1/bookings/my` is available
///   but not wired into the home screen in Phase 1 — managed via home controller.
class HomeRepository {
  HomeRepository(this._dio);
  final Dio _dio;

  Future<HomeData> fetchHomeData() async {
    final results = await Future.wait([
      _dio.get(ApiEndpoints.brands),
      _dio.get(ApiEndpoints.featuredVehicles),
      _dio.get(ApiEndpoints.categories),
    ]);

    final rawBrands = results[0].data as List<dynamic>? ?? [];
    final rawVehicles = results[1].data as List<dynamic>? ?? [];
    final rawCategories = results[2].data as List<dynamic>? ?? [];

    return HomeData(
      brands: rawBrands
          .map((e) => BrandModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      featuredVehicles: rawVehicles
          .map((e) => VehicleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: rawCategories
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<List<OfferModel>> fetchOffers() async {
    try {
      final response = await _dio.get(ApiEndpoints.offers);
      final data = response.data as List<dynamic>;
      return data.map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      // Offers endpoint is optional — return empty list gracefully
      return [];
    }
  }
}
