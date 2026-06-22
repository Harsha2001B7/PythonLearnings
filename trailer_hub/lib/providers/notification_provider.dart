import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// Notification Provider
/// Manages notification settings using Provider pattern and SharedPreferences

class NotificationProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  bool _notificationsEnabled = true;
  bool _newTrailerNotifications = true;
  bool _trendingNotifications = true;
  bool _watchlistReminders = true;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get newTrailerNotifications => _newTrailerNotifications;
  bool get trendingNotifications => _trendingNotifications;
  bool get watchlistReminders => _watchlistReminders;

  /// Initialize notification provider
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadNotificationSettings();
  }

  /// Load notification settings from SharedPreferences
  Future<void> _loadNotificationSettings() async {
    try {
      _notificationsEnabled =
          _prefs.getBool('${AppConstants.notificationsKey}_enabled') ?? true;
      _newTrailerNotifications =
          _prefs.getBool('${AppConstants.notificationsKey}_new_trailers') ?? true;
      _trendingNotifications =
          _prefs.getBool('${AppConstants.notificationsKey}_trending') ?? true;
      _watchlistReminders =
          _prefs.getBool('${AppConstants.notificationsKey}_watchlist') ?? true;
    } catch (e) {
      // Keep default values
    }
    notifyListeners();
  }

  /// Save notification settings
  Future<void> _saveNotificationSettings() async {
    try {
      await _prefs.setBool(
        '${AppConstants.notificationsKey}_enabled',
        _notificationsEnabled,
      );
      await _prefs.setBool(
        '${AppConstants.notificationsKey}_new_trailers',
        _newTrailerNotifications,
      );
      await _prefs.setBool(
        '${AppConstants.notificationsKey}_trending',
        _trendingNotifications,
      );
      await _prefs.setBool(
        '${AppConstants.notificationsKey}_watchlist',
        _watchlistReminders,
      );
    } catch (e) {
      // Handle error
    }
  }

  /// Toggle all notifications
  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    await _saveNotificationSettings();
    notifyListeners();
  }

  /// Toggle new trailer notifications
  Future<void> toggleNewTrailerNotifications() async {
    _newTrailerNotifications = !_newTrailerNotifications;
    await _saveNotificationSettings();
    notifyListeners();
  }

  /// Toggle trending notifications
  Future<void> toggleTrendingNotifications() async {
    _trendingNotifications = !_trendingNotifications;
    await _saveNotificationSettings();
    notifyListeners();
  }

  /// Toggle watchlist reminders
  Future<void> toggleWatchlistReminders() async {
    _watchlistReminders = !_watchlistReminders;
    await _saveNotificationSettings();
    notifyListeners();
  }

  /// Set all notification settings
  Future<void> setNotificationSettings({
    required bool enabled,
    required bool newTrailers,
    required bool trending,
    required bool watchlist,
  }) async {
    _notificationsEnabled = enabled;
    _newTrailerNotifications = newTrailers;
    _trendingNotifications = trending;
    _watchlistReminders = watchlist;
    await _saveNotificationSettings();
    notifyListeners();
  }
}
