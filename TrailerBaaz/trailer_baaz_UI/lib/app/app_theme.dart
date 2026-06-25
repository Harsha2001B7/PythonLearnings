import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF090909);
  static const card = Color(0xFF151515);
  static const cardAlt = Color(0xFF1F1A22);
  static const accent = Color(0xFFE50914);
  static const hype = Color(0xFFFFC531);
  static const muted = Color(0xFFA9A9A9);

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: hype,
        surface: card,
        onSurface: Colors.white,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xFF8C8C8C),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0xFF1A1A1A),
        selectedColor: accent.withValues(alpha: .18),
        side: const BorderSide(color: Color(0xFF303030)),
        labelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      ),
    );
  }
}
