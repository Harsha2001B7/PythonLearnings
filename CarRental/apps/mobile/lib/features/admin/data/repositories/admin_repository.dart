import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../home/data/models/home_models.dart';
import '../models/admin_models.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.read(dioProvider));
});

class AdminRepository {
  AdminRepository(this._dio);
  final Dio _dio;

  Future<AdminStatsModel> fetchStats() async {
    final response = await _dio.get(ApiEndpoints.adminStats);
    return AdminStatsModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<AdminBookingModel>> fetchBookings() async {
    final response = await _dio.get(ApiEndpoints.adminBookings);
    final list = response.data as List<dynamic>;
    return list.map((json) => AdminBookingModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> updateBookingStatus(int bookingId, String status) async {
    await _dio.put(
      '${ApiEndpoints.adminBookings}/$bookingId/status',
      data: {'status': status},
    );
  }

  Future<void> updateVehicleStatus(VehicleModel vehicle, bool newStatus) async {
    await _dio.patch(
      '${ApiEndpoints.vehicles}${vehicle.id}/availability',
      queryParameters: {'available': newStatus},
    );
  }

  Future<Map<String, dynamic>> addVehicle(Map<String, dynamic> data) async {
    final response = await _dio.post(
      ApiEndpoints.vehicles,
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateVehicle(int vehicleId, Map<String, dynamic> data) async {
    await _dio.put(
      '${ApiEndpoints.vehicles}$vehicleId',
      data: data,
    );
  }

  Future<void> deleteVehicle(int vehicleId) async {
    await _dio.delete('${ApiEndpoints.vehicles}$vehicleId');
  }

  Future<String> uploadVehicleImage(int vehicleId, String filePath, {String imageType = 'thumbnail'}) async {
    final fileName = filePath.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      'image_type': imageType,
    });
    final response = await _dio.post(
      '${ApiEndpoints.vehicles}$vehicleId/upload-image',
      data: formData,
    );
    return response.data['image_url'] as String;
  }

  Future<List<AdminUserModel>> fetchUsers() async {
    final response = await _dio.get(ApiEndpoints.adminUsers);
    final list = response.data as List<dynamic>;
    return list.map((json) => AdminUserModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> updateUserStatus(int userId, String status) async {
    await _dio.put(
      '${ApiEndpoints.adminUsers}/$userId/status',
      data: {'status': status},
    );
  }
}
