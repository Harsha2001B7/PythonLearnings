import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/trailer_model.dart';
import '../../providers/watchlist_provider.dart';
import '../../widgets/trailer_card.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../core/theme/app_theme.dart';

/// Watchlist Screen
/// Displays saved trailers and watched history

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize watchlist on screen creation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WatchlistProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Saved'),
            Tab(text: 'Watched'),
          ],
        ),
      ),
      body: Consumer<WatchlistProvider>(
        builder: (context, watchlistProvider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              // Saved Watchlist Tab
              _buildWatchlistTab(watchlistProvider),

              // Watched History Tab
              _buildWatchedHistoryTab(watchlistProvider),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: '/watchlist'),
    );
  }

  /// Build watchlist tab
  Widget _buildWatchlistTab(WatchlistProvider watchlistProvider) {
    if (watchlistProvider.watchlist.isEmpty) {
      return EmptyStateWidget(
        title: 'Your Watchlist is Empty',
        subtitle: 'Save trailers to watch later',
        icon: Icons.bookmark_outline,
        actionLabel: 'Browse Trailers',
        onAction: () {
          // Can navigate to home or categories
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh watchlist
        return Future.delayed(const Duration(milliseconds: 500));
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(AppTheme.paddingMd),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: AppTheme.paddingMd,
          mainAxisSpacing: AppTheme.paddingMd,
        ),
        itemCount: watchlistProvider.watchlist.length,
        itemBuilder: (context, index) {
          final trailer = watchlistProvider.watchlist[index];

          return Stack(
            children: [
              TrailerCard(
                trailer: trailer,
                isFavorite: true,
                onTap: () {
                  _showTrailerDetails(context, trailer, watchlistProvider);
                },
                onFavoritePressed: () {
                  watchlistProvider.removeFromWatchlist(trailer.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Removed from watchlist')),
                  );
                },
              ),
              // Delete button
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    watchlistProvider.removeFromWatchlist(trailer.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Removed from watchlist')),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build watched history tab
  Widget _buildWatchedHistoryTab(WatchlistProvider watchlistProvider) {
    if (watchlistProvider.watchedHistory.isEmpty) {
      return EmptyStateWidget(
        title: 'No Watch History',
        subtitle: 'Your watched trailers will appear here',
        icon: Icons.history,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        return Future.delayed(const Duration(milliseconds: 500));
      },
      child: Column(
        children: [
          // Clear History Button
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMd),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showClearHistoryDialog(context, watchlistProvider);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear History'),
              ),
            ),
          ),

          // History List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.paddingMd),
              itemCount: watchlistProvider.watchedHistory.length,
              itemBuilder: (context, index) {
                final trailer = watchlistProvider.watchedHistory[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.paddingMd),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusSm),
                        image: DecorationImage(
                          image: NetworkImage(trailer.thumbnailUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      trailer.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      trailer.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        watchlistProvider.removeFromWatchedHistory(trailer.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Removed from history'),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      _showTrailerDetails(
                        context,
                        trailer,
                        watchlistProvider,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Show trailer details
  void _showTrailerDetails(
    BuildContext context,
    TrailerModel trailer,
    WatchlistProvider watchlistProvider,
  ) {
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
                        Text('⭐ ${trailer.rating}'),
                        Text('👁️ ${trailer.formattedViews}'),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingLg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          watchlistProvider.removeFromWatchlist(trailer.id);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Removed from watchlist'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Remove from Watchlist'),
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

  /// Show clear history confirmation dialog
  void _showClearHistoryDialog(
    BuildContext context,
    WatchlistProvider watchlistProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear History?'),
          content: const Text(
            'Are you sure you want to clear your entire watch history? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                watchlistProvider.clearWatchedHistory();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History cleared')),
                );
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
