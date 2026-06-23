import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelPlayer extends StatelessWidget {
  final VideoPlayerController? controller;
  final String thumbnailUrl;
  final bool active;

  const ReelPlayer({
    super.key,
    required this.controller,
    required this.thumbnailUrl,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final ready = controller?.value.isInitialized ?? false;
    return Stack(
      fit: StackFit.expand,
      children: [
        _SafeImage(url: thumbnailUrl),
        if (ready)
          Opacity(
            opacity: active ? 1 : 0,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller!.value.size.width,
                height: controller!.value.size.height,
                child: VideoPlayer(controller!),
              ),
            ),
          ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x22000000), Color(0xCC000000)],
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
    if (_failed || !valid) return const ColoredBox(color: Color(0xFF1E1E1E), child: Center(child: Icon(Icons.movie_creation_outlined, color: Colors.white54, size: 42)));
    return Image.network(
      widget.url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        if (!_failed) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) setState(() => _failed = true); });
        return const ColoredBox(color: Color(0xFF1E1E1E), child: Center(child: Icon(Icons.movie_creation_outlined, color: Colors.white54, size: 42)));
      },
    );
  }
}
