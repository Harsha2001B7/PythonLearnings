# 🎬 TrailerHub - Quick Reference Card

## 🚀 Get Started in 3 Steps

### 1️⃣ Install Dependencies
```bash
cd trailer_hub
flutter pub get
```

### 2️⃣ Configure API
Edit `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'https://your-api.com/api/v1';
static const String apiKey = 'your-api-key';
```

### 3️⃣ Run
```bash
flutter run
```

---

## 📱 App Structure

| Screen | Location | Features |
|--------|----------|----------|
| **Home** | `lib/screens/home/` | Carousel, Search, Trending, Upcoming, Recent |
| **Trending** | `lib/screens/trending/` | Sort, Grid, Pagination |
| **Categories** | `lib/screens/categories/` | 8 Categories, Filter |
| **Watchlist** | `lib/screens/watchlist/` | Saved + History, Remove |
| **Profile** | `lib/screens/profile/` | Settings, Theme, Notifications |

---

## 🗂️ Key Directories

```
lib/
├── main.dart              ← App entry point
├── core/
│   ├── constants/        ← API config here
│   └── theme/            ← Themes (light/dark)
├── models/               ← Data classes
├── services/             ← API calls
├── providers/            ← State management
├── navigation/           ← Routing
├── screens/              ← UI screens
└── widgets/              ← Reusable components
```

---

## 🔄 Data Flow

```
Widget (Screen)
    ↓
Consumer<Provider>
    ↓
Provider (State)
    ↓
ApiService (HTTP)
    ↓
Backend API
```

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `QUICK_START.md` | 5-min setup guide |
| `IMPLEMENTATION_GUIDE.md` | Full documentation |
| `API_INTEGRATION.md` | API specs & setup |
| `FILE_STRUCTURE_VERIFICATION.md` | File checklist |
| `PROJECT_COMPLETION_SUMMARY.md` | Feature checklist |

---

## 🎨 Customization

### Change Primary Color
`lib/core/theme/app_theme.dart`:
```dart
static const Color primaryColor = Color(0xFF6366F1);
```

### Add New Screen
1. Create `lib/screens/new_screen/new_screen.dart`
2. Add route in `lib/navigation/app_router.dart`
3. Add navigation in `lib/widgets/bottom_nav_bar.dart`

### Add New API Endpoint
1. Add method to `lib/services/api_service.dart`
2. Add provider logic in `lib/providers/trailer_provider.dart`
3. Call from screen with `context.read<TrailerProvider>()`

---

## 🔐 Authentication

In `api_service.dart`, the API key is sent as:
```
Authorization: Bearer your_api_key_here
```

Update in `app_constants.dart`.

---

## 💾 Local Storage Keys

```dart
'watchlist'           // Saved trailers
'watched_history'     // Watched trailers  
'dark_mode'          // Theme preference
'notifications_enabled' // Notification settings
```

---

## 🎯 Provider Usage

### Read (No rebuild)
```dart
final trailers = context.read<TrailerProvider>().trendingTrailers;
```

### Watch (Rebuilds)
```dart
final trailers = context.watch<TrailerProvider>().trendingTrailers;
```

### In MultiProvider
```dart
Provider<ApiService>(create: (_) => apiService),
ChangeNotifierProvider(create: (_) => ThemeProvider()),
```

---

## 🛠️ Common Commands

```bash
# Clean build
flutter clean

# Get latest dependencies
flutter pub get

# Run on specific device
flutter run -d <device-id>

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release

# Check device list
flutter devices
```

---

## ⚙️ Configuration

### API Timeout
`lib/core/constants/app_constants.dart`:
```dart
static const Duration apiTimeout = Duration(seconds: 30);
```

### Pagination
Default items per page: 20
Change in `app_constants.dart`:
```dart
static const int itemsPerPage = 20;
```

### Categories
Predefined in `app_constants.dart`:
```dart
static const List<String> categories = [
  'Hollywood', 'Bollywood', 'Telugu', 'Tamil',
  'Korean', 'Netflix', 'Amazon Prime', 'Disney+'
];
```

---

## 🐛 Debugging

### Enable API Logging
Uncomment in `api_service.dart`:
```dart
_dio.interceptors.add(LogInterceptor(...));
```

### Watch State Changes
```dart
context.watch<TrailerProvider>(); // Rebuilds on change
```

### Check Local Storage
```dart
final prefs = await SharedPreferences.getInstance();
print(prefs.getKeys()); // Print all keys
```

---

## 📦 Dependencies

```yaml
provider: ^6.1.5              # State management
dio: ^5.8.0                   # HTTP client
go_router: ^16.0.0            # Navigation
cached_network_image: ^3.4.1  # Image caching
carousel_slider: ^5.1.1       # Carousel
flutter_staggered_grid_view   # Grid layouts
shared_preferences: ^2.5.3    # Local storage
```

---

## 🌐 API Endpoints Required

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/trailers/trending` | Trending trailers |
| GET | `/trailers/upcoming` | Upcoming releases |
| GET | `/trailers/recent` | Recently added |
| GET | `/categories` | All categories |
| GET | `/categories/{cat}/trailers` | Category trailers |
| GET | `/trailers/search` | Search trailers |
| GET | `/trailers/{id}` | Trailer details |

---

## ✨ Features Included

✅ 5 Complete Screens  
✅ Provider State Management  
✅ Dio HTTP Client  
✅ GoRouter Navigation  
✅ SharedPreferences Storage  
✅ Material 3 Design  
✅ Dark/Light Theme  
✅ Pagination  
✅ Search  
✅ Error Handling  
✅ Loading States  
✅ Empty States  
✅ Carousel Slider  
✅ Image Caching  

---

## 🚨 Important Notes

⚠️ **Never commit API keys** - Use environment variables  
⚠️ **Always use HTTPS** - Not HTTP  
⚠️ **Test on real device** - Before release  
⚠️ **Update API URL** - In `app_constants.dart`  
⚠️ **Check API format** - Must match model expectations  

---

## 🎯 Common Issues

| Issue | Solution |
|-------|----------|
| API not responding | Check `baseUrl` in `app_constants.dart` |
| Images not loading | Verify URLs are public & HTTPS |
| Dark mode not working | Call `ThemeProvider.initialize()` in `main()` |
| Watchlist not saving | Ensure `WatchlistProvider.initialize()` called |
| Pagination not working | Check API returns data in `data` field |

---

## 🔗 Useful Links

- [Flutter Docs](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Dio Package](https://pub.dev/packages/dio)
- [GoRouter](https://pub.dev/packages/go_router)
- [Material 3](https://m3.material.io/)

---

## 📞 Quick Help

### File Not Found?
Check `FILE_STRUCTURE_VERIFICATION.md`

### How to integrate API?
Read `API_INTEGRATION.md`

### Quick setup?
Follow `QUICK_START.md`

### Full documentation?
See `IMPLEMENTATION_GUIDE.md`

---

**Everything is ready to go! 🚀**

1. Update API configuration
2. Run `flutter pub get`
3. Run `flutter run`
4. Start building!

---

Created: June 22, 2026  
Status: ✅ Complete  
Ready: ✅ Production
