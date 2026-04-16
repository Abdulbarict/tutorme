import 'package:flutter/material.dart';

/// TutorMe spacing system — based on an 4px grid.
///
/// Usage: `SizedBox(height: AppSpacing.lg)`
class AppSpacing {
  AppSpacing._();

  /// 4 px
  static const double xs = 4.0;

  /// 8 px
  static const double sm = 8.0;

  /// 12 px
  static const double md = 12.0;

  /// 16 px
  static const double lg = 16.0;

  /// 20 px
  static const double xl = 20.0;

  /// 24 px
  static const double xxl = 24.0;

  /// 32 px
  static const double xxxl = 32.0;

  /// 40 px
  static const double xxxxl = 40.0;

  /// 48 px
  static const double xxxxxl = 48.0;
}

/// Border radius tokens.
class AppRadius {
  AppRadius._();

  /// 8 px — small elements
  static const double sm = 8.0;

  /// 10 px — inputs
  static const double input = 10.0;

  /// 12 px — buttons
  static const double button = 12.0;

  /// 16 px — cards
  static const double card = 16.0;

  /// 24 px — chips / badges
  static const double chip = 24.0;

  /// 50 % — avatar (use with [BorderRadius.circular] and a static size)
  static const double avatar = 9999.0;
}

/// Elevation / shadow token.
class AppShadow {
  AppShadow._();

  /// Standard card shadow — `0 4px 16px rgba(15,45,94,0.08)`
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x140F2D5E), // 0.08 alpha on navy
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Heavier shadow for modals / bottom sheets
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x260F2D5E),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];
}
