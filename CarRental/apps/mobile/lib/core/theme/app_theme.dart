import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.paper,
      primaryColor: AppColors.amber,
      colorScheme: const ColorScheme.light(
        primary: AppColors.amber,
        onPrimary: Colors.white,
        secondary: AppColors.amberLight,
        onSecondary: Colors.white,
        surface: AppColors.panel,
        onSurface: AppColors.ink,
        error: AppColors.danger,
        onError: Colors.white,
      ),
      dividerColor: AppColors.border,
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1.0,
        space: 1.0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.ink, size: 20),
        titleTextStyle: AppTypography.headingMedium(color: AppColors.ink),
      ),
      cardTheme: CardThemeData(
        color: AppColors.panel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.panel,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paperSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.amber, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        labelStyle: AppTypography.bodyMedium(color: AppColors.inkMuted),
        hintStyle: AppTypography.bodyMedium(color: AppColors.inkSubtle),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.amber,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

  // Future-ready dark theme (standard Material dark themed with matching amber accents)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0E0E0C),
      primaryColor: AppColors.amber,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.amber,
        onPrimary: Colors.white,
        secondary: AppColors.amberLight,
        onSecondary: Colors.white,
        surface: Color(0xFF1A1A18),
        onSurface: Color(0xFFF8F6F2),
        error: AppColors.danger,
        onError: Colors.white,
      ),
      dividerColor: const Color(0xFF2A2A28),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFFF8F6F2)),
      ),
    );
  }
}
