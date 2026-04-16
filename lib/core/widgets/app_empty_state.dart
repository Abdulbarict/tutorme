import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Full-page or inline empty state with illustration, heading, body and
/// optional CTA button.
///
/// ```dart
/// AppEmptyState(
///   svgAsset: 'assets/svg/empty_questions.svg',
///   heading: 'No Questions Yet',
///   body: 'Questions will appear once you select a chapter.',
///   actionLabel: 'Browse Subjects',
///   onAction: () {},
/// )
/// ```
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    this.svgAsset,
    required this.heading,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.illustrationSize = 200,
  });

  /// Path to an SVG asset, e.g. `'assets/svg/empty_bookmarks.svg'`.
  /// If null, a default placeholder icon is shown.
  final String? svgAsset;

  final String heading;
  final String body;

  /// Label for the CTA button. Requires [onAction].
  final String? actionLabel;
  final VoidCallback? onAction;
  final double illustrationSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxxl,
          vertical: AppSpacing.xxxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Illustration ───────────────────────────────────────────
            if (svgAsset != null)
              SvgPicture.asset(
                svgAsset!,
                width: illustrationSize,
                height: illustrationSize,
              )
            else
              Container(
                width: illustrationSize,
                height: illustrationSize,
                decoration: BoxDecoration(
                  color: AppColors.lightBlueTint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox_rounded,
                  size: illustrationSize * 0.4,
                  color: AppColors.navy.withValues(alpha: 0.4),
                ),
              ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Heading ────────────────────────────────────────────────
            Text(
              heading,
              textAlign: TextAlign.center,
              style: AppTextStyles.displaySmall,
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Body ───────────────────────────────────────────────────
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            // ── CTA Button ─────────────────────────────────────────────
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxxl),
              AppButton.primary(
                label: actionLabel!,
                onPressed: onAction,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
