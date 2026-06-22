import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/category_model.dart';
import '../core/constants/app_constants.dart';

/// Category Provider
/// Manages category data and API calls using Provider pattern

class CategoryProvider extends ChangeNotifier {
  final ApiService apiService;

  // State variables
  List<CategoryModel> _categories = [];
  List<CategoryModel> _predefinedCategories = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CategoryModel> get categories => _categories.isEmpty ? _predefinedCategories : _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CategoryProvider({required this.apiService}) {
    _initializePredefinedCategories();
  }

  /// Initialize predefined categories as fallback
  void _initializePredefinedCategories() {
    _predefinedCategories = AppConstants.categories.map((categoryName) {
      return CategoryModel(
        id: categoryName.toLowerCase().replaceAll(' ', '_'),
        name: categoryName,
        iconUrl: '',
        description: '$categoryName trailers',
        trailerCount: 0,
        createdDate: DateTime.now(),
      );
    }).toList();
  }

  /// Load categories from API
  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final categoriesData = await apiService.getCategories();
      _categories = categoriesData.isNotEmpty ? categoriesData : _predefinedCategories;
      _isLoading = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      // Keep predefined categories as fallback
      _categories = _predefinedCategories;
    }

    notifyListeners();
  }

  /// Get category by name
  CategoryModel? getCategoryByName(String name) {
    try {
      return categories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Refresh categories
  Future<void> refreshCategories() async {
    await loadCategories();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
