import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Coloured pill-chip badge variants used across TutorMe.
///
/// ```dart
/// AppBadge.level(label: 'Foundation')
/// AppBadge.status(label: 'Attempted', color: AppColors.success)
/// AppBadge.year(label: 'Nov 2023')
/// AppBadge.marks(label: '5 Marks')
/// AppBadge.subjectCode(label: 'FM-1')
/// ```
class AppBadge extends StatelessWidget {
  const AppBadge._({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  /// CMA level badge — navy/teal gradient feel
  factory AppBadge.level({
    Key? key,
    required String label,
  }) =>
      AppBadge._(
        key: key,
        label: label,
        backgroundColor: AppColors.lightBlueTint,
        textColor: AppColors.navy,
      );

  /// Generic status badge — pass any semantic colour
  factory AppBadge.status({
    Key? key,
    required String label,
    Color backgroundColor = AppColors.success,
    Color textColor = Colors.white,
    Widget? icon,
  }) =>
      AppBadge._(
        key: key,
        label: label,
        backgroundColor: backgroundColor,
        textColor: textColor,
        icon: icon,
      );

  /// Exam year / session badge — amber tint
  factory AppBadge.year({
    Key? key,
    required String label,
  }) =>
      AppBadge._(
        key: key,
        label: label,
        backgroundColor: AppColors.amberLight,
        textColor: AppColors.warning,
      );

  /// Marks badge — gold tint
  factory AppBadge.marks({
    Key? key,
    required String label,
  }) =>
      AppBadge._(
        key: key,
        label: label,
        backgroundColor: const Color(0xFFFFF3CD),
        textColor: AppColors.gold,
      );

  /// Subject code badge — navy on light tint
  factory AppBadge.subjectCode({
    Key? key,
    required String label,
  }) =>
      AppBadge._(
        key: key,
        label: label,
        backgroundColor: AppColors.navy.withValues(alpha: 0.08),
        textColor: AppColors.navy,
      );

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTextStyles.labelBold.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
