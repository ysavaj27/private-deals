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

/// Elevation tokens — theme prefers flat surfaces; keep a small set.
abstract final class AppElevation {
  static const double none = 0;
  static const double low = 1;
  static const double medium = 8;
}
