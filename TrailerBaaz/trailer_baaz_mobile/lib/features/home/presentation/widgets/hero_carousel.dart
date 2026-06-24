import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';

class HeroCarousel extends StatefulWidget {
  final List<TrailerModel> trailers;
  final ValueChanged<TrailerModel> onDetails;

  const HeroCarousel({super.key, required this.trailers, required this.onDetails});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _page;
  Timer? _timer;
  VideoPlayerController? _video;
  int _index = 0;
  bool _muted = true, _paused = false;

  @override
  void initState() {
    super.initState();
    _page = PageController();
    _loadVideo();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!_page.hasClients || widget.trailers.length < 2) return;
      final next = (_index + 1) % widget.trailers.length;
      _page.animateToPage(next, duration: const Duration(milliseconds: 520), curve: Curves.easeOutCubic);
    });
  }

  Future<void> _loadVideo() async {
    await _video?.dispose();
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.trailers[_index].videoUrl),
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

  void _sync() {
    final video = _video;
    if (video == null || !video.value.isInitialized) return;
    video.setVolume(_muted ? 0 : 1);
    _paused ? video.pause() : video.play();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.of(context).size.width * 1.2).clamp(460.0, 620.0).toDouble();
    return SizedBox(
      height: height,
      child: PageView.builder(
        physics: const BouncingScrollPhysics(),
        controller: _page,
        itemCount: widget.trailers.length,
        onPageChanged: (i) {
          setState(() => _index = i);
          _loadVideo();
        },
        itemBuilder: (_, i) => _HeroSlide(
          trailer: widget.trailers[i],
          video: i == _index ? _video : null,
          muted: _muted,
          paused: _paused,
          active: i == _index,
          count: widget.trailers.length,
          index: _index,
          onDetails: () => widget.onDetails(widget.trailers[i]),
          onMute: () => setState(() { _muted = !_muted; _sync(); }),
          onPause: () => setState(() { _paused = !_paused; _sync(); }),
        ),
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  final TrailerModel trailer; final VideoPlayerController? video; final bool muted, paused, active; final int index, count; final VoidCallback onMute, onPause, onDetails;
  const _HeroSlide({required this.trailer, required this.video, required this.muted, required this.paused, required this.active, required this.index, required this.count, required this.onMute, required this.onPause, required this.onDetails});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Stack(fit: StackFit.expand, children: [
      _SafeImage(url: trailer.imageUrl),
      if (video != null && video!.value.isInitialized) Opacity(opacity: active ? 0.9 : 0, child: FittedBox(fit: BoxFit.cover, child: SizedBox(width: video!.value.size.width, height: video!.value.size.height, child: VideoPlayer(video!)))),
      const Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, 0.15, 0.7, 1],
              colors: [AppColors.background, Colors.transparent, Colors.transparent, AppColors.background],
            ),
          ),
        ),
      ),
      const Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xCC0D0D0F), Colors.transparent], stops: [0, 0.34]),
          ),
        ),
      ),
      Positioned(top: topInset + 112, right: 16, child: Row(children: [_CircleIcon(icon: muted ? Icons.volume_off_rounded : Icons.volume_up_rounded, onTap: onMute), const SizedBox(width: 10), _CircleIcon(icon: paused ? Icons.play_arrow_rounded : Icons.pause_rounded, onTap: onPause)])),
      Positioned(left: 20, right: 20, bottom: 30, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(trailer.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, shadows: const [Shadow(color: Colors.black87, blurRadius: 14, offset: Offset(0, 2))])),
        const SizedBox(height: 8),
        Text('${trailer.language} • ${trailer.genre}', style: const TextStyle(color: AppColors.textGrey, shadows: [Shadow(color: Colors.black87, blurRadius: 10)])),
        const SizedBox(height: 14),
        Row(children: [_ActionButton(icon: Icons.play_arrow_rounded, label: 'Play', filled: true, onTap: () {}), const SizedBox(width: 12), _ActionButton(icon: Icons.info_outline_rounded, label: 'More Info', onTap: onDetails)]),
        const SizedBox(height: 18),
        Row(children: List.generate(count, (i) => AnimatedContainer(duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic, margin: const EdgeInsets.only(right: 6), width: index == i ? 24 : 8, height: 8, decoration: BoxDecoration(color: index == i ? AppColors.amber : Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(99))))),
      ])),
    ]);
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _CircleIcon({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => _SpringPress(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Icon(icon, color: AppColors.textWhite),
    ),
  );
}

class _ActionButton extends StatelessWidget {
  final IconData icon; final String label; final bool filled;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap, this.filled = false});
  @override
  Widget build(BuildContext context) => Expanded(
    child: _SpringPress(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: filled ? AppColors.textWhite : Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: filled ? Colors.transparent : Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: filled ? AppColors.background : AppColors.textWhite),
            const SizedBox(width: 6),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(color: filled ? AppColors.background : AppColors.textWhite, fontWeight: FontWeight.w700))),
          ],
        ),
      ),
    ),
  );
}

class _SpringPress extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _SpringPress({required this.child, required this.onTap});

  @override
  State<_SpringPress> createState() => _SpringPressState();
}

class _SpringPressState extends State<_SpringPress> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(scale: _pressed ? 0.95 : 1, duration: const Duration(milliseconds: 420), curve: Curves.elasticOut, child: widget.child),
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
    if (_failed || !valid) return const ColoredBox(color: AppColors.card, child: Center(child: Icon(Icons.movie_outlined, color: AppColors.textGrey, size: 42)));
    return Image.network(
      widget.url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        if (!_failed) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) setState(() => _failed = true); });
        return const ColoredBox(color: AppColors.card, child: Center(child: Icon(Icons.movie_outlined, color: AppColors.textGrey, size: 42)));
      },
    );
  }
}
