import 'package:flutter/widgets.dart';

/// Design tokens for spacing. Use these instead of magic numbers so padding
/// and gaps stay consistent across the app.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Common page padding.
  static const EdgeInsets page = EdgeInsets.all(md);
}

/// Design tokens for corner radii.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;

  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
}
