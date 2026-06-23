import '../../domain/models/reel_model.dart';

class ReelsDummyData {
  static const _v1 = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
  static const _v2 = 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4';
  static const _v3 = 'https://samplelib.com/lib/preview/mp4/sample-10s.mp4';

  // TODO: Replace with FastAPI reels feed and YouTube trailer sources later.
  static const reels = <ReelModel>[
    ReelModel(title: 'Salaar', industry: 'Tollywood', language: 'Telugu', views: '12.8M', videoUrl: _v1, thumbnailUrl: 'https://image.tmdb.org/t/p/w780/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg', genre: 'Action', releaseYear: '2023'),
    ReelModel(title: 'Kalki 2898 AD', industry: 'Bollywood', language: 'Hindi', views: '10.1M', videoUrl: _v2, thumbnailUrl: 'https://image.tmdb.org/t/p/w780/sci4z7Y6nYzDwHEfsYjeTgLq0MI.jpg', genre: 'Sci-Fi', releaseYear: '2024'),
    ReelModel(title: 'Pushpa 2', industry: 'Tollywood', language: 'Telugu', views: '18.4M', videoUrl: _v3, thumbnailUrl: 'https://image.tmdb.org/t/p/w780/62xGzeY7rOZw5L6xVnliiM4S8xS.jpg', genre: 'Mass', releaseYear: '2024'),
    ReelModel(title: 'Jawan', industry: 'Bollywood', language: 'Hindi', views: '21.3M', videoUrl: _v1, thumbnailUrl: 'https://image.tmdb.org/t/p/w780/jFt1gS4BGHlK8xt76Y81Alp4dbt.jpg', genre: 'Action', releaseYear: '2023'),
    ReelModel(title: 'Mirzapur', industry: 'Web Originals', language: 'Hindi', views: '9.7M', videoUrl: _v2, thumbnailUrl: 'https://image.tmdb.org/t/p/w780/9q0j0qS0r5yYvJZZzKzbwQ6vurI.jpg', genre: 'Crime', releaseYear: '2024'),
    ReelModel(title: 'Devara', industry: 'Tollywood', language: 'Telugu', views: '11.2M', videoUrl: _v3, thumbnailUrl: 'https://image.tmdb.org/t/p/w780/k1vWhw7qJwKlfQk6TB8fV7cJ2uj.jpg', genre: 'Action', releaseYear: '2024'),
    ReelModel(title: 'Animal', industry: 'Bollywood', language: 'Hindi', views: '14.6M', videoUrl: _v1, thumbnailUrl: 'https://image.tmdb.org/t/p/w780/xCaMFatXuhxqX9Zp3M0Wq9ELi6f.jpg', genre: 'Crime', releaseYear: '2023'),
    ReelModel(title: 'The Family Man', industry: 'Web Originals', language: 'Hindi', views: '8.4M', videoUrl: _v2, thumbnailUrl: 'https://image.tmdb.org/t/p/w780/q53nctT0x8lWb1x1o1t4bmPqhGV.jpg', genre: 'Spy', releaseYear: '2024'),
  ];
}
