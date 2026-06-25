import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';
import '../../../../shared/widgets/glass_surfaces.dart';

class TrailerPlayerScreen extends StatefulWidget {
  final TrailerModel trailer;

  const TrailerPlayerScreen({super.key, required this.trailer});

  @override
  State<TrailerPlayerScreen> createState() => _TrailerPlayerScreenState();
}

class _TrailerPlayerScreenState extends State<TrailerPlayerScreen> {
  YoutubePlayerController? _controller;
  bool _muted = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _bootstrapController();
  }

  void _bootstrapController() {
    final videoId = YoutubePlayerController.convertUrlToId(
      widget.trailer.youtubeUrl,
    );
    if (videoId == null) {
      setState(() => _failed = true);
      return;
    }

    final controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: YoutubePlayerParams(
        mute: _muted,
        showControls: true,
        showFullscreenButton: false,
        enableCaption: false,
        showVideoAnnotations: false,
        playsInline: true,
        loop: false,
        strictRelatedVideos: true,
        privacyEnhancedMode: true,
      ),
    );

    _controller = controller;
  }

  @override
  void dispose() {
    unawaited(_controller?.close());
    super.dispose();
  }

  Future<void> _toggleMute() async {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _muted = !_muted);
    if (_muted) {
      await controller.mute();
    } else {
      await controller.unMute();
    }
  }

  void _toggleFullscreen() {
    _controller?.toggleFullScreen();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  _ActionChip(
                    icon: Icons.arrow_back_rounded,
                    label: 'Back',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  _ActionChip(
                    icon: _muted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    label: _muted ? 'Muted' : 'Sound on',
                    onTap: _toggleMute,
                  ),
                  const SizedBox(width: 10),
                  _ActionChip(
                    icon: Icons.fullscreen_rounded,
                    label: 'Fullscreen',
                    onTap: _toggleFullscreen,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _failed || controller == null
                      ? _TrailerFallback(trailer: widget.trailer)
                      : YoutubeValueBuilder(
                          controller: controller,
                          builder: (context, value) {
                            if (value.hasError) {
                              if (!_failed) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) {
                                    setState(() => _failed = true);
                                  }
                                });
                              }
                              return _TrailerFallback(trailer: widget.trailer);
                            }

                            return YoutubePlayer(
                              controller: controller,
                              aspectRatio: 16 / 9,
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.trailer.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MetaBadge(label: widget.trailer.language),
                          _MetaBadge(label: widget.trailer.genre),
                          _MetaBadge(label: widget.trailer.industry),
                          _MetaBadge(label: widget.trailer.releaseYear),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Text(
                          widget.trailer.overview,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            height: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _PrimaryAction(
                              icon: Icons.play_arrow_rounded,
                              label: 'Play now',
                              onTap: () => controller?.playVideo(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SecondaryAction(
                              icon: Icons.bookmark_add_outlined,
                              label: 'Save',
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPillButton(label: label, icon: icon, onTap: onTap);
  }
}

class _MetaBadge extends StatelessWidget {
  final String label;

  const _MetaBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textWhite,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrimaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.amber.withValues(alpha: 0.9),
        foregroundColor: AppColors.background,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textWhite,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _TrailerFallback extends StatelessWidget {
  final TrailerModel trailer;

  const _TrailerFallback({required this.trailer});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          trailer.imageUrl,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xEE000000)],
            ),
          ),
        ),
        const Center(
          child: Icon(
            Icons.play_circle_fill_rounded,
            color: AppColors.textWhite,
            size: 72,
          ),
        ),
      ],
    );
  }
}
