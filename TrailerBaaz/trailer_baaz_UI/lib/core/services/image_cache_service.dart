import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/trailer.dart';

/// Disk + memory image warming, precaching, and Flutter image-cache tuning.
class ImageCacheService {
  static const int _homeSectionPrecacheLimit = 8;

  void configure() {
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = 250;
    cache.maximumSizeBytes = 120 * 1024 * 1024;
  }

  int? _scaledCacheDimension(double? logicalSize, BuildContext context) {
    if (logicalSize == null || !logicalSize.isFinite || logicalSize <= 0) {
      return null;
    }
    return (logicalSize * MediaQuery.devicePixelRatioOf(context)).round();
  }

  Future<void> precacheUrl(
    BuildContext context,
    String url, {
    int? memCacheWidth,
    int? memCacheHeight,
  }) async {
    if (url.isEmpty || !context.mounted) return;

    try {
      await precacheImage(
        CachedNetworkImageProvider(
          url,
          maxWidth: memCacheWidth,
          maxHeight: memCacheHeight,
        ),
        context,
      );
    } catch (_) {}
  }

  void precacheUrlInBackground(
    BuildContext context,
    String url, {
    int? memCacheWidth,
    int? memCacheHeight,
  }) {
    unawaited(
      precacheUrl(
        context,
        url,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
      ),
    );
  }

  String cardThumbnailUrl(Trailer trailer) {
    return trailer.youtubeVideoId.isNotEmpty
        ? trailer.youtubeHqThumbnailUrl
        : trailer.posterUrl;
  }

  void precacheCardThumbnail(
    BuildContext context,
    Trailer trailer, {
    double? width,
    double? height,
  }) {
    precacheUrlInBackground(
      context,
      cardThumbnailUrl(trailer),
      memCacheWidth: _scaledCacheDimension(width, context),
      memCacheHeight: _scaledCacheDimension(height, context),
    );
  }

  void precacheHeroBackdrop(
    BuildContext context,
    Trailer trailer, {
    double? height,
  }) {
    precacheUrlInBackground(
      context,
      trailer.youtubeThumbnailUrl,
      memCacheHeight: _scaledCacheDimension(height, context),
    );
  }

  void precacheHeroNeighbors(
    BuildContext context,
    List<Trailer> heroes,
    int page, {
    double? heroHeight,
  }) {
    if (heroes.isEmpty || !context.mounted) return;

    final length = heroes.length;
    for (final offset in const [-1, 0, 1, 2]) {
      final index = (page + offset) % length;
      final normalizedIndex = index < 0 ? index + length : index;
      precacheHeroBackdrop(
        context,
        heroes[normalizedIndex],
        height: heroHeight,
      );
    }
  }

  void warmHomeFeed(
    BuildContext context, {
    required List<Trailer> heroTrailers,
    required Map<String, List<Trailer>> sections,
    required double heroHeight,
    required double cardWidth,
    required double cardImageHeight,
  }) {
    if (!context.mounted) return;

    for (final trailer in heroTrailers) {
      precacheHeroBackdrop(context, trailer, height: heroHeight);
    }

    var warmed = 0;
    for (final entry in sections.entries) {
      for (final trailer in entry.value) {
        precacheCardThumbnail(
          context,
          trailer,
          width: cardWidth,
          height: cardImageHeight,
        );
        warmed++;
        if (warmed >= _homeSectionPrecacheLimit) return;
      }
    }
  }

  void clearMemoryCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}
