import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// TutorMe typography system.
///
/// - Display / Heading → Playfair Display
/// - Body / UI          → DM Sans
/// - Monospace / IDs    → JetBrains Mono
class AppTextStyles {
  AppTextStyles._();

  // ── Display (Playfair Display) ────────────────────────────────────────────

  /// 32 px · Bold · Navy
  static TextStyle get displayLarge => GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
        height: 1.2,
        letterSpacing: -0.5,
      );

  /// 26 px · Bold · Navy
  static TextStyle get displayMedium => GoogleFonts.playfairDisplay(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
        height: 1.25,
        letterSpacing: -0.3,
      );

  /// 22 px · Bold · Navy
  static TextStyle get displaySmall => GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
        height: 1.3,
      );

  // ── Headings (DM Sans) ────────────────────────────────────────────────────

  /// 20 px · SemiBold · Navy
  static TextStyle get headingLarge => GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
        height: 1.35,
      );

  /// 18 px · SemiBold · Navy
  static TextStyle get headingMedium => GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
        height: 1.4,
      );

  /// 16 px · SemiBold · Navy
  static TextStyle get headingSmall => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
        height: 1.4,
      );

  // ── Body (DM Sans) ────────────────────────────────────────────────────────

  /// 15 px · Regular · textPrimary
  static TextStyle get bodyLarge => GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.55,
      );

  /// 14 px · Regular · textPrimary
  static TextStyle get bodyMedium => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.55,
      );

  /// 13 px · Regular · textSecondary
  static TextStyle get bodySmall => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // ── Caption & Labels (DM Sans) ────────────────────────────────────────────

  /// 12 px · Regular · textSecondary
  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.45,
      );

  /// 13 px · SemiBold · Navy — used for chip/badge labels
  static TextStyle get labelBold => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
        height: 1.4,
        letterSpacing: 0.1,
      );

  /// 14 px · SemiBold · White — button label
  static TextStyle get buttonLabel => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.15,
      );

  // ── Monospace (JetBrains Mono) ────────────────────────────────────────────

  /// 13 px · Regular — for codes, IDs, roll numbers
  static TextStyle get monospace => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  // ── Helper ────────────────────────────────────────────────────────────────

  /// Returns the DM Sans [TextTheme] wired up for [ThemeData].
  static TextTheme get textTheme => GoogleFonts.dmSansTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32),
          displayMedium: TextStyle(fontSize: 26),
          displaySmall: TextStyle(fontSize: 22),
          headlineLarge: TextStyle(fontSize: 20),
          headlineMedium: TextStyle(fontSize: 18),
          headlineSmall: TextStyle(fontSize: 16),
          bodyLarge: TextStyle(fontSize: 15),
          bodyMedium: TextStyle(fontSize: 14),
          bodySmall: TextStyle(fontSize: 13),
          labelLarge: TextStyle(fontSize: 13),
          labelMedium: TextStyle(fontSize: 12),
        ),
      );
}
