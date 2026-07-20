import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/profile_models.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.read(dioProvider));
});

class ProfileRepository {
  ProfileRepository(this._dio);
  final Dio _dio;

  Future<List<BookingModel>> fetchBookings() async {
    try {
      final response = await _dio.get(ApiEndpoints.userBookings);
      final list = response.data as List<dynamic>;
      return list.map((json) => BookingModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<FaqModel>> fetchFaqs() async {
    try {
      final response = await _dio.get(ApiEndpoints.faqs);
      final list = response.data as List<dynamic>;
      return list.map((json) => FaqModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<SiteSettingModel>> fetchSettings() async {
    try {
      final response = await _dio.get(ApiEndpoints.settings);
      final list = response.data as List<dynamic>;
      return list.map((json) => SiteSettingModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
