import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  int _index = 0;
  bool _muted = true;

  @override
  void initState() {
    super.initState();
    _page = PageController();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!_page.hasClients || widget.trailers.length < 2) return;
      final next = (_index + 1) % widget.trailers.length;
      _page.animateToPage(next, duration: const Duration(milliseconds: 520), curve: Curves.easeOutCubic);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
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
        },
        itemBuilder: (_, i) => _HeroSlide(
          key: ValueKey(widget.trailers[i].youtubeUrl),
          trailer: widget.trailers[i],
          active: i == _index,
          muted: _muted,
          count: widget.trailers.length,
          index: _index,
          onDetails: () => widget.onDetails(widget.trailers[i]),
          onMute: () => setState(() => _muted = !_muted),
        ),
      ),
    );
  }
}

class _HeroSlide extends StatefulWidget {
  final TrailerModel trailer;
  final bool active;
  final bool muted;
  final int index, count;
  final VoidCallback onMute, onDetails;

  const _HeroSlide({
    super.key,
    required this.trailer,
    required this.active,
    required this.muted,
    required this.index,
    required this.count,
    required this.onMute,
    required this.onDetails,
  });

  @override
  State<_HeroSlide> createState() => _HeroSlideState();
}

class _HeroSlideState extends State<_HeroSlide> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.trailer.youtubeUrl)!,
      flags: YoutubePlayerFlags(
        autoPlay: widget.active,
        mute: true,
        disableDragSeek: true,
        hideControls: true,
        hideThumbnail: true,
        enableCaption: false,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _HeroSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      if (widget.active) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Stack(fit: StackFit.expand, children: [
      YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: false,
          progressIndicatorColor: Colors.transparent,
        ),
        builder: (context, player) => Positioned.fill(child: player),
      ),
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
      Positioned(
        top: topInset + 112,
        right: 16,
        child: Row(
          children: [
            _CircleIcon(
              icon: widget.muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              onTap: () {
                setState(() {
                  widget.muted ? _controller.unMute() : _controller.mute();
                });
                widget.onMute();
              },
            ),
            const SizedBox(width: 10),
            _CircleIcon(
              icon: Icons.fullscreen_rounded,
              onTap: () => _controller.toggleFullScreenMode(),
              backgroundAlpha: 0.18,
            ),
          ],
        ),
      ),
      Positioned(left: 20, right: 20, bottom: 30, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(widget.trailer.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, shadows: const [Shadow(color: Colors.black87, blurRadius: 14, offset: Offset(0, 2))])),
        const SizedBox(height: 8),
        Text('${widget.trailer.language} • ${widget.trailer.genre}', style: const TextStyle(color: AppColors.textGrey, shadows: [Shadow(color: Colors.black87, blurRadius: 10)])),
        const SizedBox(height: 14),
        Row(children: [_ActionButton(icon: Icons.play_arrow_rounded, label: 'Play', filled: true, onTap: () {}), const SizedBox(width: 12), _ActionButton(icon: Icons.info_outline_rounded, label: 'More Info', onTap: widget.onDetails)]),
        const SizedBox(height: 18),
        Row(children: List.generate(widget.count, (i) => AnimatedContainer(duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic, margin: const EdgeInsets.only(right: 6), width: widget.index == i ? 24 : 8, height: 8, decoration: BoxDecoration(color: widget.index == i ? AppColors.amber : Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(99))))),
      ])),
    ]);
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double backgroundAlpha;

  const _CircleIcon({required this.icon, required this.onTap, this.backgroundAlpha = 0.10});
  @override
  Widget build(BuildContext context) => _SpringPress(
    onTap: onTap,
  child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: backgroundAlpha),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
          color: filled ? AppColors.textWhite : Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: filled ? Colors.transparent : Colors.white.withValues(alpha: 0.15)),
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
