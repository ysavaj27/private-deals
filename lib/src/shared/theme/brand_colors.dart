import 'package:flutter/material.dart';

/// Brand colors sampled from [assets/icons/logo.png]
/// (navy keyhole + gold circuit accents).
abstract final class BrandColors {
  /// Mid navy from the logo keyhole body.
  static const Color navy = Color(0xFF243E61);

  /// Lifted navy for readable filled buttons / links on light surfaces.
  static const Color navyAction = Color(0xFF2B5996);

  /// Lightened navy for dark-mode primary.
  static const Color navyLight = Color(0xFF8BAAD4);

  /// Soft navy wash for light primary containers.
  static const Color navyContainerLight = Color(0xFFD5E2F2);

  /// Soft navy wash for dark primary containers.
  static const Color navyContainerDark = Color(0xFF1A2E48);

  /// Metallic gold from logo circuit accents.
  static const Color gold = Color(0xFFC19767);

  /// Soft gold wash — light secondary container.
  static const Color goldContainerLight = Color(0xFFF3E6D4);

  /// Soft gold wash — dark secondary container.
  static const Color goldContainerDark = Color(0xFF3D3224);

  static const Color onGold = Color(0xFF1F160C);
}

/// Legacy alias — prefer [BrandColors.navyAction].
const partnerActionBlue = BrandColors.navyAction;
