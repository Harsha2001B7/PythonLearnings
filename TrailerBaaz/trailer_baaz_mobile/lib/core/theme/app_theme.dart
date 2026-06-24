import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.amber,
        secondary: AppColors.primaryRed,
        surface: AppColors.surface,
        onPrimary: AppColors.textWhite,
        onSecondary: AppColors.textWhite,
        onSurface: AppColors.textWhite,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textWhite,
        displayColor: AppColors.textWhite,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
      ),
      cardColor: AppColors.card,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.textGrey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
