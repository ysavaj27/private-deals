

extension NumberFormatter on Duration {
  String get hours {
    return inHours % 24 != 0 ? '${inHours % 24}' : '';
  }

  String get minutes {
    return inMinutes % 60 != 0 ? '${inMinutes % 60}' : '';
  }
}
