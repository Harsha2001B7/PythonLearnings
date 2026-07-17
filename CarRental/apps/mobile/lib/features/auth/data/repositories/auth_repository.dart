import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.read(dioProvider),
    storage: ref.read(secureStorageProvider),
  );
});

/// Handles all authentication API calls against the FastAPI backend.
/// Endpoints: /api/v1/auth/login, /google, /refresh, /me, /logout
class AuthRepository {
  AuthRepository({required this.dio, required this.storage});

  final Dio dio;
  final SecureStorage storage;

  // ─── Email / Password Login ─────────────────────────────────────────────
  Future<({AuthTokens tokens, UserModel user})> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    final tokens = AuthTokens.fromJson(response.data as Map<String, dynamic>);
    final user = await _fetchProfile(tokens.accessToken);
    await _persistSession(tokens, user);
    return (tokens: tokens, user: user);
  }

  // ─── Google Sign-In ─────────────────────────────────────────────────────
  /// Sends the Google [idToken] to the backend and returns JWT tokens + user.
  Future<({AuthTokens tokens, UserModel user})> loginWithGoogle({
    required String idToken,
  }) async {
    final response = await dio.post(
      ApiEndpoints.googleLogin,
      data: {'id_token': idToken},
    );
    final tokens = AuthTokens.fromJson(response.data as Map<String, dynamic>);
    final user = await _fetchProfile(tokens.accessToken);
    await _persistSession(tokens, user);
    return (tokens: tokens, user: user);
  }

  // ─── Token Refresh ──────────────────────────────────────────────────────
  Future<AuthTokens> refreshTokens(String refreshToken) async {
    final response = await dio.post(
      ApiEndpoints.refresh,
      data: {'refresh_token': refreshToken},
    );
    final tokens = AuthTokens.fromJson(response.data as Map<String, dynamic>);
    await storage.saveAccessToken(tokens.accessToken);
    await storage.saveRefreshToken(tokens.refreshToken);
    return tokens;
  }

  // ─── Get /auth/me ───────────────────────────────────────────────────────
  Future<UserModel> fetchProfile() async {
    final token = await storage.getAccessToken() ?? '';
    return _fetchProfile(token);
  }

  // ─── Logout ─────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken != null) {
        await dio.post(ApiEndpoints.logout, data: {'refresh_token': refreshToken});
      }
    } catch (_) {
      // Best-effort logout — always clear local storage
    } finally {
      await storage.clearAll();
    }
  }

  // ─── Restore session ────────────────────────────────────────────────────
  /// Attempts to restore the previous session from secure storage.
  /// Returns [UserModel] if valid tokens exist, otherwise null.
  Future<UserModel?> restoreSession() async {
    final accessToken = await storage.getAccessToken();
    final refreshToken = await storage.getRefreshToken();

    if (accessToken == null) return null;

    try {
      // First try: validate access token with /me
      final user = await _fetchProfile(accessToken);
      return user;
    } catch (_) {
      // Second try: refresh the token if we have a refresh token
      if (refreshToken != null) {
        try {
          final newTokens = await refreshTokens(refreshToken);
          final user = await _fetchProfile(newTokens.accessToken);
          await storage.saveUserProfile(user.toJsonString());
          return user;
        } catch (_) {
          await storage.clearAll();
          return null;
        }
      }
      await storage.clearAll();
      return null;
    }
  }

  // ─── Private helpers ─────────────────────────────────────────────────────
  Future<UserModel> _fetchProfile(String accessToken) async {
    final response = await dio.get(
      ApiEndpoints.me,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> _persistSession(AuthTokens tokens, UserModel user) async {
    await storage.saveAccessToken(tokens.accessToken);
    await storage.saveRefreshToken(tokens.refreshToken);
    await storage.saveUserProfile(user.toJsonString());
  }
}
