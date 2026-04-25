// ── Password strength indicator ───────────────────────────────────────────────
// Used in SignupScreen below the password field.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

enum PasswordStrength { empty, weak, fair, strong }

class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final strength = _evaluate(password);
    if (strength == PasswordStrength.empty) return const SizedBox.shrink();

    final (color, label) = switch (strength) {
      PasswordStrength.weak => (AppColors.error, 'Weak'),
      PasswordStrength.fair => (AppColors.warning, 'Fair'),
      PasswordStrength.strong => (AppColors.success, 'Strong'),
      _ => (AppColors.border, ''),
    };

    final fill = switch (strength) {
      PasswordStrength.weak => 0.33,
      PasswordStrength.fair => 0.66,
      PasswordStrength.strong => 1.0,
      _ => 0.0,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: fill),
            duration: const Duration(milliseconds: 300),
            builder: (_, value, __) => LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.border,
              color: color,
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Password strength: $label',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static PasswordStrength _evaluate(String pw) {
    if (pw.isEmpty) return PasswordStrength.empty;
    int score = 0;
    if (pw.length >= 8) score++;
    if (pw.contains(RegExp(r'[A-Z]'))) score++;
    if (pw.contains(RegExp(r'[0-9]'))) score++;
    if (pw.contains(RegExp(r'[^A-Za-z0-9]'))) score++;
    return switch (score) {
      >= 4 => PasswordStrength.strong,
      >= 2 => PasswordStrength.fair,
      _ => PasswordStrength.weak,
    };
  }
}

// ── Email validation suffix icon ──────────────────────────────────────────────

/// Inline green checkmark when email is valid, nothing otherwise.
Widget? emailSuffixIcon(String email) {
  final valid = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  if (!valid) return null;
  return const Icon(Icons.check_circle_rounded,
      color: AppColors.success, size: 20);
}
