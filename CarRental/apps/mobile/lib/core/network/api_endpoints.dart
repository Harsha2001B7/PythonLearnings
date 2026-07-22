/// API endpoint constants for Falcon View Car Rentals.
class ApiEndpoints {
  ApiEndpoints._();

  // ─── Base URL Configuration ───────────────────────────────────────────────
  static const String adbLoopbackUrl = 'http://127.0.0.1:8000';
  static const String wifiBaseUrl = 'http://192.168.1.113:8000';
  
  // Set your production backend URL here or pass via --dart-define=BACKEND_URL=...
  static const String productionBaseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: adbLoopbackUrl,
  );

  /// Base URL getter
  static String get baseUrl => productionBaseUrl;

  static const String apiV1 = '/api/v1';

  // ─── Auth Endpoints ──────────────────────────────────────────────────────
  static String get login => '$baseUrl$apiV1/auth/login';
  static String get register => '$baseUrl$apiV1/auth/register';
  static String get googleLogin => '$baseUrl$apiV1/auth/google';
  static String get refresh => '$baseUrl$apiV1/auth/refresh';
  static String get me => '$baseUrl$apiV1/auth/me';
  static String get logout => '$baseUrl$apiV1/auth/logout';
  static String get forgotPassword => '$baseUrl$apiV1/auth/forgot-password';
  static String get userMe => '$baseUrl$apiV1/users/me';
  static String get uploadAvatar => '$baseUrl$apiV1/users/me/upload-avatar';

  // ─── Home & Fleet Endpoints ─────────────────────────────────────────────
  static String get home => '$baseUrl$apiV1/home/';
  static String get brands => '$baseUrl$apiV1/brands/';
  static String get vehicles => '$baseUrl$apiV1/vehicles/';
  static String get featuredVehicles => '$baseUrl$apiV1/vehicles/featured';
  static String get categories => '$baseUrl$apiV1/categories/';
  static String get offers => '$baseUrl$apiV1/offers/';
  static String get bookingsMy => '$baseUrl$apiV1/bookings/my';
  static String get userBookings => '$baseUrl$apiV1/users/me/bookings';
  static String get faqs => '$baseUrl$apiV1/faqs/';
  static String get settings => '$baseUrl$apiV1/settings/';

  // ─── Admin Endpoints ────────────────────────────────────────────────────
  static String get adminStats => '$baseUrl$apiV1/dashboard/stats';
  static String get adminBookings => '$baseUrl$apiV1/admin/bookings';
  static String get adminUsers => '$baseUrl$apiV1/admin/users';
}
