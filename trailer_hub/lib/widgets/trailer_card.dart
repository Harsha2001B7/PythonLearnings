import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/trailer_model.dart';
import '../core/theme/app_theme.dart';

/// Trailer Card Widget
/// Displays a single trailer in card format with image and information

class TrailerCard extends StatefulWidget {
  final TrailerModel trailer;
  final VoidCallback? onTap;
  final VoidCallback? onFavoritePressed;
  final bool isFavorite;

  const TrailerCard({
    super.key,
    required this.trailer,
    this.onTap,
    this.onFavoritePressed,
    this.isFavorite = false,
  });

  @override
  State<TrailerCard> createState() => _TrailerCardState();
}

class _TrailerCardState extends State<TrailerCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMd),
          child: Stack(
            children: [
              // Trailer Image
              CachedNetworkImage(
                imageUrl: widget.trailer.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.error),
                  ),
                ),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        widget.trailer.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppTheme.paddingSm),

                      // Rating and Views
                      Row(
                        children: [
                          // Rating
                          Text(
                            widget.trailer.ratingDisplay,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(width: AppTheme.paddingMd),

                          // Views
                          Icon(
                            Icons.visibility,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.trailer.formattedViews,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Favorite Button
              Positioned(
                top: AppTheme.paddingMd,
                right: AppTheme.paddingMd,
                child: GestureDetector(
                  onTap: widget.onFavoritePressed,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: widget.isFavorite ? Colors.red : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Duration Badge
              Positioned(
                top: AppTheme.paddingMd,
                left: AppTheme.paddingMd,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    widget.trailer.formattedDuration,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
