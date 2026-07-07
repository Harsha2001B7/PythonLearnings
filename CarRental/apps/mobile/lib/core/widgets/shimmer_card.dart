import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ShimmerCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool borderHighlight;

  const ShimmerCard({
    super.key,
    required this.child,
    this.onTap,
    this.width,
    this.height,
    this.borderRadius,
    this.borderHighlight = false,
  });

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _translateAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _translateAnimation = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter() => _controller.forward();
  void _onExit() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final defaultRadius = widget.borderRadius ?? BorderRadius.circular(16.0);

    return MouseRegion(
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: GestureDetector(
        onTapDown: (_) => _onEnter(),
        onTapUp: (_) {
          _onExit();
          if (widget.onTap != null) widget.onTap!();
        },
        onTapCancel: () => _onExit(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _translateAnimation.value),
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: defaultRadius,
                  border: Border.all(
                    color: Color.lerp(
                      AppColors.border,
                      AppColors.amber.withValues(alpha: 0.55),
                      widget.borderHighlight ? 1.0 : _glowAnimation.value,
                    )!,
                    width: widget.borderHighlight ? 1.8 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withValues(
                        alpha: 0.05 + (_glowAnimation.value * 0.04),
                      ),
                      offset: Offset(0, 4 + (_glowAnimation.value * 6)),
                      blurRadius: 12.0 + (_glowAnimation.value * 12),
                    ),
                    if (_glowAnimation.value > 0)
                      BoxShadow(
                        color: AppColors.amber.withValues(alpha: _glowAnimation.value * 0.1),
                        offset: Offset.zero,
                        blurRadius: 2.0,
                        spreadRadius: 1.0,
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: defaultRadius,
                  child: widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
