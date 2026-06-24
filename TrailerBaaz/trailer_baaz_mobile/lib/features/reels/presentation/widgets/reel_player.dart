import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ReelPlayer extends StatelessWidget {
  final String thumbnailUrl;
  final bool active;

  const ReelPlayer({
    super.key,
    required this.thumbnailUrl,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _SafeImage(url: thumbnailUrl),
        AnimatedOpacity(
          opacity: active ? 1 : 0.85,
          duration: const Duration(milliseconds: 180),
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x22000000), Color(0xCC000000)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SafeImage extends StatefulWidget {
  final String url;

  const _SafeImage({required this.url});

  @override
  State<_SafeImage> createState() => _SafeImageState();
}

class _SafeImageState extends State<_SafeImage> {
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    final valid = widget.url.startsWith('http') && widget.url.contains('/t/p/');
    if (_failed || !valid) {
      return const ColoredBox(
        color: Color(0xFF121214),
        child: Center(
          child: Icon(
            Icons.movie_creation_outlined,
            color: AppColors.textGrey,
            size: 42,
          ),
        ),
      );
    }

    return Image.network(
      widget.url,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
      errorBuilder: (context, error, stackTrace) {
        if (!_failed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _failed = true);
          });
        }
        return const ColoredBox(
          color: Color(0xFF121214),
          child: Center(
            child: Icon(
              Icons.movie_creation_outlined,
              color: AppColors.textGrey,
              size: 42,
            ),
          ),
        );
      },
    );
  }
}
