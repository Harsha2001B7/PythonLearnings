import 'package:flutter/material.dart';

import '../app_motion.dart';

/// Implicit press feedback via [AnimatedScale] (card-style tap).
class PressScale extends StatelessWidget {
  const PressScale({
    super.key,
    required this.pressed,
    required this.child,
    this.scale = AppMotion.pressScaleCard,
    this.duration = AppMotion.pressScaleFast,
    this.curve = Curves.easeOut,
  });

  final bool pressed;
  final Widget child;
  final double scale;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: duration,
      curve: curve,
      scale: pressed ? scale : 1.0,
      child: child,
    );
  }
}

/// Controller-driven press feedback that fires [onTap] on release (button-style).
class PressScaleButton extends StatefulWidget {
  const PressScaleButton({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = AppMotion.pressScaleButton,
    this.duration = AppMotion.pressScaleForward,
    this.reverseDuration = AppMotion.pressScaleReverse,
    this.curve = Curves.easeOutQuad,
  });

  final Widget child;
  final VoidCallback onTap;
  final double pressedScale;
  final Duration duration;
  final Duration reverseDuration;
  final Curve curve;

  @override
  State<PressScaleButton> createState() => _PressScaleButtonState();
}

class _PressScaleButtonState extends State<PressScaleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    try {
      _controller.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
