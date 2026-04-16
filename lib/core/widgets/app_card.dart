import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A premium white card with soft navy shadow.
///
/// ```dart
/// AppCard(
///   onTap: () {},
///   borderLeft: AppColors.gold,
///   child: Text('Hello'),
/// )
/// ```
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderLeft,
    this.borderRadius,
    this.margin,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  /// If non-null, renders a coloured left border accent (4 px wide).
  final Color? borderLeft;

  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.card;
    final effectivePadding = padding ??
        const EdgeInsets.all(AppSpacing.lg);

    Widget content = Padding(padding: effectivePadding, child: child);

    if (borderLeft != null) {
      content = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: borderLeft,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radius),
                  bottomLeft: Radius.circular(radius),
                ),
              ),
            ),
            Expanded(child: content),
          ],
        ),
      );
    }

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppShadow.card,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: AppColors.navy.withValues(alpha: 0.05),
        highlightColor: AppColors.navy.withValues(alpha: 0.03),
        child: card,
      ),
    );
  }
}
