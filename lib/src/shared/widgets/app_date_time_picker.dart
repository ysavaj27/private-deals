import 'package:flutter/material.dart';

import '../theme/app_picker_theme.dart';

/// The entry point for date and time selection throughout the app.
///
/// Values remain local calendar dates / wall-clock times. The feature owns any
/// timezone conversion, formatting and business validation (for example IST
/// expiry timestamps). Cancelling always returns null without changing a field.
abstract final class AppDateTimePicker {
  static Future<DateTime?> date({
    required BuildContext context,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? initialDate,
    DateTime? currentDate,
    String title = 'Select date',
    String confirmText = 'Apply',
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  }) {
    final first = DateUtils.dateOnly(firstDate);
    final last = DateUtils.dateOnly(lastDate);
    if (last.isBefore(first)) {
      throw ArgumentError('lastDate must be on or after firstDate');
    }
    var initial = DateUtils.dateOnly(
      initialDate ?? currentDate ?? DateTime.now(),
    );
    // Existing values may be outside a moving boundary, such as yesterday's
    // expiry date. Open at the nearest allowed date instead of asserting.
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      currentDate: currentDate,
      helpText: title,
      confirmText: confirmText,
      cancelText: 'Cancel',
      initialEntryMode: initialEntryMode,
      switchToInputEntryModeIcon: const Icon(Icons.edit_calendar_outlined),
      switchToCalendarEntryModeIcon: const Icon(Icons.calendar_month_outlined),
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: _builder,
    );
  }

  static Future<TimeOfDay?> time({
    required BuildContext context,
    required TimeOfDay initialTime,
    String title = 'Select time',
    String confirmText = 'Apply',
    bool? use24HourFormat,
    TimePickerEntryMode? initialEntryMode,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: title,
      confirmText: confirmText,
      cancelText: 'Cancel',
      // Desktop users can type immediately; the clock toggle stays available.
      initialEntryMode:
          initialEntryMode ??
          (MediaQuery.sizeOf(context).width >= 600
              ? TimePickerEntryMode.input
              : TimePickerEntryMode.dial),
      switchToInputEntryModeIcon: const Icon(Icons.keyboard_outlined),
      switchToTimerEntryModeIcon: const Icon(Icons.schedule_outlined),
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          alwaysUse24HourFormat:
              use24HourFormat ?? MediaQuery.of(context).alwaysUse24HourFormat,
        ),
        child: _builder(context, child),
      ),
    );
  }

  static Widget _builder(BuildContext context, Widget? child) =>
      Theme(data: AppPickerTheme.apply(Theme.of(context)), child: child!);
}
