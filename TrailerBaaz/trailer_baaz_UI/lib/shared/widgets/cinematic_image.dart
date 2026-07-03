import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CinematicImage extends StatelessWidget {
  const CinematicImage({
    super.key,
    required this.url,
    this.fallbackUrl,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.alignment = Alignment.center,
    this.memCacheWidth,
    this.memCacheHeight,
    this.fadeInDuration = const Duration(milliseconds: 120),
  });

  final String url;
  final String? fallbackUrl;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final Alignment alignment;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Duration fadeInDuration;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: const _ImageFallback(),
      );
    }

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: borderRadius,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final resolvedWidth = memCacheWidth ??
                _scaledCacheDimension(constraints.maxWidth, context);
            final resolvedHeight = memCacheHeight ??
                _scaledCacheDimension(constraints.maxHeight, context);

            return _CachedCinematicImage(
              imageUrl: url,
              fallbackUrl: fallbackUrl,
              fit: fit,
              alignment: alignment,
              memCacheWidth: resolvedWidth,
              memCacheHeight: resolvedHeight,
              fadeInDuration: fadeInDuration,
            );
          },
        ),
      ),
    );
  }

  int? _scaledCacheDimension(double logicalSize, BuildContext context) {
    if (!logicalSize.isFinite || logicalSize <= 0) return null;
    return (logicalSize * MediaQuery.devicePixelRatioOf(context)).round();
  }
}

class _CachedCinematicImage extends StatelessWidget {
  const _CachedCinematicImage({
    required this.imageUrl,
    required this.fallbackUrl,
    required this.fit,
    required this.alignment,
    required this.memCacheWidth,
    required this.memCacheHeight,
    required this.fadeInDuration,
  });

  final String imageUrl;
  final String? fallbackUrl;
  final BoxFit fit;
  final Alignment alignment;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Duration fadeInDuration;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      key: ValueKey<String>(imageUrl),
      imageUrl: imageUrl,
      fit: fit,
      alignment: alignment,
      width: double.infinity,
      height: double.infinity,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: Duration.zero,
      placeholderFadeInDuration: Duration.zero,
      useOldImageOnUrlChange: true,
      filterQuality: FilterQuality.high,
      placeholder: (_, _) => const _ImageFallback(),
      errorWidget: (_, _, _) {
        final fallback = fallbackUrl;
        if (fallback != null && fallback.isNotEmpty && fallback != imageUrl) {
          return _CachedCinematicImage(
            imageUrl: fallback,
            fallbackUrl: null,
            fit: fit,
            alignment: alignment,
            memCacheWidth: memCacheWidth,
            memCacheHeight: memCacheHeight,
            fadeInDuration: fadeInDuration,
          );
        }
        return const _ImageFallback();
      },
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF262626), Color(0xFF101010), Color(0xFF2B1114)],
        ),
      ),
      child: Center(
        child: Icon(Icons.movie_creation_outlined, color: Colors.white30),
      ),
    );
  }
}
