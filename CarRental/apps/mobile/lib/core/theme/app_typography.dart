import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // ── Fraunces (Editorial Display Serif) ──────────────────────────
  static TextStyle displayLarge({Color color = AppColors.ink}) => GoogleFonts.fraunces(
        fontSize: 40,
        fontWeight: FontWeight.w300,
        height: 1.0,
        letterSpacing: -1.0,
        color: color,
      );

  static TextStyle displayMedium({Color color = AppColors.ink}) => GoogleFonts.fraunces(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        height: 1.1,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle displayItalic({Color color = AppColors.amber}) => GoogleFonts.fraunces(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        fontStyle: FontStyle.italic,
        height: 1.1,
        color: color,
      );

  // ── Space Grotesk (Eyebrows, Headings, Subtitles) ─────────────────
  static TextStyle eyebrow({Color color = AppColors.amber}) => GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.0,
        color: color,
      );

  static TextStyle headingLarge({Color color = AppColors.ink}) => GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle headingMedium({Color color = AppColors.ink}) => GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle headingSmall({Color color = AppColors.ink}) => GoogleFonts.spaceGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle buttonText({Color color = Colors.white}) => GoogleFonts.spaceGrotesk(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: color,
      );

  // ── Inter (Clean UI/Body Text) ──────────────────────────────────
  static TextStyle bodyLarge({Color color = AppColors.ink}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMedium({Color color = AppColors.inkMuted}) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        height: 1.55,
        color: color,
      );

  static TextStyle bodySmall({Color color = AppColors.inkSubtle}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: color,
      );

  // ── JetBrains Mono (Dates, Specs, Numbers) ──────────────────────
  static TextStyle monoStyle({Color color = AppColors.inkMuted, double size = 10}) => GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: FontWeight.normal,
        letterSpacing: 1.2,
        color: color,
      );

  static TextStyle monoBold({Color color = AppColors.ink, double size = 10}) => GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: color,
      );
}
