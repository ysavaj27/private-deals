import 'package:flutter/material.dart';

/// Shared motion tokens for subtle, consistent UI animations.
///
/// All new animations should go through [duration] so reduced-motion
/// (`MediaQuery.disableAnimations`) is respected.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration dialog = Duration(milliseconds: 220);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOut;

  /// Soft press scale — shrinks slightly so it stays within parent bounds.
  static const double pressScale = 0.98;

  /// Tiny dialog entrance scale (fade + scale).
  static const double dialogScaleBegin = 0.98;

  /// Returns [preferred] or [Duration.zero] when animations are disabled.
  static Duration duration(BuildContext context, Duration preferred) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Duration.zero;
    }
    return preferred;
  }

  static bool reduceMotion(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}
