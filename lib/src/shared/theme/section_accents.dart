import 'package:flutter/material.dart';

/// Soft product-section accents (PE / LP Secondary / Unlisted).
/// Kept as intentional differentiators on top of the unified blue brand.
@immutable
class SectionAccents extends ThemeExtension<SectionAccents> {
  const SectionAccents({
    required this.privateEquity,
    required this.lpSecondary,
    required this.unlistedShares,
  });

  final Color privateEquity;
  final Color lpSecondary;
  final Color unlistedShares;

  /// Soft olive / teal / lavender — intentional section markers.
  static const light = SectionAccents(
    privateEquity: Color(0xFFBDB999),
    lpSecondary: Color(0xFF57B1C4),
    unlistedShares: Color(0xFF9D95CA),
  );

  static const dark = SectionAccents(
    privateEquity: Color(0xFFC9C5A8),
    lpSecondary: Color(0xFF6DC4D4),
    unlistedShares: Color(0xFFB0A8DB),
  );

  Color byIndex(int index) {
    switch (index) {
      case 0:
        return privateEquity;
      case 1:
        return lpSecondary;
      case 2:
        return unlistedShares;
      default:
        return privateEquity;
    }
  }

  @override
  SectionAccents copyWith({
    Color? privateEquity,
    Color? lpSecondary,
    Color? unlistedShares,
  }) {
    return SectionAccents(
      privateEquity: privateEquity ?? this.privateEquity,
      lpSecondary: lpSecondary ?? this.lpSecondary,
      unlistedShares: unlistedShares ?? this.unlistedShares,
    );
  }

  @override
  SectionAccents lerp(ThemeExtension<SectionAccents>? other, double t) {
    if (other is! SectionAccents) return this;
    return SectionAccents(
      privateEquity: Color.lerp(privateEquity, other.privateEquity, t)!,
      lpSecondary: Color.lerp(lpSecondary, other.lpSecondary, t)!,
      unlistedShares: Color.lerp(unlistedShares, other.unlistedShares, t)!,
    );
  }
}

extension SectionAccentsX on BuildContext {
  SectionAccents get sectionAccents =>
      Theme.of(this).extension<SectionAccents>() ?? SectionAccents.light;
}
