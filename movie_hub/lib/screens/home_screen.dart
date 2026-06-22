import 'package:flutter/material.dart';
import '../widgets/movie_section.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import 'movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final tmdbService = TmdbService();

  List<Movie> trendingMovies = [];

  List<Movie> topRatedMovies = [];

  List<Movie> popularMovies = [];
  @override
  void initState() {
    super.initState();

    loadMovies();
  }

  Future<void> loadMovies() async {
    final results = await Future.wait([
      tmdbService.getTrendingMovies(),

      tmdbService.getTopRatedMovies(),

      tmdbService.getPopularMovies(),
    ]);

    setState(() {
      trendingMovies = results[0];

      topRatedMovies = results[1];

      popularMovies = results[2];
    });
  }

  void openMovieDetails(Movie movie) {
    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (context) => MovieDetailsScreen(title: movie.title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Text(
                      '🎬 Movie Hub',

                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                MovieSection(
                  title: '🔥 Trending Movies',
                  movies: trendingMovies,
                  onMovieTap: openMovieDetails,
                ),
                const SizedBox(height: 30),

                MovieSection(
                  title: '⭐ Top Rated',
                  movies: topRatedMovies,
                  onMovieTap: openMovieDetails,
                ),

                const SizedBox(height: 30),

                MovieSection(
                  title: '🎬 Popular',
                  movies: popularMovies,
                  onMovieTap: openMovieDetails,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
