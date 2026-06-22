import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// Theme Provider
/// Manages theme settings (light/dark mode) using Provider pattern

class ThemeProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isDarkMode = false;

  // Getters
  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Initialize the theme provider
  /// Load saved theme preference from SharedPreferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool(AppConstants.darkModeKey) ?? false;
    notifyListeners();
  }

  /// Toggle dark mode
  /// Switches between light and dark theme and saves preference
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(AppConstants.darkModeKey, _isDarkMode);
    notifyListeners();
  }

  /// Set dark mode explicitly
  /// Set dark mode to a specific value and saves preference
  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    await _prefs.setBool(AppConstants.darkModeKey, _isDarkMode);
    notifyListeners();
  }
}
