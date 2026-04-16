import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Shimmer skeleton loaders for TutorMe.
///
/// ```dart
/// AppLoading.textLine()
/// AppLoading.card()
/// AppLoading.listItem()
/// AppLoading.grid(itemCount: 6)
/// ```
class AppLoading extends StatelessWidget {
  const AppLoading._({
    super.key,
    required this.child,
  });

  /// Single text line skeleton.
  factory AppLoading.textLine({
    Key? key,
    double width = double.infinity,
    double height = 14,
  }) =>
      AppLoading._(
        key: key,
        child: _ShimmerBox(width: width, height: height, radius: 6),
      );

  /// Full card skeleton.
  factory AppLoading.card({Key? key}) => AppLoading._(
        key: key,
        child: _SkeletonCard(),
      );

  /// List item skeleton (avatar + two text lines).
  factory AppLoading.listItem({Key? key}) => AppLoading._(
        key: key,
        child: _SkeletonListItem(),
      );

  /// Grid of [itemCount] card skeletons.
  factory AppLoading.grid({
    Key? key,
    int itemCount = 6,
    int crossAxisCount = 2,
  }) =>
      AppLoading._(
        key: key,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.4,
          ),
          itemBuilder: (_, __) => _SkeletonCard(),
        ),
      );

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.lightBlueTint,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

// ── Private skeleton building blocks ─────────────────────────────────────────

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _ShimmerBox(width: 80, height: 10),
            SizedBox(height: AppSpacing.md),
            _ShimmerBox(width: double.infinity, height: 14),
            SizedBox(height: AppSpacing.sm),
            _ShimmerBox(width: 140, height: 14),
            SizedBox(height: AppSpacing.lg),
            Row(children: [
              _ShimmerBox(width: 60, height: 24, radius: 24),
              SizedBox(width: AppSpacing.sm),
              _ShimmerBox(width: 60, height: 24, radius: 24),
            ]),
          ],
        ),
      );
}

class _SkeletonListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            const _ShimmerBox(width: 48, height: 48, radius: 48),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _ShimmerBox(width: double.infinity, height: 14),
                  SizedBox(height: AppSpacing.sm),
                  _ShimmerBox(width: 120, height: 12),
                ],
              ),
            ),
          ],
        ),
      );
}
