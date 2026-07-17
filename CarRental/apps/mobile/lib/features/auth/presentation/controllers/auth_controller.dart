import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
// AuthException is defined in login_screen.dart — import it here so the
// controller can re-throw typed exceptions that the view surfaces verbatim.
import '../views/login_screen.dart';

// ─── Auth State ───────────────────────────────────────────────────────────────
sealed class AuthState {
  const AuthState();
}

class AuthInitializing extends AuthState {
  const AuthInitializing();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final UserModel user;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated([this.error]);
  final String? error;
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

// ─── Auth Controller ──────────────────────────────────────────────────────────
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(authRepositoryProvider));
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(const AuthInitializing()) {
    _init();
  }

  final AuthRepository _repo;

  // ─── Session restore ─────────────────────────────────────────────────────
  // Called once at startup. Tries:
  //   1. GET /auth/me with stored access_token
  //   2. POST /auth/refresh if (1) fails but refresh_token is present
  //   3. Clears storage and emits AuthUnauthenticated if both fail
  Future<void> _init() async {
    try {
      final user = await _repo.restoreSession();
      state = user != null ? AuthAuthenticated(user) : const AuthUnauthenticated();
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  // ─── Email / password login ───────────────────────────────────────────────
  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final result =
          await _repo.loginWithEmail(email: email, password: password);
      state = AuthAuthenticated(result.user);
    } on DioException catch (e) {
      final msg = _dioErrorMessage(e);
      state = AuthUnauthenticated(msg);
      throw AuthException(msg);
    } catch (e) {
      const msg = 'An error occurred. Please try again.';
      state = const AuthUnauthenticated(msg);
      throw const AuthException(msg);
    }
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────
  // Receives the Google ID Token from the native google_sign_in package.
  // POSTs to /auth/google { id_token } → access_token + refresh_token
  // Then GETs /auth/me to retrieve the full user profile and role.
  Future<void> loginWithGoogle(String idToken) async {
    state = const AuthLoading();
    try {
      final result = await _repo.loginWithGoogle(idToken: idToken);
      state = AuthAuthenticated(result.user);
    } on DioException catch (e) {
      final msg = _dioErrorMessage(e);
      state = AuthUnauthenticated(msg);
      throw AuthException(msg);
    } catch (e) {
      const msg = 'Google authentication failed. Please try again.';
      state = const AuthUnauthenticated(msg);
      throw const AuthException(msg);
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _repo.logout();
    state = const AuthUnauthenticated();
  }

  UserModel? get currentUser {
    final s = state;
    return s is AuthAuthenticated ? s.user : null;
  }

  bool get isAuthenticated => state is AuthAuthenticated;

  // ─── Helpers ──────────────────────────────────────────────────────────────
  String _dioErrorMessage(DioException e) {
    // Try to surface the backend's `detail` field first (FastAPI convention)
    final detail = e.response?.data;
    if (detail is Map && detail['detail'] != null) {
      return detail['detail'].toString();
    }
    if (detail is String && detail.isNotEmpty) {
      return detail;
    }

    // Fall back to status-code-aware messages
    final status = e.response?.statusCode;
    if (status == 400) return 'Incorrect email or password.';
    if (status == 401) return 'Session expired. Please sign in again.';
    if (status == 403) return 'Access denied.';

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Cannot reach server. Check your internet connection.';
    }

    return 'An error occurred. Please try again.';
  }
}
