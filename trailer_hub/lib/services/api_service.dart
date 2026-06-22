import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../models/trailer_model.dart';
import '../models/category_model.dart';

/// API Service
/// Handles all API calls for the TrailerHub application
/// Currently uses dummy data - replace with real API calls when backend is ready

class ApiService {
  late Dio _dio;
  
  // Dummy YouTube video URL (Spider-Man: Brand New Day)
  static const String dummyVideoUrl = 'https://youtu.be/62bIsvRcPv0?si=Vrlr0obZ-oUtpf90';

  ApiService() {
    // Initialize Dio with base configuration
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AppConstants.apiKey}',
        },
      ),
    );

    // Add interceptors for logging (optional, for debugging)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {
          // Uncomment for debugging
          // print(obj);
        },
      ),
    );
  }

  /// Get trending trailers
  /// Returns a list of trending trailers
  Future<List<TrailerModel>> getTrendingTrailers({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.trendingTrailersEndpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      // Handle successful response
      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? response.data ?? [];
        return data
            .map((trailer) => TrailerModel.fromJson(trailer))
            .toList();
      } else {
        throw Exception('Failed to load trending trailers');
      }
    } on DioException {
      // Return dummy data when API fails
      return _generateDummyTrailers();
    }
  }

  /// Get upcoming releases
  /// Returns a list of upcoming trailer releases
  Future<List<TrailerModel>> getUpcomingReleases({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.upcomingReleasesEndpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? response.data ?? [];
        return data
            .map((trailer) => TrailerModel.fromJson(trailer))
            .toList();
      } else {
        throw Exception('Failed to load upcoming releases');
      }
    } on DioException {
      // Return dummy data when API fails
      return _generateDummyTrailers();
    }
  }

  /// Get recently added trailers
  /// Returns a list of recently added trailers
  Future<List<TrailerModel>> getRecentlyAdded({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.recentlyAddedEndpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? response.data ?? [];
        return data
            .map((trailer) => TrailerModel.fromJson(trailer))
            .toList();
      } else {
        throw Exception('Failed to load recently added trailers');
      }
    } on DioException {
      // Return dummy data when API fails
      return _generateDummyTrailers();
    }
  }

  /// Get trailers by category
  /// Returns trailers for a specific category
  Future<List<TrailerModel>> getTrailersByCategory({
    required String category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConstants.categoriesEndpoint}/$category/trailers',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? response.data ?? [];
        return data
            .map((trailer) => TrailerModel.fromJson(trailer))
            .toList();
      } else {
        throw Exception('Failed to load trailers for category: $category');
      }
    } on DioException {
      // Return dummy data when API fails
      return _generateDummyTrailers();
    }
  }

  /// Search trailers
  /// Returns trailers matching the search query
  Future<List<TrailerModel>> searchTrailers({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.searchEndpoint,
        queryParameters: {
          'q': query,
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? response.data ?? [];
        return data
            .map((trailer) => TrailerModel.fromJson(trailer))
            .toList();
      } else {
        throw Exception('No results found for: $query');
      }
    } on DioException {
      // Return dummy data when API fails, filtered by search query
      List<TrailerModel> dummyData = _generateDummyTrailers();
      return dummyData
          .where((trailer) =>
              trailer.title.toLowerCase().contains(query.toLowerCase()) ||
              trailer.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  /// Get all categories
  /// Returns a list of all available categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get(AppConstants.categoriesEndpoint);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? response.data ?? [];
        return data
            .map((category) => CategoryModel.fromJson(category))
            .toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } on DioException {
      // Return dummy categories when API fails
      return AppConstants.categories
          .map((cat) => CategoryModel(
                id: cat.toLowerCase(),
                name: cat,
                description: '$cat trailers',
                iconUrl: 'https://via.placeholder.com/100?text=$cat',
                createdDate: DateTime.now(),
                trailerCount: 1
              ))
          .toList();
    }
  }

  /// Get single trailer details
  /// Returns detailed information about a specific trailer
  Future<TrailerModel> getTrailerDetails(String trailerId) async {
    try {
      final response = await _dio.get('/trailers/$trailerId');

      if (response.statusCode == 200) {
        return TrailerModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception('Failed to load trailer details');
      }
    } on DioException {
      // Return a dummy trailer when API fails
      List<TrailerModel> dummyData = _generateDummyTrailers();
      return dummyData.firstWhere(
        (trailer) => trailer.id == trailerId,
        orElse: () => dummyData.first,
      );
    }
  }

  /// Get trailers sorted by views
  /// Returns trailers sorted by popularity (views)
  Future<List<TrailerModel>> getTrailersSortedByViews({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.trendingTrailersEndpoint,
        queryParameters: {
          'sortBy': 'views',
          'order': 'desc',
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? response.data ?? [];
        return data
            .map((trailer) => TrailerModel.fromJson(trailer))
            .toList();
      } else {
        throw Exception('Failed to load trailers sorted by views');
      }
    } on DioException {
      // Return dummy data sorted by views when API fails
      List<TrailerModel> dummyData = _generateDummyTrailers();
      dummyData.sort((a, b) => b.views.compareTo(a.views));
      return dummyData;
    }
  }

  /// Get trailers by rating
  /// Returns trailers sorted by rating
  Future<List<TrailerModel>> getTrailersByRating({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.trendingTrailersEndpoint,
        queryParameters: {
          'sortBy': 'rating',
          'order': 'desc',
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? response.data ?? [];
        return data
            .map((trailer) => TrailerModel.fromJson(trailer))
            .toList();
      } else {
        throw Exception('Failed to load top-rated trailers');
      }
    } on DioException {
      // Return dummy data sorted by rating when API fails
      List<TrailerModel> dummyData = _generateDummyTrailers();
      dummyData.sort((a, b) => b.rating.compareTo(a.rating));
      return dummyData;
    }
  }

  /// Generate dummy trailers for testing/demo purposes
  /// Uses Spider-Man: Brand New Day as placeholder video
  List<TrailerModel> _generateDummyTrailers() {
    return [
      TrailerModel(
        id: '1',
        title: 'Spider-Man: Brand New Day',
        description:
            'An exciting new adventure of Spider-Man. Experience the action-packed trailer that will blow your mind!',
        imageUrl:
            'https://images.unsplash.com/photo-1544716278-ca5e3af8abd8?w=500&h=700&fit=crop',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1544716278-ca5e3af8abd8?w=200&h=300&fit=crop',
        videoUrl: dummyVideoUrl,
        category: 'Hollywood',
        releaseDate: DateTime(2024, 6, 15),
        rating: 8.5,
        views: 2500000,
        genres: ['Action', 'Adventure', 'Superhero'],
        language: 'English',
        durationInSeconds: 180,
        productionHouse: 'Marvel Studios',
        addedDate: DateTime(2024, 6, 1),
      ),
      TrailerModel(
        id: '2',
        title: 'The Avengers: Endgame',
        description:
            'The epic conclusion to the Avengers saga. Heroes assemble for an unforgettable battle.',
        imageUrl:
            'https://images.unsplash.com/photo-1536440936338-c2d0513a8671?w=500&h=700&fit=crop',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1536440936338-c2d0513a8671?w=200&h=300&fit=crop',
        videoUrl: dummyVideoUrl,
        category: 'Hollywood',
        releaseDate: DateTime(2024, 5, 10),
        rating: 9.0,
        views: 5000000,
        genres: ['Action', 'Adventure', 'Sci-Fi'],
        language: 'English',
        durationInSeconds: 150,
        productionHouse: 'Marvel Studios',
        addedDate: DateTime(2024, 5, 1),
      ),
      TrailerModel(
        id: '3',
        title: 'Avatar: The Way of Water',
        description: 'Return to the world of Pandora in this visual masterpiece.',
        imageUrl:
            'https://images.unsplash.com/photo-1514306688772-2196b1ae2c1d?w=500&h=700&fit=crop',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1514306688772-2196b1ae2c1d?w=200&h=300&fit=crop',
        videoUrl: dummyVideoUrl,
        category: 'Hollywood',
        releaseDate: DateTime(2024, 4, 20),
        rating: 8.8,
        views: 4200000,
        genres: ['Sci-Fi', 'Adventure', 'Fantasy'],
        language: 'English',
        durationInSeconds: 200,
        productionHouse: '20th Century Studios',
        addedDate: DateTime(2024, 4, 1),
      ),
      TrailerModel(
        id: '4',
        title: 'Pathaan',
        description: 'A thrilling action spy thriller from Bollywood.',
        imageUrl:
            'https://images.unsplash.com/photo-1570158108792-4eb260c56df8?w=500&h=700&fit=crop',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1570158108792-4eb260c56df8?w=200&h=300&fit=crop',
        videoUrl: dummyVideoUrl,
        category: 'Bollywood',
        releaseDate: DateTime(2024, 3, 15),
        rating: 7.8,
        views: 3000000,
        genres: ['Action', 'Thriller', 'Spy'],
        language: 'Hindi',
        durationInSeconds: 160,
        productionHouse: 'Red Chillies Entertainment',
        addedDate: DateTime(2024, 3, 1),
      ),
      TrailerModel(
        id: '5',
        title: 'Jawan',
        description: 'A blockbuster action film with stunning cinematography.',
        imageUrl:
            'https://images.unsplash.com/photo-1503460006622-bc46c3f1c4d2?w=500&h=700&fit=crop',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1503460006622-bc46c3f1c4d2?w=200&h=300&fit=crop',
        videoUrl: dummyVideoUrl,
        category: 'Bollywood',
        releaseDate: DateTime(2024, 2, 20),
        rating: 7.9,
        views: 2800000,
        genres: ['Action', 'Drama', 'Crime'],
        language: 'Hindi',
        durationInSeconds: 170,
        productionHouse: 'Red Chillies Entertainment',
        addedDate: DateTime(2024, 2, 1),
      ),
      TrailerModel(
        id: '6',
        title: 'Pushpa: The Rise',
        description: 'A Telugu action film that broke all box office records.',
        imageUrl:
            'https://images.unsplash.com/photo-1522869635100-ce306e08591d?w=500&h=700&fit=crop',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1522869635100-ce306e08591d?w=200&h=300&fit=crop',
        videoUrl: dummyVideoUrl,
        category: 'Telugu',
        releaseDate: DateTime(2024, 1, 25),
        rating: 8.3,
        views: 2200000,
        genres: ['Action', 'Crime', 'Drama'],
        language: 'Telugu',
        durationInSeconds: 180,
        productionHouse: 'Mythri Movie Makers',
        addedDate: DateTime(2024, 1, 10),
      ),
      TrailerModel(
        id: '7',
        title: 'Kabali',
        description: 'A Tamil action thriller with superb performances.',
        imageUrl:
            'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=500&h=700&fit=crop',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=200&h=300&fit=crop',
        videoUrl: dummyVideoUrl,
        category: 'Tamil',
        releaseDate: DateTime(2024, 1, 15),
        rating: 8.1,
        views: 1900000,
        genres: ['Action', 'Crime', 'Thriller'],
        language: 'Tamil',
        durationInSeconds: 155,
        productionHouse: 'S. Pictures',
        addedDate: DateTime(2024, 1, 5),
      ),
      TrailerModel(
        id: '8',
        title: 'Squid Game: The Challenge',
        description: 'A Netflix survival series that took the world by storm.',
        imageUrl:
            'https://images.unsplash.com/photo-1569269271066-f2953f6f623f?w=500&h=700&fit=crop',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1569269271066-f2953f6f623f?w=200&h=300&fit=crop',
        videoUrl: dummyVideoUrl,
        category: 'Netflix',
        releaseDate: DateTime(2023, 12, 20),
        rating: 8.6,
        views: 4500000,
        genres: ['Drama', 'Thriller', 'Reality'],
        language: 'Korean',
        durationInSeconds: 200,
        productionHouse: 'Netflix',
        addedDate: DateTime(2023, 12, 10),
      ),
    ];
  }
}
