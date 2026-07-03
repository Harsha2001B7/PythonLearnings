import 'package:flutter/material.dart';

/// A base shimmer widget that drives a looping brightness animation.
///
/// Provide a [builder] callback that receives the current shimmer [Color]
/// and returns the skeleton UI. This is the animation engine; use
/// [HomeSectionShimmer] (or other named variants) for the actual layout.
///
/// Example:
/// ```dart
/// LoadingShimmer(
///   builder: (context, shimmerColor) => Container(
///     width: 200,
///     height: 100,
///     color: shimmerColor,
///   ),
/// )
/// ```
class LoadingShimmer extends StatefulWidget {
  const LoadingShimmer({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 1200),
    this.baseColor = const Color(0xFF1A1A1A),
    this.highlightColor = const Color(0xFF2A2A2A),
  });

  /// Called each animation frame with the interpolated shimmer color.
  final Widget Function(BuildContext context, Color shimmerColor) builder;

  /// Duration of one shimmer pulse (base → highlight → base).
  final Duration duration;

  /// Darker base color of the shimmer pulse.
  final Color baseColor;

  /// Lighter highlight color of the shimmer pulse.
  final Color highlightColor;

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl!, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    try {
      _ctrl?.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final shimmerColor = Color.lerp(
          widget.baseColor,
          widget.highlightColor,
          _anim.value,
        )!;
        return widget.builder(context, shimmerColor);
      },
    );
  }
}
