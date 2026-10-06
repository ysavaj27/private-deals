import 'package:private_deals/src/shared/functions/parse.dart' as shared;

class Parse {
  static int toInt(dynamic data, [int defaultValue = 0]) {
    return int.tryParse(data.toString()) ?? defaultValue;
  }

  static double toDouble(dynamic data, [double defaultValue = 0.0]) {
    return double.tryParse(data.toString()) ?? defaultValue;
  }

  static DateTime toDateTime(dynamic date) {
    final parsed = DateTime.tryParse(date?.toString() ?? "");

    if (parsed == null) {
      return DateTime(0);
    }

    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  static bool toBool(dynamic data) {
    return toInt(data) == 1 || data == true ? true : false;
  }

  static String toStrings(dynamic data, [String defaultValue = ""]) {
    return data?.toString() ?? defaultValue;
  }

  static String parseUrl(String? url) => shared.Parse.parseUrl(url);

  static T toEnum<T extends Enum>(
    List<T> values,
    dynamic data, {
    required T defaultValue,
  }) {
    final value = data?.toString().toLowerCase();

    return values.firstWhere(
      (e) => e.name.toLowerCase() == value,
      orElse: () => defaultValue,
    );
  }
}
