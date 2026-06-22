import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Profile Screen
/// Displays user profile, settings, and preferences

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize theme provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThemeProvider>().initialize();
      context.read<NotificationProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),

            const Divider(height: 32),

            // Stats Section
            _buildStatsSection(),

            const Divider(height: 32),

            // Theme Settings
            _buildThemeSettings(),

            const Divider(height: 32),

            // Notification Settings
            _buildNotificationSettings(),

            const Divider(height: 32),

            // App Information
            _buildAppInfo(),

            const SizedBox(height: AppTheme.paddingLg),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: '/profile'),
    );
  }

  /// Build profile header
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingLg),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor,
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.paddingMd),

          // User Name
          Text(
            'TrailerHub User',
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          // Email
          Text(
            'user@trailerhub.app',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  /// Build stats section
  Widget _buildStatsSection() {
    return Consumer<WatchlistProvider>(
      builder: (context, watchlistProvider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Watchlist',
                watchlistProvider.watchlistCount.toString(),
                Icons.bookmark,
              ),
              _buildStatCard(
                'Watched',
                watchlistProvider.watchedCount.toString(),
                Icons.history,
              ),
              _buildStatCard(
                'Favorite',
                watchlistProvider.watchlistCount.toString(),
                Icons.favorite,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build stat card
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  /// Build theme settings
  Widget _buildThemeSettings() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Display Settings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.paddingMd),

              // Dark Mode Toggle
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
                ),
                padding: const EdgeInsets.all(AppTheme.paddingMd),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          themeProvider.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: AppTheme.paddingMd),
                        Text(
                          'Dark Mode',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.setDarkMode(value);
                      },
                      activeThumbColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build notification settings
  Widget _buildNotificationSettings() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.paddingMd),

              // Enable all notifications
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
                ),
                padding: const EdgeInsets.all(AppTheme.paddingMd),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications, color: AppTheme.primaryColor),
                        const SizedBox(width: AppTheme.paddingMd),
                        Text(
                          'All Notifications',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    Switch(
                      value: notificationProvider.notificationsEnabled,
                      onChanged: (value) {
                        notificationProvider.toggleNotifications();
                      },
                      activeThumbColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.paddingMd),

              // New Trailers
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
                ),
                padding: const EdgeInsets.all(AppTheme.paddingMd),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.new_releases, color: AppTheme.primaryColor),
                        const SizedBox(width: AppTheme.paddingMd),
                        Text(
                          'New Trailers',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    Switch(
                      value: notificationProvider.newTrailerNotifications,
                      onChanged: (value) {
                        notificationProvider.toggleNewTrailerNotifications();
                      },
                      activeThumbColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.paddingMd),

              // Trending Notifications
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
                ),
                padding: const EdgeInsets.all(AppTheme.paddingMd),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.trending_up, color: AppTheme.primaryColor),
                        const SizedBox(width: AppTheme.paddingMd),
                        Text(
                          'Trending',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    Switch(
                      value: notificationProvider.trendingNotifications,
                      onChanged: (value) {
                        notificationProvider.toggleTrendingNotifications();
                      },
                      activeThumbColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.paddingMd),

              // Watchlist Reminders
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
                ),
                padding: const EdgeInsets.all(AppTheme.paddingMd),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bookmark, color: AppTheme.primaryColor),
                        const SizedBox(width: AppTheme.paddingMd),
                        Text(
                          'Watchlist Reminders',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    Switch(
                      value: notificationProvider.watchlistReminders,
                      onChanged: (value) {
                        notificationProvider.toggleWatchlistReminders();
                      },
                      activeThumbColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build app info
  Widget _buildAppInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppTheme.paddingMd),

          // App Version
          _buildInfoTile(
            'App Version',
            AppConstants.appVersion,
            Icons.info_outline,
          ),
          const SizedBox(height: AppTheme.paddingMd),

          // App Description
          _buildInfoTile(
            'About TrailerHub',
            AppConstants.appDescription,
            Icons.movie_outlined,
          ),
          const SizedBox(height: AppTheme.paddingMd),

          // Feedback Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showFeedbackDialog();
              },
              icon: const Icon(Icons.feedback_outlined),
              label: const Text('Send Feedback'),
            ),
          ),
          const SizedBox(height: AppTheme.paddingMd),

          // About Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showAboutDialog();
              },
              icon: const Icon(Icons.help_outline),
              label: const Text('Help & Support'),
            ),
          ),
        ],
      ),
    );
  }

  /// Build info tile
  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
      ),
      padding: const EdgeInsets.all(AppTheme.paddingMd),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: AppTheme.paddingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Show feedback dialog
  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Feedback'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Thank you for using TrailerHub!'),
              SizedBox(height: 16),
              Text('Your feedback helps us improve the app.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feedback sent! Thank you.'),
                  ),
                );
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  /// Show about dialog
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationLegalese: '© 2024 TrailerHub. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'TrailerHub is your ultimate destination for movie and TV show trailers. '
          'Discover new releases, trending content, and manage your watchlist.',
        ),
      ],
    );
  }
}
