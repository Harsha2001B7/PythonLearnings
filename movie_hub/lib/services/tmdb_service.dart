import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';

class TmdbService {
  final Dio dio = Dio();

  final String apiKey = dotenv.env['TMDB_API_KEY']!;

  Future<List<Movie>> getTrendingMovies() async {
    final response = await dio.get(
      'https://api.themoviedb.org/3/trending/movie/day',

      queryParameters: {'api_key': apiKey},
    );

    final results = response.data['results'];

    return results.map<Movie>((movie) {
      return Movie.fromJson(movie);
    }).toList();
  }

    Future<List<Movie>> getTopRatedMovies() async {
    final response = await dio.get(
      'https://api.themoviedb.org/3/movie/top_rated',

      queryParameters: {'api_key': apiKey},
    );

    final results = response.data['results'];

    return results.map<Movie>((movie) {
      return Movie.fromJson(movie);
    }).toList();
  }
    Future<List<Movie>> getPopularMovies() async {
    final response = await dio.get(
      'https://api.themoviedb.org/3/movie/popular',

      queryParameters: {'api_key': apiKey},
    );

    final results = response.data['results'];

    return results.map<Movie>((movie) {
      return Movie.fromJson(movie);
    }).toList();
  }

}
