import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/constants/app_constants.dart';
import '../models/trailer_model.dart';

/// Watchlist Provider
/// Manages watchlist using Provider pattern and SharedPreferences for local storage

class WatchlistProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  List<TrailerModel> _watchlist = [];
  List<TrailerModel> _watchedHistory = [];

  // Getters
  List<TrailerModel> get watchlist => _watchlist;
  List<TrailerModel> get watchedHistory => _watchedHistory;
  int get watchlistCount => _watchlist.length;
  int get watchedCount => _watchedHistory.length;

  /// Initialize the watchlist provider
  /// Load saved watchlist from SharedPreferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadWatchlist();
    await _loadWatchedHistory();
  }

  /// Load watchlist from SharedPreferences
  Future<void> _loadWatchlist() async {
    try {
      final jsonString = _prefs.getString(AppConstants.watchlistKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _watchlist = jsonList
            .map((item) => TrailerModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      _watchlist = [];
    }
    notifyListeners();
  }

  /// Load watched history from SharedPreferences
  Future<void> _loadWatchedHistory() async {
    try {
      final jsonString = _prefs.getString(AppConstants.watchedHistoryKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _watchedHistory = jsonList
            .map((item) => TrailerModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      _watchedHistory = [];
    }
    notifyListeners();
  }

  /// Save watchlist to SharedPreferences
  Future<void> _saveWatchlist() async {
    try {
      final jsonString = jsonEncode(
        _watchlist.map((item) => item.toJson()).toList(),
      );
      await _prefs.setString(AppConstants.watchlistKey, jsonString);
    } catch (e) {
      // Handle error
    }
  }

  /// Save watched history to SharedPreferences
  Future<void> _saveWatchedHistory() async {
    try {
      final jsonString = jsonEncode(
        _watchedHistory.map((item) => item.toJson()).toList(),
      );
      await _prefs.setString(AppConstants.watchedHistoryKey, jsonString);
    } catch (e) {
      // Handle error
    }
  }

  /// Add trailer to watchlist
  Future<void> addToWatchlist(TrailerModel trailer) async {
    // Check if trailer is already in watchlist
    if (!_watchlist.any((t) => t.id == trailer.id)) {
      _watchlist.add(trailer);
      await _saveWatchlist();
      notifyListeners();
    }
  }

  /// Remove trailer from watchlist
  Future<void> removeFromWatchlist(String trailerId) async {
    _watchlist.removeWhere((trailer) => trailer.id == trailerId);
    await _saveWatchlist();
    notifyListeners();
  }

  /// Check if trailer is in watchlist
  bool isInWatchlist(String trailerId) {
    return _watchlist.any((trailer) => trailer.id == trailerId);
  }

  /// Add trailer to watched history
  Future<void> addToWatchedHistory(TrailerModel trailer) async {
    // Check if already in history
    if (!_watchedHistory.any((t) => t.id == trailer.id)) {
      _watchedHistory.insert(0, trailer); // Add to the beginning (most recent)

      // Keep only last 100 items
      if (_watchedHistory.length > 100) {
        _watchedHistory = _watchedHistory.sublist(0, 100);
      }

      await _saveWatchedHistory();
      notifyListeners();
    }
  }

  /// Clear watched history
  Future<void> clearWatchedHistory() async {
    _watchedHistory.clear();
    await _saveWatchedHistory();
    notifyListeners();
  }

  /// Remove item from watched history
  Future<void> removeFromWatchedHistory(String trailerId) async {
    _watchedHistory.removeWhere((trailer) => trailer.id == trailerId);
    await _saveWatchedHistory();
    notifyListeners();
  }

  /// Clear entire watchlist
  Future<void> clearWatchlist() async {
    _watchlist.clear();
    await _saveWatchlist();
    notifyListeners();
  }

  /// Get trailer from watchlist by ID
  TrailerModel? getTrailerFromWatchlist(String trailerId) {
    try {
      return _watchlist.firstWhere((trailer) => trailer.id == trailerId);
    } catch (e) {
      return null;
    }
  }
}
