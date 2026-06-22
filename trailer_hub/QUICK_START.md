# TrailerHub - Quick Start Guide

## 📋 Project Overview

**TrailerHub** is a production-ready Flutter application featuring:
- Modern Material 3 UI with light/dark theme support
- Clean Architecture with Provider state management
- RESTful API integration with Dio
- Local data persistence with SharedPreferences
- Comprehensive error handling and loading states

## 🚀 Quick Setup (5 minutes)

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Update API Configuration
Open `lib/core/constants/app_constants.dart` and update:
```dart
static const String baseUrl = 'https://your-api-url.com/api/v1';
static const String apiKey = 'your_api_key_here';
```

### Step 3: Run the App
```bash
flutter run
```

## 📂 File Structure at a Glance

```
lib/
├── main.dart                    # Entry point with MultiProvider setup
├── core/
│   ├── constants/app_constants.dart       # API URLs, storage keys
│   └── theme/app_theme.dart              # Light & dark themes
├── models/
│   ├── trailer_model.dart       # Trailer data + utility methods
│   └── category_model.dart      # Category data
├── services/
│   └── api_service.dart         # All API calls (Dio)
├── providers/                   # State Management (Provider)
│   ├── trailer_provider.dart    # Trailer data state
│   ├── category_provider.dart   # Category state
│   ├── watchlist_provider.dart  # Local watchlist + history
│   ├── theme_provider.dart      # Dark/light mode
│   └── notification_provider.dart # Notification settings
├── navigation/
│   └── app_router.dart          # GoRouter route definitions
├── screens/                     # UI Screens
│   ├── home/home_screen.dart
│   ├── trending/trending_screen.dart
│   ├── categories/categories_screen.dart
│   ├── watchlist/watchlist_screen.dart
│   └── profile/profile_screen.dart
└── widgets/                     # Reusable components
    ├── trailer_card.dart
    ├── featured_carousel.dart
    ├── category_chip.dart
    ├── bottom_nav_bar.dart
    └── common_widgets.dart
```

## 🎯 Key Files Explained

### 1. **main.dart** - App Entry Point
- Initializes all providers
- Sets up MultiProvider
- Configures theme and routing
- Handles async initialization

### 2. **app_router.dart** - Navigation
All routes defined here:
- `/home` - Home Screen
- `/trending` - Trending Screen
- `/categories` - Categories Screen
- `/watchlist` - Watchlist Screen
- `/profile` - Profile Screen

Usage:
```dart
AppRouter.goHome(context);
AppRouter.goTrending(context);
// etc...
```

### 3. **api_service.dart** - API Calls
Contains all API methods:
```dart
// Example usage
final apiService = ApiService();
final trailers = await apiService.getTrendingTrailers();
final searchResults = await apiService.searchTrailers(query: 'avatar');
```

### 4. **Providers** - State Management
Each provider manages specific domain:

```dart
// In any screen
final trailers = context.read<TrailerProvider>().trendingTrailers;
final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
```

### 5. **Models** - Data Classes
Self-contained with utilities:
```dart
// Example
final trailer = TrailerModel.fromJson(json);
print(trailer.formattedDuration);  // "02:30"
print(trailer.formattedViews);     // "1.2M"
print(trailer.ratingDisplay);      // "⭐ 8.5"
```

## 🎨 Customization

### Change Primary Color
In `lib/core/theme/app_theme.dart`:
```dart
static const Color primaryColor = Color(0xFF6366F1); // Change this
```

### Add New Route
In `lib/navigation/app_router.dart`:
```dart
GoRoute(
  path: '/new-screen',
  name: 'new_screen',
  builder: (context, state) => const NewScreen(),
),
```

### Add New Provider
1. Create file: `lib/providers/new_provider.dart`
2. Extend `ChangeNotifier`
3. Add to `main.dart` MultiProvider list

## 📱 Screen Hierarchy

```
BottomNavBar (Navigation Hub)
├── Home Screen
│   ├── Featured Carousel
│   ├── Trending Section
│   ├── Upcoming Section
│   └── Recently Added Section
├── Trending Screen
│   └── Grid of trending trailers
├── Categories Screen
│   ├── Category Chips (horizontal scroll)
│   └── Grid of category trailers
├── Watchlist Screen
│   ├── Saved Trailers Tab
│   └── Watched History Tab
└── Profile Screen
    ├── User Stats
    ├── Display Settings (Dark Mode)
    ├── Notification Settings
    └── About App
```

## 🔄 Data Flow

### Loading Trailers Example
```
Home Screen
  ↓
context.read<TrailerProvider>()
  ↓
TrailerProvider.loadTrendingTrailers()
  ↓
ApiService.getTrendingTrailers()
  ↓
Dio HTTP Request to Backend
  ↓
Response → TrailerModel.fromJson()
  ↓
notifyListeners() → Widget Rebuilds
```

## 💾 Local Storage Keys

All keys defined in `app_constants.dart`:
```dart
'watchlist'              // Saved trailers
'watched_history'       // Watched trailers
'dark_mode'             // Theme preference
'notifications_enabled' // Notification settings
```

## 🧪 Testing Locally

### Without Backend
Use mock data in providers for testing:
```dart
// In trailer_provider.dart, add test data
_trendingTrailers = [
  TrailerModel(
    id: '1',
    title: 'Test Trailer',
    // ... other fields
  ),
];
```

### With Backend
1. Set up your backend API
2. Update `baseUrl` in `app_constants.dart`
3. Ensure API returns correct JSON format
4. Test each endpoint separately

## 🐛 Debugging Tips

### Enable Dio Logging
In `api_service.dart` constructor, uncomment:
```dart
// _dio.interceptors.add(LogInterceptor(...));
```

### Watch Provider Changes
```dart
// In any screen
context.watch<TrailerProvider>(); // Rebuilds on changes
```

### Check Local Storage
```dart
// Add this in main.dart to debug
final prefs = await SharedPreferences.getInstance();
print(prefs.getKeys());
```

## 📦 Adding New Packages

```bash
flutter pub add package_name
flutter pub get
```

Then import in files:
```dart
import 'package:package_name/package_name.dart';
```

## 🚀 Build for Release

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## ⚠️ Common Issues & Solutions

### Issue: API Not Responding
**Solution**: 
- Check `baseUrl` in `app_constants.dart`
- Verify API is running
- Check internet connection

### Issue: Images Not Loading
**Solution**:
- Verify image URLs are correct
- Check network permissions in AndroidManifest.xml
- Add to Info.plist for iOS if using HTTP

### Issue: Watchlist Not Persisting
**Solution**:
- Ensure `WatchlistProvider.initialize()` is called in `main()`
- Check SharedPreferences is not cleared

### Issue: Dark Mode Not Working
**Solution**:
- Ensure `ThemeProvider.initialize()` is called in `main()`
- Check `themeMode` is properly configured

## 📚 Next Steps

1. **Connect Real API**: Update API endpoints and test
2. **Add Authentication**: Implement user login/signup
3. **Enhance Features**: Add reviews, ratings, recommendations
4. **Optimize Performance**: Profile app and optimize hot paths
5. **Deploy**: Follow platform-specific deployment guides

## 🔗 Useful Links

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Go Router](https://pub.dev/packages/go_router)
- [Dio Package](https://pub.dev/packages/dio)
- [Material 3 Design](https://m3.material.io/)

---

**Happy coding! 🚀**

For detailed information, see `IMPLEMENTATION_GUIDE.md`
