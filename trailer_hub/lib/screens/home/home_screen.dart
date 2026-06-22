import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/trailer_model.dart';
import '../../providers/trailer_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../widgets/featured_carousel.dart';
import '../../widgets/trailer_card.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../core/theme/app_theme.dart';
import '../../navigation/app_router.dart';

/// Home Screen
/// Main screen displaying featured trailers, trending, upcoming, and recently added

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Load initial data when screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// Load all data for home screen
  Future<void> _loadData() async{
    final trailerProvider = context.read<TrailerProvider>();
    trailerProvider.loadTrendingTrailers();
    trailerProvider.loadUpcomingReleases();
    trailerProvider.loadRecentlyAdded();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrailerHub'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      body: Consumer<TrailerProvider>(
        builder: (context, trailerProvider, _) {
          return RefreshIndicator(
            onRefresh: () async {
              await _loadData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Search Bar
                  if (_isSearching)
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.paddingMd),
                      child: _buildSearchBar(trailerProvider),
                    ),

                  // Featured Carousel
                  FeaturedCarousel(
                    trailers: trailerProvider.trendingTrailers.take(5).toList(),
                    onTrailerTap: (trailer) {
                      // Handle trailer tap
                      _showTrailerDetails(context, trailer);
                    },
                    isLoading: trailerProvider.isLoadingTrending,
                  ),

                  // Trending Today Section
                  SectionHeader(
                    title: 'Trending Today',
                    onSeeAll: () {
                      AppRouter.goTrending(context);
                    },
                  ),
                  _buildTrailerList(
                    trailerProvider.trendingTrailers.take(10).toList(),
                    trailerProvider.isLoadingTrending,
                  ),

                  // Upcoming Releases Section
                  SectionHeader(
                    title: 'Upcoming Releases',
                    onSeeAll: () {},
                  ),
                  _buildTrailerList(
                    trailerProvider.upcomingReleases.take(10).toList(),
                    trailerProvider.isLoadingUpcoming,
                  ),

                  // Recently Added Section
                  SectionHeader(
                    title: 'Recently Added',
                    onSeeAll: () {},
                  ),
                  _buildTrailerList(
                    trailerProvider.recentlyAdded.take(10).toList(),
                    trailerProvider.isLoadingRecent,
                  ),

                  const SizedBox(height: AppTheme.paddingLg),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: '/home'),
    );
  }

  /// Build search bar
  Widget _buildSearchBar(TrailerProvider trailerProvider) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search trailers...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  trailerProvider.clearSearch();
                  setState(() {});
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        ),
      ),
      onChanged: (value) {
        setState(() {});
        trailerProvider.searchTrailers(value);
      },
      onSubmitted: (value) {
        trailerProvider.searchTrailers(value);
      },
    );
  }

  /// Build trailer list (horizontal scroll)
  Widget _buildTrailerList(List<TrailerModel> trailers, bool isLoading) {
    if (isLoading) {
      return SizedBox(
        height: 200,
        child: LoadingIndicator(
          message: 'Loading...',
          size: 40,
        ),
      );
    }

    if (trailers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingMd),
        child: EmptyStateWidget(
          title: 'No trailers found',
          icon: Icons.movie_outlined,
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMd),
        itemCount: trailers.length,
        itemBuilder: (context, index) {
          final trailer = trailers[index];
          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.paddingMd),
            child: SizedBox(
              width: 150,
              child: Consumer<WatchlistProvider>(
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
              ),
            ),
          );
        },
      ),
    );
  }

  /// Show trailer details (bottom sheet or dialog)
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
                    // Title
                    Text(
                      trailer.title,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: AppTheme.paddingMd),

                    // Rating and Views
                    Row(
                      children: [
                        Chip(
                          label: Text('⭐ ${trailer.rating}'),
                          backgroundColor: Colors.amber.withValues(alpha: 0.3),
                        ),
                        const SizedBox(width: AppTheme.paddingMd),
                        Chip(
                          label: Text('👁️ ${trailer.formattedViews}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingMd),

                    // Description
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppTheme.paddingSm),
                    Text(
                      trailer.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppTheme.paddingLg),

                    // Details
                    _buildDetailRow(context, 'Category', trailer.category),
                    _buildDetailRow(context, 'Language', trailer.language),
                    _buildDetailRow(context, 'Duration', trailer.formattedDuration),
                    _buildDetailRow(context, 'Production', trailer.productionHouse),
                    const SizedBox(height: AppTheme.paddingLg),

                    // Genres
                    if (trailer.genres.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Genres',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppTheme.paddingSm),
                          Wrap(
                            spacing: 8,
                            children: trailer.genres
                                .map(
                                  (genre) => Chip(
                                    label: Text(genre),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: AppTheme.paddingLg),
                        ],
                      ),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Build detail row
  Widget _buildDetailRow(BuildContext context,String label, String value) {
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
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
