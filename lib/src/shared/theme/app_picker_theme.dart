import 'package:flutter/material.dart';

import 'brand_colors.dart';

/// Shared calendar and clock styling for both app-wide defaults and dialogs
/// opened from features with their own local theme.
abstract final class AppPickerTheme {
  static ThemeData apply(ThemeData theme) => theme.copyWith(
    datePickerTheme: date(theme.colorScheme, theme.textTheme),
    timePickerTheme: time(theme.colorScheme, theme.textTheme),
  );

  static RoundedRectangleBorder _shape(ColorScheme colors) =>
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.65)),
      );

  static ButtonStyle _confirm(ColorScheme colors) => TextButton.styleFrom(
    backgroundColor: colors.primary,
    foregroundColor: colors.onPrimary,
    minimumSize: const Size(96, 48),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(
      fontFamily: 'inter',
      fontWeight: FontWeight.w600,
    ),
  );

  static ButtonStyle _cancel(ColorScheme colors) => TextButton.styleFrom(
    foregroundColor: colors.onSurfaceVariant,
    minimumSize: const Size(64, 48),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static WidgetStateProperty<Color?> _foreground(ColorScheme colors) =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.onSurface.withValues(alpha: 0.3);
        }
        return states.contains(WidgetState.selected)
            ? colors.onPrimary
            : colors.onSurface;
      });

  static WidgetStateProperty<Color?> _background(ColorScheme colors) =>
      WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.primary
            : Colors.transparent,
      );

  static DatePickerThemeData date(ColorScheme colors, TextTheme text) =>
      DatePickerThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: _shape(colors),
        headerBackgroundColor: BrandColors.navy,
        headerForegroundColor: Colors.white,
        headerHeadlineStyle: text.headlineLarge?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        headerHelpStyle: text.labelLarge?.copyWith(letterSpacing: 0.5),
        weekdayStyle: text.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        dayStyle: text.bodyMedium,
        dayForegroundColor: _foreground(colors),
        dayBackgroundColor: _background(colors),
        todayForegroundColor: _foreground(colors),
        todayBackgroundColor: _background(colors),
        todayBorder: const BorderSide(color: BrandColors.gold, width: 1.5),
        yearStyle: text.bodyMedium,
        yearForegroundColor: _foreground(colors),
        yearBackgroundColor: _background(colors),
        dividerColor: colors.outlineVariant.withValues(alpha: 0.65),
        subHeaderForegroundColor: colors.onSurface,
        cancelButtonStyle: _cancel(colors),
        confirmButtonStyle: _confirm(colors),
        inputDecorationTheme: _input(colors),
      );

  static TimePickerThemeData time(
    ColorScheme colors,
    TextTheme text,
  ) => TimePickerThemeData(
    backgroundColor: colors.surface,
    elevation: 0,
    shape: _shape(colors),
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
    helpTextStyle: text.labelMedium?.copyWith(
      color: colors.onSurfaceVariant,
      letterSpacing: 0.5,
    ),
    hourMinuteShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    hourMinuteColor: WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? BrandColors.navy
          : colors.surfaceContainerLow,
    ),
    hourMinuteTextColor: WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? Colors.white
          : colors.onSurface,
    ),
    hourMinuteTextStyle: text.displayMedium?.copyWith(
      fontSize: 48,
      fontWeight: FontWeight.w500,
    ),
    timeSelectorSeparatorColor: WidgetStatePropertyAll(colors.onSurfaceVariant),
    timeSelectorSeparatorTextStyle: WidgetStatePropertyAll(
      text.displayMedium?.copyWith(fontSize: 40),
    ),
    dayPeriodShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    dayPeriodBorderSide: BorderSide(color: colors.outlineVariant),
    dayPeriodColor: WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? colors.secondaryContainer
          : colors.surface,
    ),
    dayPeriodTextColor: WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? colors.onSecondaryContainer
          : colors.onSurfaceVariant,
    ),
    dayPeriodTextStyle: text.labelLarge,
    dialBackgroundColor: BrandColors.navy,
    dialHandColor: BrandColors.gold,
    dialTextColor: WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? BrandColors.onGold
          : Colors.white,
    ),
    dialTextStyle: text.titleMedium,
    entryModeIconColor: colors.primary,
    cancelButtonStyle: _cancel(colors),
    confirmButtonStyle: _confirm(colors),
    inputDecorationTheme: _input(colors).copyWith(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );

  static InputDecorationThemeData _input(ColorScheme colors) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecorationThemeData(
      filled: true,
      // TimePicker supplies its state-aware hour/minute fill and text colors.
      // Keeping fillColor unset preserves contrast in focused time inputs.
      border: border(colors.outlineVariant),
      enabledBorder: border(colors.outlineVariant),
      focusedBorder: border(colors.primary, 2),
      errorBorder: border(colors.error),
      focusedErrorBorder: border(colors.error, 2),
      errorMaxLines: 3,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
