import 'package:flutter/material.dart';

import 'package:private_deals/src/shared/theme/brand_colors.dart';
import 'package:private_deals/src/shared/theme/section_accents.dart';
import 'package:private_deals/src/shared/theme/app_picker_theme.dart';

export 'package:private_deals/src/shared/theme/brand_colors.dart' show BrandColors, partnerActionBlue;

abstract final class LightTheme {
  static final colorScheme = ColorScheme.fromSeed(
    seedColor: BrandColors.navyAction,
    brightness: Brightness.light,
    secondary: BrandColors.gold,
  ).copyWith(
    primary: BrandColors.navyAction,
    onPrimary: Colors.white,
    primaryContainer: BrandColors.navyContainerLight,
    onPrimaryContainer: BrandColors.navy,
    secondary: BrandColors.gold,
    onSecondary: BrandColors.onGold,
    secondaryContainer: BrandColors.goldContainerLight,
    onSecondaryContainer: BrandColors.onGold,
    // Navy-tinted surface ladder — scaffold ≠ card ≠ elevated.
    surface: const Color(0xFFF7F9FC),
    onSurface: const Color(0xFF1A2233),
    onSurfaceVariant: const Color(0xFF5A6578),
    surfaceContainerLowest: const Color(0xFFF7F9FC),
    surfaceContainerLow: const Color(0xFFE4E9F1),
    surfaceContainer: const Color(0xFFD8DEE8),
    surfaceContainerHigh: const Color(0xFFCDD5E2),
    surfaceContainerHighest: const Color(0xFFC0CAD9),
    outline: const Color(0xFF6B7589),
    outlineVariant: const Color(0xFFB8C2D1),
    error: const Color(0xFFBA1A1A),
    onError: Colors.white,
  );

  static final theme = _buildTheme(colorScheme);
}

abstract final class DarkTheme {
  static final colorScheme = ColorScheme.fromSeed(
    seedColor: BrandColors.navyAction,
    brightness: Brightness.dark,
    secondary: BrandColors.gold,
  ).copyWith(
    primary: BrandColors.navyLight,
    onPrimary: BrandColors.navy,
    primaryContainer: BrandColors.navyContainerDark,
    onPrimaryContainer: const Color(0xFFE2EDFF),
    secondary: BrandColors.gold,
    onSecondary: BrandColors.onGold,
    secondaryContainer: BrandColors.goldContainerDark,
    onSecondaryContainer: const Color(0xFFF3E6D4),
    surface: const Color(0xFF0D1117),
    onSurface: const Color(0xFFF0F6FC),
    onSurfaceVariant: const Color(0xFFB1BAC4),
    surfaceContainerLowest: const Color(0xFF010409),
    surfaceContainerLow: const Color(0xFF0D1117),
    surfaceContainer: const Color(0xFF161B22),
    surfaceContainerHigh: const Color(0xFF1C2128),
    surfaceContainerHighest: const Color(0xFF30363D),
    outline: const Color(0xFF6E7681),
    outlineVariant: const Color(0xFF30363D),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
  );

  static final theme = _buildTheme(colorScheme);
}

ThemeData _buildTheme(ColorScheme colors) {
  final isDark = colors.brightness == Brightness.dark;
  final radius = BorderRadius.circular(12);

  final base = ThemeData(
    useMaterial3: true,
    brightness: colors.brightness,
    colorScheme: colors,
    fontFamily: 'inter',
    fontFamilyFallback: ['roboto'],
  );

  final textTheme = base.textTheme
      .copyWith(
        headlineLarge: const TextStyle(
          fontSize: 32,
          height: 1.25,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        headlineMedium: const TextStyle(
          fontSize: 28,
          height: 1.3,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        headlineSmall: const TextStyle(
          fontSize: 24,
          height: 1.3,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: const TextStyle(
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          height: 1.45,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          height: 1.3,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: const TextStyle(
          fontSize: 12,
          height: 1.3,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: const TextStyle(
          fontSize: 11,
          height: 1.3,
          fontWeight: FontWeight.w500,
        ),
      )
      .apply(
        fontFamily: 'inter',
        bodyColor: colors.onSurface,
        displayColor: colors.onSurface,
      );

  OutlineInputBorder inputBorder(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[
      isDark ? SectionAccents.dark : SectionAccents.light,
    ],
    primaryColor: colors.primary,
    scaffoldBackgroundColor:
        isDark ? colors.surfaceContainerLowest : colors.surfaceContainerLow,
    cardColor: colors.surface,
    dividerColor: colors.outlineVariant,
    disabledColor: colors.onSurface.withAlpha(97),
    textTheme: textTheme,
    datePickerTheme: AppPickerTheme.date(colors, textTheme),
    timePickerTheme: AppPickerTheme.time(colors, textTheme),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colors.surfaceContainerLow,
      foregroundColor: colors.onSurface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.titleLarge,
      iconTheme: IconThemeData(color: colors.onSurfaceVariant),
      shape: Border(bottom: BorderSide(color: colors.outlineVariant)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.outlineVariant)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          side: BorderSide(color: colors.outlineVariant)),
    ),
    drawerTheme: DrawerThemeData(
        backgroundColor: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      hintStyle: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant,
      ),
      floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: colors.primary),
      errorStyle: textTheme.bodySmall?.copyWith(color: colors.error),
      errorMaxLines: 3,
      prefixIconColor: colors.onSurfaceVariant,
      suffixIconColor: colors.onSurfaceVariant,
      border: inputBorder(colors.outlineVariant),
      enabledBorder: inputBorder(colors.outlineVariant),
      focusedBorder: inputBorder(colors.primary, 2),
      errorBorder: inputBorder(colors.error),
      focusedErrorBorder: inputBorder(colors.error, 2),
      disabledBorder: inputBorder(colors.outlineVariant.withAlpha(128)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        surfaceTintColor: Colors.transparent,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.onSurface,
        backgroundColor: colors.surfaceContainerHigh,
        disabledBackgroundColor: colors.surface,
        disabledForegroundColor: colors.onSurface.withAlpha(97),
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        side: BorderSide(color: colors.outline),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        minimumSize: const Size(48, 48),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
    ),
    iconTheme: IconThemeData(color: colors.onSurfaceVariant, size: 22),
    dividerTheme: DividerThemeData(
      color: colors.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: isDark ? colors.surfaceContainer : colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      textStyle: textTheme.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colors.onSurfaceVariant,
      textColor: colors.onSurface,
      selectedColor: colors.primary,
      selectedTileColor: colors.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: radius),
      titleTextStyle: textTheme.bodyMedium,
      subtitleTextStyle: textTheme.bodySmall?.copyWith(
        color: colors.onSurfaceVariant,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colors.primary,
      selectionColor: colors.primary.withAlpha(64),
      selectionHandleColor: colors.primary,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colors.primary,
      linearTrackColor: colors.primaryContainer,
      circularTrackColor: colors.primaryContainer,
    ),
  );
}
