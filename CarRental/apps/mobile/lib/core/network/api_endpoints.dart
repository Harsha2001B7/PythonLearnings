/// API endpoint constants for Falcon View Car Rentals.
class ApiEndpoints {
  ApiEndpoints._();

  // ─── Environment Configuration ──────────────────────────────────────────
  // Set [useRenderProduction] to true when you want to switch to the live Render API.
  // Set [useRenderProduction] to false when testing against local FastAPI backend.
  static const bool useRenderProduction = false;

  // ─── Local IP Configuration ─────────────────────────────────────────────
  // 192.168.1.113 connects directly over Wi-Fi without needing USB or adb reverse!
  static const String wifiBaseUrl = 'http://192.168.1.113:8000';
  static const String adbLoopbackUrl = 'http://127.0.0.1:8000';
  static const String renderBaseUrl = 'https://falconviewcarrental.onrender.com';

  // Default to Wi-Fi IP for seamless permanent phone connection
  static const String localBaseUrl = adbLoopbackUrl;

  /// Dynamic base URL getter based on [useRenderProduction]
  static String get baseUrl => useRenderProduction ? renderBaseUrl : localBaseUrl;

  static const String apiV1 = '/api/v1';

  // ─── Auth Endpoints ──────────────────────────────────────────────────────
  static String get login => '$baseUrl$apiV1/auth/login';
  static String get register => '$baseUrl$apiV1/auth/register';
  static String get googleLogin => '$baseUrl$apiV1/auth/google';
  static String get refresh => '$baseUrl$apiV1/auth/refresh';
  static String get me => '$baseUrl$apiV1/auth/me';
  static String get logout => '$baseUrl$apiV1/auth/logout';
  static String get forgotPassword => '$baseUrl$apiV1/auth/forgot-password';

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
