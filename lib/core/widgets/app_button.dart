import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// TutorMe button system — three named constructors.
///
/// ```dart
/// AppButton.primary(label: 'Continue', onPressed: () {})
/// AppButton.secondary(label: 'Skip', onPressed: () {})
/// AppButton.ghost(label: 'Back', onPressed: () {})
/// ```
class AppButton extends StatefulWidget {
  const AppButton._({
    super.key,
    required this.label,
    required this.onPressed,
    required this.variant,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.height = 52,
  });

  /// Navy fill · White text · Gold shimmer on press
  factory AppButton.primary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    Widget? icon,
    bool fullWidth = true,
    double height = 52,
  }) =>
      AppButton._(
        key: key,
        label: label,
        onPressed: onPressed,
        variant: _Variant.primary,
        isLoading: isLoading,
        icon: icon,
        fullWidth: fullWidth,
        height: height,
      );

  /// Gold fill · Navy text
  factory AppButton.secondary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    Widget? icon,
    bool fullWidth = true,
    double height = 52,
  }) =>
      AppButton._(
        key: key,
        label: label,
        onPressed: onPressed,
        variant: _Variant.secondary,
        isLoading: isLoading,
        icon: icon,
        fullWidth: fullWidth,
        height: height,
      );

  /// Transparent · Navy border + text
  factory AppButton.ghost({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    Widget? icon,
    bool fullWidth = true,
    double height = 52,
  }) =>
      AppButton._(
        key: key,
        label: label,
        onPressed: onPressed,
        variant: _Variant.ghost,
        isLoading: isLoading,
        icon: icon,
        fullWidth: fullWidth,
        height: height,
      );

  final String label;
  final VoidCallback? onPressed;
  final _Variant variant;
  final bool isLoading;
  final Widget? icon;
  final bool fullWidth;
  final double height;

  @override
  State<AppButton> createState() => _AppButtonState();
}

enum _Variant { primary, secondary, ghost }

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shimmerAnim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.variant == _Variant.primary) {
      _shimmerCtrl.forward(from: 0);
    }
  }

  // ── config helpers ──────────────────────────────────────────────────────

  Color get _bgColor => switch (widget.variant) {
        _Variant.primary => AppColors.navy,
        _Variant.secondary => AppColors.gold,
        _Variant.ghost => Colors.transparent,
      };

  Color get _fgColor => switch (widget.variant) {
        _Variant.primary => Colors.white,
        _Variant.secondary => AppColors.navy,
        _Variant.ghost => AppColors.navy,
      };

  Border? get _border => widget.variant == _Variant.ghost
      ? Border.all(color: AppColors.navy, width: 1.5)
      : null;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.isLoading;

    Widget label = Text(
      widget.label,
      style: AppTextStyles.buttonLabel.copyWith(color: _fgColor),
    );

    if (widget.icon != null) {
      label = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.icon!,
          const SizedBox(width: AppSpacing.sm),
          label,
        ],
      );
    }

    Widget content = widget.isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(_fgColor),
            ),
          )
        : label;

    // Gold shimmer overlay (primary only)
    if (widget.variant == _Variant.primary) {
      content = AnimatedBuilder(
        animation: _shimmerAnim,
        builder: (context, child) => ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(_shimmerAnim.value - 0.3, 0),
            end: Alignment(_shimmerAnim.value + 0.3, 0),
            colors: [
              Colors.transparent,
              AppColors.goldLight.withValues(alpha: 0.35),
              Colors.transparent,
            ],
          ).createShader(bounds),
          blendMode: BlendMode.overlay,
          child: child,
        ),
        child: content,
      );
    }

    final button = GestureDetector(
      onTapDown: _onTapDown,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: widget.height,
        width: widget.fullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: disabled
              ? (widget.variant == _Variant.ghost
                  ? Colors.transparent
                  : AppColors.border)
              : _bgColor,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: _border,
          boxShadow: disabled || widget.variant == _Variant.ghost
              ? null
              : [
                  BoxShadow(
                    color: _bgColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: disabled ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(AppRadius.button),
            splashColor: _fgColor.withValues(alpha: 0.12),
            child: Center(child: content),
          ),
        ),
      ),
    );

    return button;
  }
}
