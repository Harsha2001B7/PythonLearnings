import '../../../../shared/models/trailer_model.dart';

class HomeDummyData {
  static const _v1 = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
  static const _v2 = 'https://samplelib.com/lib/preview/mp4/sample-5s.mp4';
  static const _v3 = 'https://samplelib.com/lib/preview/mp4/sample-10s.mp4';

  static const trailers = <TrailerModel>[
    // TODO: Replace with FastAPI home feed and YouTube trailers later.
    TrailerModel(title: 'Salaar', imageUrl: 'https://image.tmdb.org/t/p/w780/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=4GPvYMKtrtI', videoUrl: _v1, category: 'Trending', language: 'Telugu', genre: 'Action'),
    TrailerModel(title: 'Kalki 2898 AD', imageUrl: 'https://image.tmdb.org/t/p/w780/sci4z7Y6nYzDwHEfsYjeTgLq0MI.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=BfCIPsEGAS8', videoUrl: _v2, category: 'Trending', language: 'Hindi', genre: 'Sci-Fi'),
    TrailerModel(title: 'Pushpa 2', imageUrl: 'https://image.tmdb.org/t/p/w780/62xGzeY7rOZw5L6xVnliiM4S8xS.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=g3JUbgOHgdw', videoUrl: _v3, category: 'Trending', language: 'Telugu', genre: 'Mass'),
    TrailerModel(title: 'Game Changer', imageUrl: 'https://image.tmdb.org/t/p/w780/t9XkeE7HzOsdQcDDDapDYh8Rrmt.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=G4qBU9fve0Y', videoUrl: _v1, category: 'Telugu', language: 'Telugu', genre: 'Political'),
    TrailerModel(title: 'Devara', imageUrl: 'https://image.tmdb.org/t/p/w780/k1vWhw7qJwKlfQk6TB8fV7cJ2uj.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=rc61YHl1PFY', videoUrl: _v2, category: 'Telugu', language: 'Telugu', genre: 'Action'),
    TrailerModel(title: 'OG', imageUrl: 'https://image.tmdb.org/t/p/w780/xnnYSLJ1Z7K9w3yXcThhDTt8pK3.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=JKAi2xV6g1c', videoUrl: _v3, category: 'Telugu', language: 'Telugu', genre: 'Gangster'),
    TrailerModel(title: 'Jawan', imageUrl: 'https://image.tmdb.org/t/p/w780/jFt1gS4BGHlK8xt76Y81Alp4dbt.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=MWOlnZSnXJo', videoUrl: _v1, category: 'Hindi', language: 'Hindi', genre: 'Action'),
    TrailerModel(title: 'Animal', imageUrl: 'https://image.tmdb.org/t/p/w780/xCaMFatXuhxqX9Zp3M0Wq9ELi6f.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=Dydmpfo68DA', videoUrl: _v2, category: 'Hindi', language: 'Hindi', genre: 'Crime'),
    TrailerModel(title: 'Stree 2', imageUrl: 'https://image.tmdb.org/t/p/w780/7seqaCaaXDNUHOx4DqwpoOH8pPa.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=KLVq0IAzh1A', videoUrl: _v3, category: 'Hindi', language: 'Hindi', genre: 'Comedy'),
    TrailerModel(title: 'Mirzapur', imageUrl: 'https://image.tmdb.org/t/p/w780/9q0j0qS0r5yYvJZZzKzbwQ6vurI.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=ZNeGF-PvRHY', videoUrl: _v1, category: 'Web Series', language: 'Hindi', genre: 'Crime'),
    TrailerModel(title: 'Farzi', imageUrl: 'https://image.tmdb.org/t/p/w780/aB2x8Gx8hN8R3t6m0n6zkRgZNpm.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=tNfF5xG1JEs', videoUrl: _v2, category: 'Web Series', language: 'Hindi', genre: 'Thriller'),
    TrailerModel(title: 'The Family Man', imageUrl: 'https://image.tmdb.org/t/p/w780/q53nctT0x8lWb1x1o1t4bmPqhGV.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=XatRGut65VI', videoUrl: _v3, category: 'Web Series', language: 'Hindi', genre: 'Spy'),
    TrailerModel(title: 'Coolie', imageUrl: 'https://image.tmdb.org/t/p/w780/8cdWjvZQUExUUTzVk3MaqkO1g1k.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=v9M8eo74fD8', videoUrl: _v1, category: 'Upcoming', language: 'Tamil', genre: 'Action', isUpcoming: true),
    TrailerModel(title: 'War 2', imageUrl: 'https://image.tmdb.org/t/p/w780/euYIwmwkmz95mnXvufEmbL6ovhZ.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=hbVV58BfGqc', videoUrl: _v2, category: 'Upcoming', language: 'Hindi', genre: 'Spy', isUpcoming: true),
    TrailerModel(title: 'Kuberaa', imageUrl: 'https://image.tmdb.org/t/p/w780/6uAiest6qj0d5X9wR7mO7m0cC7p.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=Qf1nCzl0Ywk', videoUrl: _v3, category: 'Upcoming', language: 'Telugu', genre: 'Drama', isUpcoming: true),
  ];

  static List<TrailerModel> byCategory(String category) {
    return trailers.where((item) => item.category == category).toList();
  }

  static List<TrailerModel> get featured => trailers.take(5).toList();
  static List<TrailerModel> get upcoming => trailers.where((item) => item.isUpcoming).toList();
}
