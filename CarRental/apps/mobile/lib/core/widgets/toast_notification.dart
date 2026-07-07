import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ToastNotification {
  static void show(
    BuildContext context,
    String message, {
    String type = 'success',
  }) {
    Color accentColor;
    IconData icon;

    switch (type) {
      case 'error':
        accentColor = AppColors.danger;
        icon = Icons.error_outline_rounded;
        break;
      case 'info':
        accentColor = AppColors.amber;
        icon = Icons.info_outline_rounded;
        break;
      case 'success':
      default:
        accentColor = AppColors.success;
        icon = Icons.check_circle_outline_rounded;
        break;
    }

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      duration: const Duration(milliseconds: 3000),
      content: Container(
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.08),
              offset: const Offset(0, 8),
              blurRadius: 24.0,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                message,
                style: AppTypography.headingSmall(color: AppColors.ink),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(snackBar);
  }
}
