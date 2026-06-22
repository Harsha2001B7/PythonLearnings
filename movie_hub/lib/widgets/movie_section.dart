import 'package:flutter/material.dart';
import 'movie_card.dart';
import '../models/movie.dart';

class MovieSection extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final Function(Movie) onMovieTap;
  const MovieSection({
    super.key,

    required this.title,

    required this.movies,

    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 320,

          child: ListView(
            scrollDirection: Axis.horizontal,

            children: movies.map((movie) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),

                child: MovieCard(
                  title: movie.title,

                  rating: movie.rating,

                  posterPath: movie.posterPath,

                  onTap: () {
                    onMovieTap(movie);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
