import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../data/mock/reels_dummy_data.dart';
import '../../domain/models/reel_model.dart';
import '../widgets/reel_overlay.dart';
import '../widgets/reel_player.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final _reels = ReelsDummyData.reels;
  late final PageController _page;
  late final List<VideoPlayerController> _videos;
  int _index = 0;
  bool _muted = true;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _page = PageController();
    _videos = _reels.map((reel) => VideoPlayerController.networkUrl(Uri.parse(reel.videoUrl))).toList();
    for (final video in _videos) {
      video
        ..setLooping(true)
        ..setVolume(0)
        ..initialize().then((_) {
          if (!mounted) return;
          setState(_syncPlayback);
        });
    }
  }

  void _syncPlayback() {
    for (var i = 0; i < _videos.length; i++) {
      final video = _videos[i];
      if (!video.value.isInitialized) continue;
      final active = i == _index && !_paused;
      video.setVolume(active && !_muted ? 1 : 0);
      active ? video.play() : video.pause();
    }
  }

  void _onPageChanged(int index) => setState(() {
        _index = index;
        _paused = false;
        _syncPlayback();
      });

  @override
  void dispose() {
    _page.dispose();
    for (final video in _videos) { video.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _page,
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (_, index) => _ReelPage(
          reel: _reels[index],
          controller: _videos[index],
          active: index == _index,
          muted: _muted,
          paused: _paused && index == _index,
          onMute: () => setState(() { _muted = !_muted; _syncPlayback(); }),
          onPlayPause: () => setState(() { _paused = !_paused; _syncPlayback(); }),
        ),
      ),
    );
  }
}

class _ReelPage extends StatelessWidget {
  final ReelModel reel;
  final VideoPlayerController controller;
  final bool active;
  final bool muted;
  final bool paused;
  final VoidCallback onMute;
  final VoidCallback onPlayPause;

  const _ReelPage({required this.reel, required this.controller, required this.active, required this.muted, required this.paused, required this.onMute, required this.onPlayPause});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ReelPlayer(controller: controller, thumbnailUrl: reel.thumbnailUrl, active: active),
        ReelOverlay(reel: reel, muted: muted, paused: paused, onMute: onMute, onPlayPause: onPlayPause),
      ],
    );
  }
}
