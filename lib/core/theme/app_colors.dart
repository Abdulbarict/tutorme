import 'package:flutter/material.dart';

/// TutorMe design system colour palette.
/// All colours are immutable constants — never hard-code hex values elsewhere.
class AppColors {
  AppColors._();

  // ── Primary Navy ──────────────────────────────────────────────────────────
  static const Color navy = Color(0xFF0F2D5E);
  static const Color navyLight = Color(0xFF1A4A8A);
  static const Color navyDark = Color(0xFF0A1F3D);

  // ── Gold Accent ───────────────────────────────────────────────────────────
  static const Color gold = Color(0xFFC9993A);
  static const Color goldLight = Color(0xFFE8C97A);

  // ── Backgrounds & Surfaces ────────────────────────────────────────────────
  static const Color background = Color(0xFFF4F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color lightBlueTint = Color(0xFFEEF2FF);
  static const Color amberLight = Color(0xFFFFF8F0);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF1A7F5A);
  static const Color error = Color(0xFFC0392B);
  static const Color warning = Color(0xFFE67E22);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);

  // ── Border ────────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);

  // ── Gradient helpers ─────────────────────────────────────────────────────
  static const Color navyGradientStart = Color(0xFF0F2D5E);
  static const Color navyGradientEnd = Color(0xFF1A4A8A);

  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyGradientStart, navyGradientEnd],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, goldLight],
  );
}
