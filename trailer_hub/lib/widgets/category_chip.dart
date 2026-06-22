import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Category Chip Widget
/// Displays a category as a chip with icon and text

class CategoryChip extends StatefulWidget {
  final String label;
  final String? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final Color? unselectedColor;

  const CategoryChip({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    required this.onTap,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor =
        widget.selectedColor ?? AppTheme.primaryColor;
    final unselectedColor = widget.unselectedColor ??
        (isDark ? AppTheme.darkSurfaceColor : AppTheme.backgroundColor);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingMd,
          vertical: AppTheme.paddingSm,
        ),
        decoration: BoxDecoration(
          color: widget.isSelected ? selectedColor : unselectedColor,
          border: Border.all(
            color: widget.isSelected
                ? selectedColor
                : (isDark ? AppTheme.darkSurfaceColor : Colors.grey[300]!),
            width: widget.isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon (if provided)
            if (widget.icon != null) ...[
              Text(
                widget.icon!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
            ],

            // Label
            Text(
              widget.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: widget.isSelected
                        ? Colors.white
                        : (isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
