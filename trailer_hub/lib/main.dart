import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation/app_router.dart';
import 'services/api_service.dart';
import 'providers/trailer_provider.dart';
import 'providers/category_provider.dart';
import 'providers/watchlist_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';
import 'core/theme/app_theme.dart';

/// Main Entry Point of TrailerHub Application
/// 
/// This is the main.dart file that initializes the app with all providers
/// and sets up the material app configuration.

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize providers that require async operations
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  final watchlistProvider = WatchlistProvider();
  await watchlistProvider.initialize();

  final notificationProvider = NotificationProvider();
  await notificationProvider.initialize();

  runApp(
    const TrailerHubApp(),
  );
}

/// Main Application Widget
/// Sets up all providers using the Provider package

class TrailerHubApp extends StatelessWidget {
  const TrailerHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create API service instance
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        // API Service Provider
        Provider<ApiService>(
          create: (_) => apiService,
        ),

        // Trailer Provider - manages trailer data
        ChangeNotifierProvider<TrailerProvider>(
          create: (context) => TrailerProvider(
            apiService: context.read<ApiService>(),
          ),
        ),

        // Category Provider - manages category data
        ChangeNotifierProvider<CategoryProvider>(
          create: (context) => CategoryProvider(
            apiService: context.read<ApiService>(),
          ),
        ),

        // Watchlist Provider - manages watchlist and history
        ChangeNotifierProvider<WatchlistProvider>(
          create: (_) => WatchlistProvider(),
        ),

        // Theme Provider - manages dark/light mode
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),

        // Notification Provider - manages notification settings
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
      ],
      child: Consumer2<ThemeProvider, NotificationProvider>(
        builder: (context, themeProvider, notificationProvider, _) {
          return MaterialApp.router(
            // App Configuration
            title: 'TrailerHub',
            debugShowCheckedModeBanner: false,

            // Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Router Configuration
            routerConfig: AppRouter.router,

            // Localization
            supportedLocales: const [
              Locale('en', 'US'),
            ],
          );
        },
      ),
    );
  }
}
