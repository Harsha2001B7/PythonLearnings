import 'package:flutter/material.dart';

class AppColors {
  // ── Surface / Warm Paper ──────────────────────────────────────────
  static const Color paper = Color(0xFFF8F6F2);       // Base Warm Parchment
  static const Color paperSoft = Color(0xFFF0EDE7);   // Recessed surfaces / cards
  static const Color panel = Color(0xFFFFFFFF);       // Panel / dialog bg
  static const Color border = Color(0xFFE4DED4);      // Key divider lines and card borders

  // ── Ink Typography ──────────────────────────────────────────────
  static const Color ink = Color(0xFF0E0E0C);         // Title headings / dark text
  static const Color inkMuted = Color(0xFF6B6558);    // Subtitle body text
  static const Color inkSubtle = Color(0xFF9C9589);   // Inactive fields / placeholders

  // ── Premium Amber Accents ───────────────────────────────────────
  static const Color amber = Color(0xFFC8873A);       // CTA active buttons
  static const Color amberLight = Color(0xFFE5A75A);  // Pressed/hover states
  static const Color amberPale = Color(0xFFFDF3E7);   // Highlight area backgrounds
  static const Color amberGlow = Color(0x33C8873A);   // Radial glow (20% opacity)

  // ── Alert Statuses ──────────────────────────────────────────────
  static const Color success = Color(0xFF2D7A4F);
  static const Color danger = Color(0xFFC0392B);

  // ── Luxury Gradients & Shimmer ──────────────────────────────────
  static const RadialGradient heroRadialGlow = RadialGradient(
    center: Alignment(0.75, -0.8),
    radius: 1.5,
    colors: [
      Color(0x1FC8873A), // 12% opacity amber
      Colors.transparent,
    ],
  );

  static const LinearGradient cardShimmer = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x0FC8873A), // 6% opacity amber
      Colors.transparent,
    ],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );
}
