/// App-wide constants for TrailerHub application
library;

class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://api.trailerbaaz.com/api/v1';
  static const String apiKey = 'your_api_key_here';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String watchlistKey = 'watchlist';
  static const String watchedHistoryKey = 'watched_history';
  static const String darkModeKey = 'dark_mode';
  static const String notificationsKey = 'notifications_enabled';
  static const String userPreferencesKey = 'user_preferences';

  // Screen Names
  static const String homeScreen = 'home';
  static const String trendingScreen = 'trending';
  static const String categoriesScreen = 'categories';
  static const String watchlistScreen = 'watchlist';
  static const String profileScreen = 'profile';
  static const String trailerDetailScreen = 'trailer_detail';

  // Categories
  static const List<String> categories = [
    'Hollywood',
    'Bollywood',
    'Telugu',
    'Tamil',
    'Korean',
    'Netflix',
    'Amazon Prime',
    'Disney+',
  ];

  // API Endpoints
  static const String trendingTrailersEndpoint = '/trailers/trending';
  static const String upcomingReleasesEndpoint = '/trailers/upcoming';
  static const String recentlyAddedEndpoint = '/trailers/recent';
  static const String categoriesEndpoint = '/categories';
  static const String searchEndpoint = '/trailers/search';

  // Pagination
  static const int itemsPerPage = 20;
  static const int initialPage = 1;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  // App Info
  static const String appName = 'TrailerHub';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Your ultimate destination for movie and TV show trailers';
}
