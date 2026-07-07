import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isGhost;
  final Widget? icon;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isGhost = false,
    this.icon,
    this.width,
    this.height = 48.0,
  });

  const CustomButton.amber({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width,
    this.height = 48.0,
  }) : isGhost = false;

  const CustomButton.ghost({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width,
    this.height = 48.0,
  }) : isGhost = true;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTypography.buttonText(
      color: widget.isGhost ? AppColors.ink : Colors.white,
    );

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.isGhost ? Colors.transparent : AppColors.amber,
            borderRadius: BorderRadius.circular(24.0),
            border: widget.isGhost
                ? Border.all(color: AppColors.border, width: 1.5)
                : null,
            boxShadow: widget.isGhost
                ? null
                : [
                    BoxShadow(
                      color: AppColors.amber.withValues(alpha: 0.24),
                      offset: const Offset(0, 4),
                      blurRadius: 12.0,
                    ),
                  ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8.0),
              ],
              Text(
                widget.text,
                style: textStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
