import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';

/// A circular icon button in the top-right corner of every screen
/// that toggles between dark and light mode.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(themeModeProvider.notifier);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return IconButton(
      onPressed: notifier.toggle,
      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      style: IconButton.styleFrom(
        backgroundColor: isDark ? AppColors.surface2Dark : AppColors.surface2Light,
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(8),
      ),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
          size: 20,
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
      ),
    );
  }
}
