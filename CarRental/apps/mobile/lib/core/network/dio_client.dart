import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

/// Dio singleton provider.
final dioProvider = Provider<Dio>((ref) {
  final storage = ref.read(secureStorageProvider);
  final dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(AuthInterceptor(dio: dio, storage: storage));
  return dio;
});

/// Intercepts every request to inject the Bearer token.
/// On 401, attempts a silent token refresh, queues concurrent requests,
/// and clears credentials if the refresh itself fails.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.dio, required this.storage});

  final Dio dio;
  final SecureStorage storage;

  bool _isRefreshing = false;
  final List<_RetryRequest> _queue = [];

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;

    // Only intercept 401s — skip retry for auth endpoints to avoid loops
    if (response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final requestUrl = err.requestOptions.path;
    if (requestUrl.contains('/auth/refresh') ||
        requestUrl.contains('/auth/login') ||
        requestUrl.contains('/auth/google')) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      // Queue the request until refresh completes
      final completer = Completer<Response>();
      _queue.add(_RetryRequest(err.requestOptions, completer));
      try {
        final res = await completer.future;
        handler.resolve(res);
      } catch (e) {
        handler.next(err);
      }
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken == null) {
        await _clearAndFail(handler, err);
        return;
      }

      // Use a separate Dio instance to avoid interceptor loop
      final refreshDio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
      final refreshResponse = await refreshDio.post(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );

      final newAccess = refreshResponse.data['access_token'] as String;
      final newRefresh = refreshResponse.data['refresh_token'] as String;

      await storage.saveAccessToken(newAccess);
      await storage.saveRefreshToken(newRefresh);

      // Retry the original request
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
      final retryResponse = await dio.fetch(err.requestOptions);

      // Flush queued requests
      for (final pending in _queue) {
        pending.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
        try {
          final r = await dio.fetch(pending.requestOptions);
          pending.completer.complete(r);
        } catch (e) {
          pending.completer.completeError(e);
        }
      }
      _queue.clear();

      handler.resolve(retryResponse);
    } catch (_) {
      for (final pending in _queue) {
        pending.completer.completeError(err);
      }
      _queue.clear();
      await _clearAndFail(handler, err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _clearAndFail(ErrorInterceptorHandler handler, DioException err) async {
    await storage.clearAll();
    handler.next(err);
  }
}

class _RetryRequest {
  final RequestOptions requestOptions;
  final Completer<Response> completer;
  _RetryRequest(this.requestOptions, this.completer);
}
