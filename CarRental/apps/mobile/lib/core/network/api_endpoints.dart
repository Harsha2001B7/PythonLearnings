/// API endpoint constants.
/// Base URL uses 10.0.2.2 for Android emulator (maps to host machine's localhost).
class ApiEndpoints {
  ApiEndpoints._();

  // ─── Base ─────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://falconviewcarrental.onrender.com';
  static const String apiV1 = '/api/v1';

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static const String login = '$apiV1/auth/login';
  static const String googleLogin = '$apiV1/auth/google';
  static const String refresh = '$apiV1/auth/refresh';
  static const String me = '$apiV1/auth/me';
  static const String logout = '$apiV1/auth/logout';
  static const String forgotPassword = '$apiV1/auth/forgot-password';

  // ─── Home ─────────────────────────────────────────────────────────────────
  static const String home = '$apiV1/home/';
  static const String brands = '$apiV1/brands/';
  static const String vehicles = '$apiV1/vehicles/';
  static const String featuredVehicles = '$apiV1/vehicles/featured';
  static const String categories = '$apiV1/categories/';
  static const String offers = '$apiV1/offers/';
  static const String bookingsMy = '$apiV1/bookings/my';
}
