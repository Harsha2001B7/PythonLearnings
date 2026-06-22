import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/trailer_model.dart';

/// Trailer Provider
/// Manages trailer data and API calls using Provider pattern

class TrailerProvider extends ChangeNotifier {
  final ApiService apiService;

  // State variables
  List<TrailerModel> _trendingTrailers = [];
  List<TrailerModel> _upcomingReleases = [];
  List<TrailerModel> _recentlyAdded = [];
  List<TrailerModel> _searchResults = [];

  bool _isLoadingTrending = false;
  bool _isLoadingUpcoming = false;
  bool _isLoadingRecent = false;
  bool _isLoadingSearch = false;

  String? _errorMessage;
  int _currentTrendingPage = 1;
  int _currentUpcomingPage = 1;
  int _currentRecentPage = 1;

  // Getters
  List<TrailerModel> get trendingTrailers => _trendingTrailers;
  List<TrailerModel> get upcomingReleases => _upcomingReleases;
  List<TrailerModel> get recentlyAdded => _recentlyAdded;
  List<TrailerModel> get searchResults => _searchResults;

  bool get isLoadingTrending => _isLoadingTrending;
  bool get isLoadingUpcoming => _isLoadingUpcoming;
  bool get isLoadingRecent => _isLoadingRecent;
  bool get isLoadingSearch => _isLoadingSearch;

  String? get errorMessage => _errorMessage;
  int get currentTrendingPage => _currentTrendingPage;

  TrailerProvider({required this.apiService});

  /// Load trending trailers
  Future<void> loadTrendingTrailers({bool isLoadMore = false}) async {
    if (isLoadMore) {
      _currentTrendingPage++;
    } else {
      _currentTrendingPage = 1;
      _isLoadingTrending = true;
      _errorMessage = null;
    }

    notifyListeners();

    try {
      final trailers = await apiService.getTrendingTrailers(
        page: _currentTrendingPage,
      );

      if (isLoadMore) {
        _trendingTrailers.addAll(trailers);
      } else {
        _trendingTrailers = trailers;
      }

      _isLoadingTrending = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingTrending = false;
      if (isLoadMore) {
        _currentTrendingPage--;
      }
    }

    notifyListeners();
  }

  /// Load upcoming releases
  Future<void> loadUpcomingReleases({bool isLoadMore = false}) async {
    if (isLoadMore) {
      _currentUpcomingPage++;
    } else {
      _currentUpcomingPage = 1;
      _isLoadingUpcoming = true;
      _errorMessage = null;
    }

    notifyListeners();

    try {
      final trailers = await apiService.getUpcomingReleases(
        page: _currentUpcomingPage,
      );

      if (isLoadMore) {
        _upcomingReleases.addAll(trailers);
      } else {
        _upcomingReleases = trailers;
      }

      _isLoadingUpcoming = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingUpcoming = false;
      if (isLoadMore) {
        _currentUpcomingPage--;
      }
    }

    notifyListeners();
  }

  /// Load recently added trailers
  Future<void> loadRecentlyAdded({bool isLoadMore = false}) async {
    if (isLoadMore) {
      _currentRecentPage++;
    } else {
      _currentRecentPage = 1;
      _isLoadingRecent = true;
      _errorMessage = null;
    }

    notifyListeners();

    try {
      final trailers = await apiService.getRecentlyAdded(
        page: _currentRecentPage,
      );

      if (isLoadMore) {
        _recentlyAdded.addAll(trailers);
      } else {
        _recentlyAdded = trailers;
      }

      _isLoadingRecent = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingRecent = false;
      if (isLoadMore) {
        _currentRecentPage--;
      }
    }

    notifyListeners();
  }

  /// Search trailers
  Future<void> searchTrailers(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _isLoadingSearch = false;
      notifyListeners();
      return;
    }

    _isLoadingSearch = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final trailers = await apiService.searchTrailers(query: query);
      _searchResults = trailers;
      _isLoadingSearch = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingSearch = false;
      _searchResults = [];
    }

    notifyListeners();
  }

  /// Clear search results
  void clearSearch() {
    _searchResults = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
