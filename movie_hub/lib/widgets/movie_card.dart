import 'package:flutter/material.dart';

class MovieCard extends StatelessWidget {
  final String title;

  final double rating;
  final String posterPath;
  final VoidCallback onTap;
  const MovieCard({
    super.key,

    required this.title,

    required this.rating,

    required this.posterPath,

    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 150,

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: Colors.grey[900],

          borderRadius: BorderRadius.circular(12),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),

              child: Image.network(
                'https://image.tmdb.org/t/p/w500$posterPath',

                height: 180,

                width: double.infinity,

                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              title,

              maxLines: 2,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 6),

            Text('⭐ ${rating.toStringAsFixed(1)}'),
          ],
        ),
      ),
    );
  }
}
