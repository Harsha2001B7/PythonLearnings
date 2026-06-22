# TrailerHub - Movie & TV Show Trailer App

A modern Flutter mobile application that brings the ultimate trailer experience inspired by TrailerBaaz. TrailerHub allows users to discover trending trailers, browse by categories, manage their watchlist, and customize their experience with dark mode and notification settings.

## 📱 Features

### Home Screen
- **Featured Carousel**: Eye-catching carousel of featured trailers with auto-play
- **Search Functionality**: Real-time search across all trailers
- **Trending Today**: See what's trending right now
- **Upcoming Releases**: Discover upcoming trailer releases
- **Recently Added**: Stay updated with newly added trailers

### Trending Screen
- **Top Trending Trailers**: Comprehensive list of trending content
- **Popularity Ranking**: Sorted by views and popularity
- **Sorting Options**: Sort by views, rating, or recent
- **Infinite Scroll**: Load more trailers as you scroll

### Categories Screen
- **Multi-Category Support**:
  - Hollywood
  - Bollywood
  - Telugu
  - Tamil
  - Korean
  - Netflix
  - Amazon Prime
  - Disney+
- **Category-Specific Trailers**: Browse trailers by your favorite category

### Watchlist Screen
- **Save Trailers**: Add trailers to your watchlist for later
- **Watched History**: Track trailers you've watched
- **Easy Management**: Remove items with a single tap
- **Clear History**: Clear entire watch history

### Profile Screen
- **User Statistics**: View your watchlist count, watched count, and favorites
- **Display Settings**: Toggle dark/light mode
- **Notification Control**: Manage notification preferences
  - All Notifications
  - New Trailer Alerts
  - Trending Notifications
  - Watchlist Reminders
- **App Information**: View app version and description
- **Feedback**: Send feedback directly from the app

## 🏗️ Architecture

The app follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── constants/
│   │   └── app_constants.dart        # App-wide constants
│   └── theme/
│       └── app_theme.dart            # Theme configuration
├── models/
│   ├── trailer_model.dart            # Trailer data model
│   └── category_model.dart           # Category data model
├── services/
│   └── api_service.dart              # API communication
├── providers/                         # State management (Provider)
│   ├── trailer_provider.dart
│   ├── category_provider.dart
│   ├── watchlist_provider.dart
│   ├── theme_provider.dart
│   └── notification_provider.dart
├── navigation/
│   └── app_router.dart               # Go Router navigation setup
├── screens/
│   ├── home/
│   │   └── home_screen.dart
│   ├── trending/
│   │   └── trending_screen.dart
│   ├── categories/
│   │   └── categories_screen.dart
│   ├── watchlist/
│   │   └── watchlist_screen.dart
│   └── profile/
│       └── profile_screen.dart
└── widgets/
    ├── trailer_card.dart
    ├── featured_carousel.dart
    ├── category_chip.dart
    ├── bottom_nav_bar.dart
    └── common_widgets.dart
```

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Networking**: Dio
- **Navigation**: Go Router
- **Local Storage**: Shared Preferences
- **Image Caching**: Cached Network Image
- **Carousel**: Carousel Slider
- **Grid Layouts**: Flutter Staggered Grid View

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.5
  
  # HTTP Client
  dio: ^5.8.0
  
  # Navigation
  go_router: ^16.0.0
  
  # UI Components
  cached_network_image: ^3.4.1
  carousel_slider: ^5.1.1
  flutter_staggered_grid_view: ^0.7.0
  
  # Local Storage
  shared_preferences: ^2.5.3
  
  # Icons
  cupertino_icons: ^1.0.8
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.12.2 or higher
- Dart SDK 3.12.2 or higher
- An IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd trailer_hub
   ```

2. **Get dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate platform files** (if needed):
   ```bash
   flutter pub get
   flutter create .
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

   Or run on a specific device:
   ```bash
   flutter run -d <device-id>
   ```

### Configuration

1. **API Configuration**: Update the API URL in `lib/core/constants/app_constants.dart`:
   ```dart
   static const String baseUrl = 'https://your-api-url.com/api/v1';
   static const String apiKey = 'your_api_key_here';
   ```

2. **Theme Customization**: Modify colors in `lib/core/theme/app_theme.dart`:
   ```dart
   static const Color primaryColor = Color(0xFF6366F1);
   static const Color secondaryColor = Color(0xFF8B5CF6);
   ```

## 📱 Usage

### Main Navigation
- **Bottom Navigation Bar**: Navigate between 5 main sections (Home, Trending, Categories, Watchlist, Profile)
- **Search**: Tap the search icon on the Home screen to search for trailers
- **Watchlist**: Add trailers to your watchlist from any screen

### Features Usage

**Add to Watchlist**:
1. Tap the heart icon on any trailer card
2. Or tap the trailer to see details and add from there

**View Trailer Details**:
1. Tap on any trailer card
2. A bottom sheet will appear with full trailer information
3. View rating, duration, genres, and production details

**Browse by Category**:
1. Go to Categories screen
2. Select a category chip
3. Browse trailers in that category

**Manage Watchlist**:
1. Go to Watchlist screen
2. Use tabs to switch between "Saved" and "Watched"
3. Swipe or tap to remove items

**Settings**:
1. Go to Profile screen
2. Toggle dark mode
3. Manage notification preferences

## 🎨 Theme Support

The app includes built-in **Material 3** design with:
- Light theme (default)
- Dark theme (toggle in Profile)
- Responsive layouts
- Smooth animations and transitions

### Custom Theme Colors
- **Primary**: Indigo (#6366F1)
- **Secondary**: Purple (#8B5CF6)
- **Accent**: Pink (#EC4899)
- **Error**: Red (#EF4444)
- **Success**: Green (#22C55E)

## 📡 API Integration

The app consumes trailer APIs with the following endpoints:

- `GET /trailers/trending` - Trending trailers
- `GET /trailers/upcoming` - Upcoming releases
- `GET /trailers/recent` - Recently added
- `GET /categories` - All categories
- `GET /categories/{category}/trailers` - Trailers by category
- `GET /trailers/search?q={query}` - Search trailers
- `GET /trailers/{id}` - Single trailer details

**Note**: Replace the API base URL with your actual backend URL.

## 💾 Local Storage

The app uses **SharedPreferences** to persist:
- **Watchlist**: Saved trailers (persistent across sessions)
- **Watched History**: Recently watched trailers (last 100)
- **Theme Preference**: Dark/Light mode setting
- **Notification Settings**: User notification preferences

## 🔄 State Management

Using **Provider** package for state management:

1. **TrailerProvider**: Manages trailer data, pagination, and search
2. **CategoryProvider**: Manages category data with fallback options
3. **WatchlistProvider**: Manages watchlist and history with local persistence
4. **ThemeProvider**: Manages theme state
5. **NotificationProvider**: Manages notification settings

## 🐛 Error Handling

The app includes comprehensive error handling:
- Loading states with spinners
- Error messages with retry buttons
- Empty states with helpful prompts
- Network error handling
- API timeout management (30 seconds default)

## 📝 Code Structure

### Models
- **TrailerModel**: Complete trailer information with utility methods
- **CategoryModel**: Category information with metadata

### Providers
- Factory methods for API data transformation
- JSON serialization/deserialization
- Error state management
- Data caching strategies

### Screens
- Responsive layouts for all screen sizes
- Pull-to-refresh functionality
- Infinite scroll pagination
- Modal bottom sheets for details

### Widgets
- Reusable components (TrailerCard, FeaturedCarousel, CategoryChip)
- Common widgets (LoadingIndicator, ErrorWidget, EmptyStateWidget)
- Proper state management integration

## 🎯 Best Practices

- **Clean Code**: Well-organized, commented code throughout
- **Performance**: Image caching, lazy loading, efficient rebuilds
- **UX**: Smooth animations, intuitive navigation, helpful feedback
- **Error Handling**: Graceful degradation with user-friendly messages
- **Scalability**: Modular architecture for easy feature addition
- **Accessibility**: Proper contrast ratios, readable fonts, intuitive layout

## 📚 Dependencies Documentation

- [Provider](https://pub.dev/packages/provider) - State management
- [Dio](https://pub.dev/packages/dio) - HTTP client
- [Go Router](https://pub.dev/packages/go_router) - Navigation
- [Cached Network Image](https://pub.dev/packages/cached_network_image) - Image caching
- [Carousel Slider](https://pub.dev/packages/carousel_slider) - Carousel widget
- [Shared Preferences](https://pub.dev/packages/shared_preferences) - Local storage

## 🤝 Contributing

Feel free to fork this project and submit pull requests for improvements.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔗 API Integration

To integrate with your actual backend:

1. Update `baseUrl` in `app_constants.dart`
2. Update `apiKey` with your authentication token
3. Ensure API responses match the expected JSON format in model classes
4. Test all endpoints before deployment

## 🚨 Important Notes

- API URLs in the code are placeholders. Replace with your actual backend URLs.
- Ensure your API returns data in the format expected by the models.
- Always use HTTPS for production API calls.
- Never commit API keys or sensitive data. Use environment variables instead.

## 📞 Support

For issues or questions:
1. Check the error messages and logs
2. Verify API endpoints are correct
3. Ensure all dependencies are properly installed
4. Check Flutter and Dart versions compatibility

## ✨ Future Enhancements

- User authentication system
- Video playback integration
- Social sharing features
- Advanced filtering and sorting
- Recommendation engine
- Push notifications
- Offline mode with caching
- Multi-language support
- User reviews and ratings

---

**Happy Streaming with TrailerHub! 🎬**
