import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';

class HeroCarousel extends StatefulWidget {
  final List<TrailerModel> trailers;

  const HeroCarousel({super.key, required this.trailers});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _page;
  late final List<VideoPlayerController> _videos;
  Timer? _timer;
  int _index = 0;
  bool _muted = true, _paused = false;

  @override
  void initState() {
    super.initState();
    _page = PageController(viewportFraction: 0.94);
    _videos = widget.trailers.map((t) => VideoPlayerController.networkUrl(Uri.parse(t.videoUrl))).toList();
    for (final video in _videos) {
      video
        ..setLooping(true)
        ..setVolume(0)
        ..initialize().then((_) {
          if (!mounted) return;
          setState(_sync);
        });
    }
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!_page.hasClients || widget.trailers.length < 2) return;
      final next = (_index + 1) % widget.trailers.length;
      _page.animateToPage(next, duration: const Duration(milliseconds: 450), curve: Curves.easeOut);
    });
  }

  void _sync() {
    for (var i = 0; i < _videos.length; i++) {
      final video = _videos[i];
      if (!video.value.isInitialized) continue;
      final active = i == _index && !_paused;
      video.setVolume(active && !_muted ? 1 : 0);
      active ? video.play() : video.pause();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    for (final video in _videos) { video.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.of(context).size.width * 1.15).clamp(360.0, 520.0).toDouble();
    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: _page,
        itemCount: widget.trailers.length,
        onPageChanged: (i) => setState(() { _index = i; _sync(); }),
        itemBuilder: (_, i) => _HeroSlide(
          trailer: widget.trailers[i],
          video: _videos[i],
          muted: _muted,
          paused: _paused,
          active: i == _index,
          count: widget.trailers.length,
          index: _index,
          onMute: () => setState(() { _muted = !_muted; _sync(); }),
          onPause: () => setState(() { _paused = !_paused; _sync(); }),
        ),
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  final TrailerModel trailer; final VideoPlayerController video; final bool muted, paused, active; final int index, count; final VoidCallback onMute, onPause;
  const _HeroSlide({required this.trailer, required this.video, required this.muted, required this.paused, required this.active, required this.index, required this.count, required this.onMute, required this.onPause});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(fit: StackFit.expand, children: [
          Image.network(trailer.imageUrl, fit: BoxFit.cover),
          if (video.value.isInitialized) Opacity(opacity: active ? 0.92 : 0, child: FittedBox(fit: BoxFit.cover, child: SizedBox(width: video.value.size.width, height: video.value.size.height, child: VideoPlayer(video)))),
          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x30000000), Color(0xDD000000)]))),
          Positioned(top: 16, right: 16, child: Row(children: [_CircleIcon(icon: muted ? Icons.volume_off_rounded : Icons.volume_up_rounded, onTap: onMute), const SizedBox(width: 10), _CircleIcon(icon: paused ? Icons.play_arrow_rounded : Icons.pause_rounded, onTap: onPause)])),
          Positioned(left: 20, right: 20, bottom: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(trailer.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('${trailer.language} • ${trailer.genre}', style: const TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 14),
            Row(children: const [_ActionButton(icon: Icons.play_arrow_rounded, label: 'Play', filled: true), SizedBox(width: 12), _ActionButton(icon: Icons.info_outline_rounded, label: 'More Info')]),
            const SizedBox(height: 16),
            Row(children: List.generate(count, (i) => AnimatedContainer(duration: const Duration(milliseconds: 250), margin: const EdgeInsets.only(right: 6), width: index == i ? 20 : 8, height: 8, decoration: BoxDecoration(color: index == i ? AppColors.primaryRed : Colors.white38, borderRadius: BorderRadius.circular(99))))),
          ])),
        ]),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _CircleIcon({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Color(0x66000000), shape: BoxShape.circle), child: Icon(icon, color: AppColors.textWhite)));
}

class _ActionButton extends StatelessWidget {
  final IconData icon; final String label; final bool filled;
  const _ActionButton({required this.icon, required this.label, this.filled = false});
  @override
  Widget build(BuildContext context) => Expanded(child: FilledButton.tonalIcon(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: filled ? AppColors.textWhite : Colors.white12, foregroundColor: filled ? Colors.black : AppColors.textWhite), icon: Icon(icon, size: 20), label: Text(label)));
}
