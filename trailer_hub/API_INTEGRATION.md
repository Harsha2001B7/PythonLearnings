# API Integration Guide for TrailerHub

## ⚠️ Important: Dummy Data Configuration

**Current Status**: The app is currently configured with **dummy data** using a placeholder YouTube video.

### Dummy Video Details
- **Title**: Spider-Man: Brand New Day
- **URL**: https://youtu.be/62bIsvRcPv0?si=Vrlr0obZ-oUtpf90
- **Used in**: All 8 dummy trailers across all categories
- **Location**: `lib/services/api_service.dart` (line 12)

### How Dummy Data Works
The app will automatically use dummy data when:
1. API calls fail or connection is unavailable
2. Backend is not configured yet
3. You're testing locally without a backend

This ensures the app works immediately without requiring API setup. Later, you can connect to your real backend API.

## 🔗 Base API Configuration

### Switching from Dummy Data to Real API

When you're ready to connect your real backend:

1. **Update the base URL** in `lib/core/constants/app_constants.dart`:
   ```dart
   static const String baseUrl = 'https://api.yourdomain.com/api/v1';
   ```

2. **Update the API key**:
   ```dart
   static const String apiKey = 'your_actual_api_key_here';
   ```

3. **The app will automatically switch to using your API** instead of dummy data

### Dummy Data Usage
- **When API fails**: Returns dummy trailers with Spider-Man video
- **When searching**: Filters dummy data by title/description
- **When sorting**: Sorts dummy data by views/rating
- **Categories**: Returns predefined categories from constants

To remove dummy data fallback, simply modify the `on DioException catch` blocks in `api_service.dart`

### In `lib/core/constants/app_constants.dart`

```dart
static const String baseUrl = 'https://api.yourdomain.com/api/v1';
static const String apiKey = 'your_api_key_here';
static const Duration apiTimeout = Duration(seconds: 30);
```

Replace with your actual API base URL and API key.

## 📡 API Endpoints Required

### 1. **Get Trending Trailers**
**Endpoint**: `GET /trailers/trending`

**Query Parameters**:
- `page` (int): Page number (default: 1)
- `limit` (int): Items per page (default: 20)

**Response Format**:
```json
{
  "status": "success",
  "data": [
    {
      "id": "1",
      "title": "Avatar: The Way of Water",
      "description": "The continuation of the story begins...",
      "imageUrl": "https://cdn.example.com/avatar.jpg",
      "posterUrl": "https://cdn.example.com/avatar-poster.jpg",
      "thumbnailUrl": "https://cdn.example.com/avatar-thumb.jpg",
      "videoUrl": "https://www.youtube.com/watch?v=...",
      "category": "Hollywood",
      "releaseDate": "2022-12-16",
      "rating": 7.8,
      "views": 1500000,
      "genres": ["Science Fiction", "Adventure", "Fantasy"],
      "language": "English",
      "durationInSeconds": 10920,
      "productionHouse": "20th Century Studios",
      "addedDate": "2022-12-01"
    }
  ]
}
```

### 2. **Get Upcoming Releases**
**Endpoint**: `GET /trailers/upcoming`

**Query Parameters**:
- `page` (int): Page number
- `limit` (int): Items per page

**Response Format**: Same as trending trailers

### 3. **Get Recently Added Trailers**
**Endpoint**: `GET /trailers/recent`

**Query Parameters**:
- `page` (int): Page number
- `limit` (int): Items per page

**Response Format**: Same as trending trailers

### 4. **Get All Categories**
**Endpoint**: `GET /categories`

**Response Format**:
```json
{
  "status": "success",
  "data": [
    {
      "id": "hollywood",
      "name": "Hollywood",
      "iconUrl": "https://cdn.example.com/hollywood-icon.png",
      "description": "Hollywood movies and trailers",
      "trailerCount": 150,
      "createdDate": "2022-01-01"
    },
    {
      "id": "bollywood",
      "name": "Bollywood",
      "iconUrl": "https://cdn.example.com/bollywood-icon.png",
      "description": "Hindi movies and trailers",
      "trailerCount": 200,
      "createdDate": "2022-01-01"
    }
  ]
}
```

### 5. **Get Trailers by Category**
**Endpoint**: `GET /categories/{category}/trailers`

**Path Parameters**:
- `category` (string): Category name (e.g., "hollywood", "bollywood")

**Query Parameters**:
- `page` (int): Page number
- `limit` (int): Items per page

**Response Format**: Same as trending trailers

### 6. **Search Trailers**
**Endpoint**: `GET /trailers/search`

**Query Parameters**:
- `q` (string): Search query (required)
- `page` (int): Page number
- `limit` (int): Items per page

**Response Format**: Same as trending trailers

### 7. **Get Single Trailer Details**
**Endpoint**: `GET /trailers/{id}`

**Path Parameters**:
- `id` (string): Trailer ID

**Response Format**:
```json
{
  "status": "success",
  "data": {
    "id": "1",
    "title": "Avatar: The Way of Water",
    "description": "...",
    "imageUrl": "...",
    "thumbnailUrl": "...",
    "videoUrl": "...",
    "category": "Hollywood",
    "releaseDate": "2022-12-16",
    "rating": 7.8,
    "views": 1500000,
    "genres": ["Science Fiction", "Adventure"],
    "language": "English",
    "durationInSeconds": 10920,
    "productionHouse": "20th Century Studios",
    "addedDate": "2022-12-01"
  }
}
```

### 8. **Get Trailers Sorted by Views**
**Endpoint**: `GET /trailers/trending`

**Query Parameters**:
- `sortBy` (string): "views"
- `order` (string): "desc" for descending
- `page` (int): Page number
- `limit` (int): Items per page

### 9. **Get Top Rated Trailers**
**Endpoint**: `GET /trailers/trending`

**Query Parameters**:
- `sortBy` (string): "rating"
- `order` (string): "desc"
- `page` (int): Page number
- `limit` (int): Items per page

## 📝 API Response Specifications

### Required Fields in Trailer Response

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Unique identifier |
| `title` | string | Yes | Trailer title |
| `description` | string | Yes | Trailer description |
| `imageUrl` | string | Yes | Main image URL |
| `category` | string | Yes | Trailer category |
| `releaseDate` | ISO 8601 string | Yes | Release date |
| `rating` | number | Yes | Rating (0-10) |
| `views` | integer | Yes | View count |
| `language` | string | Yes | Language code |
| `durationInSeconds` | integer | Yes | Duration in seconds |

### Optional Fields in Trailer Response

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `thumbnailUrl` | string | imageUrl | Thumbnail URL |
| `videoUrl` | string | null | Video URL (YouTube link) |
| `genres` | array | [] | Genre list |
| `productionHouse` | string | "Unknown" | Production company |
| `addedDate` | ISO 8601 string | now | When added |

## 🔐 Authentication

### Header-Based Authentication (Recommended)
Add to API requests:
```
Authorization: Bearer <your_api_token>
```

Update in `api_service.dart`:
```dart
BaseOptions(
  baseUrl: AppConstants.baseUrl,
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AppConstants.apiKey}',
  },
)
```

### API Key in Query String
Alternative method (less secure):
```
GET /trailers/trending?apiKey=your_key&page=1
```

## 🧪 Testing Your API

### 1. Test with cURL
```bash
# Get trending trailers
curl -X GET \
  "https://api.yourdomain.com/api/v1/trailers/trending?page=1&limit=10" \
  -H "Authorization: Bearer YOUR_API_KEY"

# Search trailers
curl -X GET \
  "https://api.yourdomain.com/api/v1/trailers/search?q=avatar" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

### 2. Test with Postman
1. Create new collection
2. Add requests for each endpoint
3. Set base URL as variable
4. Test all endpoints before integrating

### 3. Test in App
1. Add test data to your backend
2. Update `baseUrl` in `app_constants.dart`
3. Run app: `flutter run`
4. Check Console for API responses
5. Enable Dio logging to debug (see below)

## 🐛 Enable API Logging for Debugging

In `lib/services/api_service.dart`, uncomment the LogInterceptor:

```dart
_dio.interceptors.add(
  LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (obj) {
      print(obj); // Print to console for debugging
    },
  ),
);
```

Then check the console output to see:
- Request URLs
- Request headers
- Request body
- Response status
- Response body

## 🔄 Handling API Errors

### Error Handling in Code

The app automatically handles:
- **Connection errors**: Network unavailable
- **Timeout errors**: API response too slow (30s default)
- **HTTP errors**: 4xx, 5xx status codes
- **JSON parse errors**: Invalid response format

### Error Messages Display

Users see:
1. **Loading state**: While requesting
2. **Error state**: If request fails with retry button
3. **Empty state**: If no results found
4. **Success state**: If data loaded successfully

### Custom Error Handling

To handle specific errors, modify `api_service.dart`:

```dart
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    throw Exception('Connection timeout');
  } else if (e.type == DioExceptionType.receiveTimeout) {
    throw Exception('Server too slow');
  } else if (e.response?.statusCode == 404) {
    throw Exception('Not found');
  }
  throw Exception('Error: ${e.message}');
}
```

## 🚀 Optimization Tips

### 1. Pagination
Implement pagination to reduce data transfer:
```dart
// Load first page
trailerProvider.loadTrendingTrailers(page: 1);

// Load more on scroll
trailerProvider.loadTrendingTrailers(page: 2, isLoadMore: true);
```

### 2. Image Optimization
Ensure your API returns:
- Optimized image sizes
- WebP format (better compression)
- CDN-delivered images for fast loading

### 3. Caching
The app uses `cached_network_image` for automatic caching.
Configure cache duration in `cached_network_image` settings if needed.

### 4. Response Compression
Enable GZIP compression on backend:
```
Content-Encoding: gzip
```

## 📋 Required API Capabilities

Your backend API must support:

- ✅ HTTPS (required for production)
- ✅ CORS (if frontend is separate domain)
- ✅ JSON responses
- ✅ Pagination with `page` and `limit`
- ✅ Sorting (`sortBy`, `order` parameters)
- ✅ Search functionality (`q` parameter)
- ✅ Proper HTTP status codes
- ✅ Error response format:

```json
{
  "status": "error",
  "message": "Error description",
  "code": "ERROR_CODE"
}
```

## 🔒 Security Considerations

1. **Never commit API keys**: Use environment variables
2. **Use HTTPS only**: Never use HTTP in production
3. **Validate inputs**: Backend should validate all inputs
4. **Rate limiting**: Implement to prevent abuse
5. **CORS**: Configure properly for your domain
6. **Token expiration**: Implement token refresh mechanism

## 📞 Troubleshooting

### API Not Responding
- Check network connection
- Verify `baseUrl` is correct
- Check API server is running
- Look for CORS errors in browser console

### JSON Parse Error
- Verify response matches expected format
- Check for extra fields in response
- Ensure all required fields are present
- Enable logging to see actual response

### Images Not Loading
- Check image URLs are public and accessible
- Verify URL format (should include protocol)
- Check CDN is working
- Enable HTTPS on image URLs

### Performance Issues
- Implement pagination
- Optimize image sizes on backend
- Use response compression
- Cache frequently accessed data

---

**Example Complete Integration**:

```dart
// In main.dart
final apiService = ApiService();

// In any screen
final trailers = await apiService.getTrendingTrailers(page: 1);
final searchResults = await apiService.searchTrailers(query: 'avatar');
final categories = await apiService.getCategories();
```

For more details, refer to `api_service.dart` and individual screen implementations.
