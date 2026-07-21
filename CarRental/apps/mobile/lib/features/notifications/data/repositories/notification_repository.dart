import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/notification_models.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.read(dioProvider);
  return NotificationRepository(dio);
});

class NotificationRepository {
  NotificationRepository(this._dio);

  final Dio _dio;

  Future<List<NotificationItemModel>> fetchNotifications({int skip = 0, int limit = 50}) async {
    final response = await _dio.get(
      '${ApiEndpoints.baseUrl}/api/v1/notifications/',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    final list = response.data as List<dynamic>;
    return list.map((item) => NotificationItemModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<int> fetchUnreadCount() async {
    final response = await _dio.get('${ApiEndpoints.baseUrl}/api/v1/notifications/unread-count');
    final data = response.data as Map<String, dynamic>;
    return (data['unread_count'] as int?) ?? 0;
  }

  Future<void> markAsRead(int notificationId) async {
    await _dio.patch('${ApiEndpoints.baseUrl}/api/v1/notifications/$notificationId/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.patch('${ApiEndpoints.baseUrl}/api/v1/notifications/read-all');
  }
}
