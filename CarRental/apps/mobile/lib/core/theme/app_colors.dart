import 'package:flutter/material.dart';

/// Design tokens extracted from the HTML prototype (index.html)
class AppColors {
  AppColors._();

  // ─── Brand ───────────────────────────────────────────
  static const Color orange = Color(0xFFFF6600);
  static const Color orangeLight = Color(0xFFFF8033);
  static const Color orangeDim = Color(0x26FF6600); // rgba(255,102,0,0.15)
  static const Color orangeGlow = Color(0x40FF6600); // rgba(255,102,0,0.25)
  static const Color gold = Color(0xFFC9A84C);

  // ─── Dark theme ──────────────────────────────────────
  static const Color bgDark = Color(0xFF0D0D0D);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surface2Dark = Color(0xFF242424);
  static const Color surface3Dark = Color(0xFF2E2E2E);
  static const Color borderDark = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color borderMidDark = Color(0x1EFFFFFF); // rgba(255,255,255,0.12)
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color textSecDark = Color(0xFFB0B0B0);
  static const Color textMutedDark = Color(0xFF6B6B6B);

  // ─── Light theme ─────────────────────────────────────
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surface2Light = Color(0xFFF1F3F5);
  static const Color surface3Light = Color(0xFFE9ECEF);
  static const Color borderLight = Color(0x14000000); // rgba(0,0,0,0.08)
  static const Color borderMidLight = Color(0x1E000000); // rgba(0,0,0,0.12)
  static const Color textLight = Color(0xFF1A1A1A);
  static const Color textSecLight = Color(0xFF495057);
  static const Color textMutedLight = Color(0xFF868E96);

  // ─── Semantic ────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successDim = Color(0x2622C55E); // rgba(34,197,94,0.15)
  static const Color error = Color(0xFFEF4444);
  static const Color errorDim = Color(0x26EF4444); // rgba(239,68,68,0.15)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDim = Color(0x26F59E0B); // rgba(245,158,11,0.15)
}
