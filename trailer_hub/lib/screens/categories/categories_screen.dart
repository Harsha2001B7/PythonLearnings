import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/trailer_model.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/trailer_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/trailer_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../core/theme/app_theme.dart';

/// Categories Screen
/// Displays all categories and trailers filtered by selected category

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? _selectedCategory;
  List<TrailerModel> _categoryTrailers = [];
  bool _isLoadingTrailers = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  /// Load trailers for selected category
  Future<void> _loadCategoryTrailers(String category) async {
    setState(() {
      _isLoadingTrailers = true;
    });

    try {
      final trailers = await _apiService.getTrailersByCategory(
        category: category,
      );
      setState(() {
        _categoryTrailers = trailers;
        _isLoadingTrailers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTrailers = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading trailers: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Categories List
          Consumer<CategoryProvider>(
            builder: (context, categoryProvider, _) {
              if (categoryProvider.isLoading) {
                return SizedBox(
                  height: 60,
                  child: LoadingIndicator(size: 30),
                );
              }

              return SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingMd,
                    vertical: AppTheme.paddingSm,
                  ),
                  itemCount: categoryProvider.categories.length,
                  itemBuilder: (context, index) {
                    final category = categoryProvider.categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: AppTheme.paddingMd),
                      child: CategoryChip(
                        label: category.name,
                        isSelected: _selectedCategory == category.name,
                        onTap: () {
                          setState(() {
                            _selectedCategory = category.name;
                          });
                          _loadCategoryTrailers(category.name.toLowerCase());
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Trailers Grid
          Expanded(
            child: _buildTrailersGrid(),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: '/categories'),
    );
  }

  /// Build trailers grid
  Widget _buildTrailersGrid() {
    if (_selectedCategory == null) {
      return EmptyStateWidget(
        title: 'Select a Category',
        subtitle: 'Choose a category to see trailers',
        icon: Icons.category_outlined,
      );
    }

    if (_isLoadingTrailers) {
      return LoadingIndicator(message: 'Loading trailers...');
    }

    if (_categoryTrailers.isEmpty) {
      return EmptyStateWidget(
        title: 'No Trailers Found',
        subtitle: 'No trailers available in this category',
        icon: Icons.movie_outlined,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.paddingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppTheme.paddingMd,
        mainAxisSpacing: AppTheme.paddingMd,
      ),
      itemCount: _categoryTrailers.length,
      itemBuilder: (context, index) {
        final trailer = _categoryTrailers[index];

        return Consumer<WatchlistProvider>(
          builder: (context, watchlistProvider, _) {
            return TrailerCard(
              trailer: trailer,
              isFavorite: watchlistProvider.isInWatchlist(trailer.id),
              onTap: () {
                _showTrailerDetails(context, trailer);
              },
              onFavoritePressed: () {
                _toggleWatchlist(trailer, context);
              },
            );
          },
        );
      },
    );
  }

  /// Show trailer details
  void _showTrailerDetails(BuildContext context, TrailerModel trailer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trailer.title,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: AppTheme.paddingMd),
                    Text(
                      trailer.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppTheme.paddingLg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rating: ⭐ ${trailer.rating}'),
                        Text('Views: 👁️ ${trailer.formattedViews}'),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingLg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _toggleWatchlist(trailer, context);
                        },
                        icon: Consumer<WatchlistProvider>(
                          builder: (context, watchlistProvider, _) {
                            return Icon(
                              watchlistProvider.isInWatchlist(trailer.id)
                                  ? Icons.check
                                  : Icons.add,
                            );
                          },
                        ),
                        label: const Text('Add to Watchlist'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Toggle watchlist status
  void _toggleWatchlist(TrailerModel trailer, BuildContext context) {
    final watchlistProvider = context.read<WatchlistProvider>();
    if (watchlistProvider.isInWatchlist(trailer.id)) {
      watchlistProvider.removeFromWatchlist(trailer.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from watchlist')),
      );
    } else {
      watchlistProvider.addToWatchlist(trailer);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to watchlist')),
      );
    }
  }
}
