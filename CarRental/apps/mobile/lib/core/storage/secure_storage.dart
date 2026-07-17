import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

/// Typed wrapper around [FlutterSecureStorage] for token persistence.
class SecureStorage {
  SecureStorage()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  final FlutterSecureStorage _storage;

  static const _keyAccess = 'fv_access_token';
  static const _keyRefresh = 'fv_refresh_token';
  static const _keyUser = 'fv_user_profile';

  // ─── Access Token ─────────────────────────────────────
  Future<void> saveAccessToken(String token) => _storage.write(key: _keyAccess, value: token);
  Future<String?> getAccessToken() => _storage.read(key: _keyAccess);
  Future<void> deleteAccessToken() => _storage.delete(key: _keyAccess);

  // ─── Refresh Token ────────────────────────────────────
  Future<void> saveRefreshToken(String token) => _storage.write(key: _keyRefresh, value: token);
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefresh);
  Future<void> deleteRefreshToken() => _storage.delete(key: _keyRefresh);

  // ─── User Profile (JSON string) ───────────────────────
  Future<void> saveUserProfile(String json) => _storage.write(key: _keyUser, value: json);
  Future<String?> getUserProfile() => _storage.read(key: _keyUser);
  Future<void> deleteUserProfile() => _storage.delete(key: _keyUser);

  // ─── Clear all session data ───────────────────────────
  Future<void> clearAll() async {
    await _storage.delete(key: _keyAccess);
    await _storage.delete(key: _keyRefresh);
    await _storage.delete(key: _keyUser);
  }

  /// Returns true if a stored access token exists.
  Future<bool> hasSession() async {
    final token = await _storage.read(key: _keyAccess);
    return token != null && token.isNotEmpty;
  }
}
