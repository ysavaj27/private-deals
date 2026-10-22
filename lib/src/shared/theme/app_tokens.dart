import 'package:flutter/material.dart';

/// Spacing scale — prefer these over magic EdgeInsets numbers.
abstract final class AppSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalLg =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalMd =
      EdgeInsets.symmetric(horizontal: md);
}

/// Shared desktop shell sizes for wealth manager and seller workspaces.
abstract final class AppShell {
  static const double sidebarWidth = 260;

  /// Fits the LP Secondary / Unlisted product switcher + header actions.
  static const double desktopAppBarHeight = 82;
}

/// Shared page content insets so headers and titles align across screens.
///
/// Always derive from [MediaQuery] window width (not content-area width) so
/// wealth manager and seller pages keep the same gutters on desktop web.
abstract final class AppPagePadding {
  static const double compactBreakpoint = 600;

  /// Desktop page gutter used by WM and seller (same on both sides).
  static const double desktop = 40;

  static bool isCompact(double width) => width < compactBreakpoint;

  static bool compactOf(BuildContext context) =>
      isCompact(MediaQuery.sizeOf(context).width);

  static double horizontalOf(BuildContext context) =>
      compactOf(context) ? AppSpace.lg : desktop;

  /// Prefer [horizontalOf]; kept for call sites that already have a width.
  /// Pass the window width, not the post-sidebar content width.
  static double horizontalFor(double width) =>
      isCompact(width) ? AppSpace.lg : desktop;

  /// Standard page inset: 16/40 horizontal, 24 top, 32 bottom.
  static EdgeInsets of(BuildContext context, {double? bottom}) {
    final horizontal = horizontalOf(context);
    return EdgeInsets.fromLTRB(
      horizontal,
      AppSpace.xl,
      horizontal,
      bottom ?? AppSpace.xxl,
    );
  }

  /// Prefer [of]; same inset using an explicit window width.
  static EdgeInsets forWidth(double width, {double? bottom}) {
    final horizontal = horizontalFor(width);
    return EdgeInsets.fromLTRB(
      horizontal,
      AppSpace.xl,
      horizontal,
      bottom ?? AppSpace.xxl,
    );
  }

  /// Horizontal-only inset for pages that manage vertical spacing themselves.
  static EdgeInsets horizontalOnly(BuildContext context) {
    final horizontal = horizontalOf(context);
    return EdgeInsets.symmetric(horizontal: horizontal);
  }
}

/// Corner radius scale aligned with [partner_theme] (12 inputs, 16 cards).
abstract final class AppRadii {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 999;

  static BorderRadius get xsAll => BorderRadius.circular(xs);
  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
  static BorderRadius get pill => BorderRadius.circular(full);
}

/// Window-size layout. iPhone Duo's outer display is a phone. Its inner
/// display is about 669 pt wide in portrait and about 951 pt in landscape,
/// and the size changes when the device folds. The desktop shell needs a
/// full window, so those Duo sizes stay on the compact layout.
abstract final class AppWindow {
  static const double desktopMinWidth = 1024;

  static bool compactWidth(double width) => width < desktopMinWidth;

  static bool compact(BuildContext context) =>
      compactWidth(MediaQuery.sizeOf(context).width);
}

/// Elevation tokens — theme prefers flat surfaces; keep a small set.
abstract final class AppElevation {
  static const double none = 0;
  static const double low = 1;
  static const double medium = 8;
}
