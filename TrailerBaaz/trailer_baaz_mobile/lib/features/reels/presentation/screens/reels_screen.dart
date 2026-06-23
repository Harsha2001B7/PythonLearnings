import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../home/data/mock/home_dummy_data.dart';
import '../../../home/presentation/screens/trailer_details_screen.dart';
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
  VideoPlayerController? _video;
  int _index = 0;
  bool _muted = true;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _page = PageController();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    await _video?.dispose();
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(_reels[_index].videoUrl),
    );
    _video = controller;
    await controller.setLooping(true);
    await controller.setVolume(_muted ? 0 : 1);
    await controller.initialize();
    if (!mounted || _video != controller) {
      await controller.dispose();
      return;
    }
    if (!_paused) controller.play();
    setState(() {});
  }

  void _syncPlayback() {
    final video = _video;
    if (video == null || !video.value.isInitialized) return;
    video.setVolume(_muted ? 0 : 1);
    _paused ? video.pause() : video.play();
  }

  void _onPageChanged(int index) {
    setState(() {
      _index = index;
      _paused = false;
    });
    _loadVideo();
  }

  void _openDetails(ReelModel reel) {
    final matches = HomeDummyData.trailers.where((item) => item.title == reel.title);
    if (matches.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TrailerDetailsScreen(trailer: matches.first)),
    );
  }

  @override
  void dispose() {
    _page.dispose();
    _video?.dispose();
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
          controller: index == _index ? _video : null,
          active: index == _index,
          muted: _muted,
          paused: _paused && index == _index,
          onMute: () => setState(() { _muted = !_muted; _syncPlayback(); }),
          onPlayPause: () => setState(() { _paused = !_paused; _syncPlayback(); }),
          onDetails: () => _openDetails(_reels[index]),
        ),
      ),
    );
  }
}

class _ReelPage extends StatelessWidget {
  final ReelModel reel;
  final VideoPlayerController? controller;
  final bool active;
  final bool muted;
  final bool paused;
  final VoidCallback onMute;
  final VoidCallback onPlayPause;
  final VoidCallback onDetails;

  const _ReelPage({required this.reel, required this.controller, required this.active, required this.muted, required this.paused, required this.onMute, required this.onPlayPause, required this.onDetails});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ReelPlayer(controller: controller, thumbnailUrl: reel.thumbnailUrl, active: active),
        ReelOverlay(reel: reel, muted: muted, paused: paused, onMute: onMute, onPlayPause: onPlayPause, onDetails: onDetails),
      ],
    );
  }
}
