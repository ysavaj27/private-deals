import 'dart:io';

import 'package:intl/intl.dart';

DateTime today = DateTime.now();
DateTime nextDay = DateTime.now().add(const Duration(days: 1));

extension FileExtention on FileSystemEntity {
  String get name => path.split(Platform.pathSeparator).last;
}

extension DateTimeExtension on DateTime {
  int getMonth() {
    switch (weekday) {
      case 1:
        return 1;
      case 2:
        return 2;
      case 3:
        return 3;
      case 4:
        return 4;
      case 5:
        return 5;
      case 6:
        return 6;
      case 7:
        return 0;
      default:
        return 0;
    }
  }

  ///Example 2022-08-30
  String get serverDate {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  int myDifference(DateTime other) {
    DateTime otherNew = DateTime(
      other.year,
      other.month,
      other.day,
      9,
      0,
      0,
      0,
      0,
    );
    DateTime thisNew = DateTime(year, month, day, 9, 0, 0, 0, 0);
    return thisNew.difference(otherNew).inDays;
  }

  ///Example 2022_08_30_12_00_00
  String get saveDate {
    return DateFormat('yyyy_MM_dd_hh_mm_ss').format(this);
  }

  ///Example 2022
  String get showYear {
    if (this.isNotEmpty) {
      return DateFormat('yyyy').format(this);
    } else {
      return "N/A";
    }
  }

  ///Example 30-8-2022
  String get showDate {
    if (this.isNotEmpty) {
      return DateFormat('dd-MM-yyyy').format(this);
    } else {
      return "N/A";
    }
  }

  String get apiFormat {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(this);
  }

  ///Example 30-8-2022
  DateTime nextDate(int day) {
    return add(Duration(days: day));
  }

  ///Example Aug-21
  String get shortMonthWithDate {
    return DateFormat('MMM-dd').format(this);
  }

  String get monthAndYear {
    return DateFormat('MMMM yyyy').format(this);
  }

  ///Example 20-August
  String get dateWithMonth {
    if (this.isNotEmpty) {
      return DateFormat('dd MMMM').format(this);
    } else {
      return "N/A";
    }
  }

  ///Example Saturday, 07 October 2023
  String get dayWithDateMonthYear {
    if (this.isNotEmpty) {
      return DateFormat('EEE dd, MMMM yyyy').format(this);
    } else {
      return "N/A";
    }
  }

  ///Example 20-Aug, 2022
  String get dateWithSortMonthYear {
    if (this.isNotEmpty) {
      return DateFormat('dd MMM, yyyy').format(this);
    } else {
      return "N/A";
    }
  }

  /// October 2023 at 05:30 PM
  String get livePitchDate {
    if (this.isNotEmpty) {
      return DateFormat('E dd, MMMM yyyy \'at\' hh:mm a').format(this);
    } else {
      return "N/A";
    }
  }

  ///Example 20-August-2022
  String get dateWithMonthYear {
    if (this.isNotEmpty) {
      return DateFormat('dd-MMMM-yyyy').format(this);
    } else {
      return "N/A";
    }
  }

  ///Example Set Time In Today Date
  DateTime get realTime {
    return DateTime(today.year, today.month, today.day, hour, minute);
  }

  ///Example Set Time In Today Date
  DateTime addTime(DateTime date) {
    return DateTime(year, month, day, date.hour, date.minute, date.second);
  }

  ///Example 14:00
  String get timeFormat {
    if (this.isNotEmpty) {
      return DateFormat('hh:mm a').format(this);
    } else {
      return "N/A";
    }
  }

  // String get onlyTime12Format {
  //   if (authRepo.halfFormat()) {
  //     return DateFormat('hh:mm a').format(this);
  //   } else {
  //     return DateFormat('HH:mm').format(this);
  //   }
  // }

  ///Example 23:00
  // String get onlyAMPMFormat {
  //   return DateFormat('a').format(this);
  // }

  /// If date is 3/12/2022 then return 1/12/2022.
  DateTime get firstDateOfMonth {
    return DateTime(year, month, 1);
  }

  /// If date is 3/12/2022 then return 31/12/2022.
  DateTime get lastDateOfMoth {
    return (month < 12)
        ? DateTime(year, month + 1, 0)
        : DateTime(year + 1, 1, 0);
  }

  DateTime next(int day) {
    return add(Duration(days: (day - weekday) % DateTime.daysPerWeek));
  }

  DateTime get timeClear {
    return DateTime(year, month, day);
  }

  bool isSameDay(DateTime? date) {
    if (date?.day == day) {
      return true;
    } else {
      return false;
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays >= 7) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays >= 1) {
      return difference.inDays == 1
          ? '1 day ago'
          : '${difference.inDays} days ago';
    } else if (difference.inHours >= 1) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes >= 1) {
      return difference.inMinutes == 1
          ? '1 minute ago'
          : '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }

  int get timeRemainingValue {
    if (this.isBefore(DateTime.now())) {
      return 0; // Expired
    }

    final difference = this.difference(DateTime.now());

    if (difference.inDays >= 1) {
      return difference.inDays;
    } else if (difference.inHours >= 1) {
      return difference.inHours;
    } else if (difference.inMinutes >= 1) {
      return difference.inMinutes;
    } else {
      return 0; // Less than a minute
    }
  }

  // Returns the time unit as a string: days, hours, or minutes
  String get timeRemainingUnit {
    if (this.isBefore(DateTime.now())) {
      return 'Expired';
    }

    final difference = this.difference(DateTime.now());

    if (difference.inDays >= 1) {
      return difference.inDays == 1 ? 'day left' : 'days left';
    } else if (difference.inHours >= 1) {
      return difference.inHours == 1 ? 'hour left' : 'hours left';
    } else if (difference.inMinutes >= 1) {
      return difference.inMinutes == 1 ? 'minute left' : 'minutes left';
    } else {
      return 'Less than a minute';
    }
  }

  bool get isActive {
    return this.isBefore(DateTime.now()) ? false : true;
  }

  double progress({int totalDays = 15}) {
    final startTime = this.subtract(Duration(days: totalDays));

    if (this.isBefore(startTime)) {
      // If current time is before start time, progress is 0.0
      return 0.0;
    } else if (this.isAfter(this)) {
      // If current time is after end time, progress is 1.0
      return 1.0;
    }

    final totalDuration = this.difference(startTime).inSeconds;
    final elapsedDuration = this.difference(startTime).inSeconds;

    // Return the progress (time passed / total time)
    return elapsedDuration / totalDuration;
  }

  bool get isNotEmpty {
    if (DateTime(0, 1, 1).isAtSameMomentAs(this) ||
        DateTime(0).isAtSameMomentAs(this)) {
      return false;
    } else {
      return true;
    }
  }
}
