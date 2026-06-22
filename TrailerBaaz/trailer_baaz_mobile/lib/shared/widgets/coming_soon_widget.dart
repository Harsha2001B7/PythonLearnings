import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ComingSoonWidget extends StatelessWidget {
  final IconData icon;
  final String title;

  const ComingSoonWidget({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 56, color: AppColors.primaryRed),
                const SizedBox(height: 20),
                Text(title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text(
                  'Coming Soon',
                  style: textTheme.titleMedium?.copyWith(color: AppColors.textGrey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
