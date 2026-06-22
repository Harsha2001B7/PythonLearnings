import '../../../../shared/models/trailer_model.dart';

class HomeDummyData {
  static const trailers = <TrailerModel>[
    TrailerModel(title: 'Salaar', imageUrl: 'https://image.tmdb.org/t/p/w780/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=4GPvYMKtrtI', category: 'Trending', subtitle: 'Telugu • Action'),
    TrailerModel(title: 'Kalki 2898 AD', imageUrl: 'https://image.tmdb.org/t/p/w780/sci4z7Y6nYzDwHEfsYjeTgLq0MI.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=BfCIPsEGAS8', category: 'Trending', subtitle: 'Hindi • Sci-Fi'),
    TrailerModel(title: 'Pushpa 2', imageUrl: 'https://image.tmdb.org/t/p/w780/62xGzeY7rOZw5L6xVnliiM4S8xS.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=g3JUbgOHgdw', category: 'Trending', subtitle: 'Telugu • Mass'),
    TrailerModel(title: 'Game Changer', imageUrl: 'https://image.tmdb.org/t/p/w780/t9XkeE7HzOsdQcDDDapDYh8Rrmt.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=G4qBU9fve0Y', category: 'Telugu', subtitle: 'Political • Drama'),
    TrailerModel(title: 'Devara', imageUrl: 'https://image.tmdb.org/t/p/w780/k1vWhw7qJwKlfQk6TB8fV7cJ2uj.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=rc61YHl1PFY', category: 'Telugu', subtitle: 'Sea • Action'),
    TrailerModel(title: 'OG', imageUrl: 'https://image.tmdb.org/t/p/w780/xnnYSLJ1Z7K9w3yXcThhDTt8pK3.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=JKAi2xV6g1c', category: 'Telugu', subtitle: 'Gangster • Action'),
    TrailerModel(title: 'Jawan', imageUrl: 'https://image.tmdb.org/t/p/w780/jFt1gS4BGHlK8xt76Y81Alp4dbt.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=MWOlnZSnXJo', category: 'Hindi', subtitle: 'Atlee • Action'),
    TrailerModel(title: 'Animal', imageUrl: 'https://image.tmdb.org/t/p/w780/xCaMFatXuhxqX9Zp3M0Wq9ELi6f.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=Dydmpfo68DA', category: 'Hindi', subtitle: 'Crime • Drama'),
    TrailerModel(title: 'Stree 2', imageUrl: 'https://image.tmdb.org/t/p/w780/7seqaCaaXDNUHOx4DqwpoOH8pPa.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=KLVq0IAzh1A', category: 'Hindi', subtitle: 'Horror • Comedy'),
    TrailerModel(title: 'Mirzapur', imageUrl: 'https://image.tmdb.org/t/p/w780/9q0j0qS0r5yYvJZZzKzbwQ6vurI.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=ZNeGF-PvRHY', category: 'Web Series', subtitle: 'Prime Video • Crime'),
    TrailerModel(title: 'Farzi', imageUrl: 'https://image.tmdb.org/t/p/w780/aB2x8Gx8hN8R3t6m0n6zkRgZNpm.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=tNfF5xG1JEs', category: 'Web Series', subtitle: 'Thriller • Drama'),
    TrailerModel(title: 'The Family Man', imageUrl: 'https://image.tmdb.org/t/p/w780/q53nctT0x8lWb1x1o1t4bmPqhGV.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=XatRGut65VI', category: 'Web Series', subtitle: 'Spy • Thriller'),
    TrailerModel(title: 'Coolie', imageUrl: 'https://image.tmdb.org/t/p/w780/8cdWjvZQUExUUTzVk3MaqkO1g1k.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=dummyCoolie123', category: 'Upcoming', subtitle: 'Superstar • Action', isUpcoming: true),
    TrailerModel(title: 'War 2', imageUrl: 'https://image.tmdb.org/t/p/w780/euYIwmwkmz95mnXvufEmbL6ovhZ.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=dummyWar2123', category: 'Upcoming', subtitle: 'Spy Universe • Action', isUpcoming: true),
    TrailerModel(title: 'Kuberaa', imageUrl: 'https://image.tmdb.org/t/p/w780/6uAiest6qj0d5X9wR7mO7m0cC7p.jpg', youtubeUrl: 'https://www.youtube.com/watch?v=dummyKuberaa123', category: 'Upcoming', subtitle: 'Drama • Thriller', isUpcoming: true),
  ];

  static List<TrailerModel> byCategory(String category) {
    return trailers.where((item) => item.category == category).toList();
  }

  static List<TrailerModel> get featured => trailers.take(5).toList();
  static List<TrailerModel> get upcoming => trailers.where((item) => item.isUpcoming).toList();
}