import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/trailer_model.dart';
import '../../providers/trailer_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../widgets/trailer_card.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../core/theme/app_theme.dart';

/// Trending Screen
/// Displays trending trailers with sorting and filtering options

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  String _sortBy = 'views'; // views, rating, recent
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrailerProvider>().loadTrendingTrailers();
    });

    // Handle pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Load more trailers
  void _loadMore() {
    context.read<TrailerProvider>().loadTrendingTrailers(isLoadMore: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Trailers'),
        elevation: 0,
        actions: [
          // Sort button
          PopupMenuButton(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'views',
                child: Row(
                  children: [
                    Icon(Icons.visibility),
                    SizedBox(width: 12),
                    Text('By Views'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'rating',
                child: Row(
                  children: [
                    Icon(Icons.star),
                    SizedBox(width: 12),
                    Text('By Rating'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'recent',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today),
                    SizedBox(width: 12),
                    Text('Recent'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<TrailerProvider>(
        builder: (context, trailerProvider, _) {
          if (trailerProvider.isLoadingTrending &&
              trailerProvider.trendingTrailers.isEmpty) {
            return LoadingIndicator(
              message: 'Loading trending trailers...',
            );
          }

          if (trailerProvider.errorMessage != null &&
              trailerProvider.trendingTrailers.isEmpty) {
            return CustomErrorWidget(
              message: trailerProvider.errorMessage ?? 'An error occurred',
              onRetry: () {
                trailerProvider.loadTrendingTrailers();
              },
            );
          }

          if (trailerProvider.trendingTrailers.isEmpty) {
            return EmptyStateWidget(
              title: 'No Trending Trailers',
              subtitle: 'Check back later for trending trailers',
              icon: Icons.trending_up_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await trailerProvider.loadTrendingTrailers();
            },
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppTheme.paddingMd),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: AppTheme.paddingMd,
                mainAxisSpacing: AppTheme.paddingMd,
              ),
              itemCount: trailerProvider.trendingTrailers.length +
                  (trailerProvider.isLoadingTrending ? 1 : 0),
              itemBuilder: (context, index) {
                // Loading indicator at the end
                if (index == trailerProvider.trendingTrailers.length) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final trailer = trailerProvider.trendingTrailers[index];

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
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: '/trending'),
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
                    ElevatedButton.icon(
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
