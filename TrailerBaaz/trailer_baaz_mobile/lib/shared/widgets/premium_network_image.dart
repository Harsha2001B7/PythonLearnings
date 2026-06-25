import 'package:flutter/material.dart';

class PremiumNetworkImage extends StatefulWidget {
  final String url;
  final BoxFit fit;

  const PremiumNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });

  @override
  State<PremiumNetworkImage> createState() => _PremiumNetworkImageState();
}

class _PremiumNetworkImageState extends State<PremiumNetworkImage> {
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    if (_failed || !_isValid(widget.url)) {
      return const _DarkPlaceholder();
    }

    return Image.network(
      widget.url,
      fit: widget.fit,
      filterQuality: FilterQuality.low,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress != null) {
          return const _DarkPlaceholder();
        }
        return child;
      },
      errorBuilder: (context, error, stackTrace) {
        if (!_failed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _failed = true);
          });
        }
        return const _DarkPlaceholder();
      },
    );
  }

  bool _isValid(String url) {
    final trimmed = url.trim();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }
}

class _DarkPlaceholder extends StatelessWidget {
  const _DarkPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0E0E10),
            Color(0xFF141416),
            Color(0xFF09090B),
          ],
        ),
      ),
    );
  }
}
