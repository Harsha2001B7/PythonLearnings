import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelPlayer extends StatelessWidget {
  final VideoPlayerController controller;
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
    final ready = controller.value.isInitialized;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(thumbnailUrl, fit: BoxFit.cover),
        if (ready)
          Opacity(
            opacity: active ? 1 : 0,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
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
