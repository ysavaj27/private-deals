/// The dashboard accepts the endpoint's payload or the standard API envelope.
class DashboardModel {
  final Map<String, dynamic> data;
  DashboardModel._(this.data);

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('status') && json['status'] != 1) {
      throw const FormatException('Dashboard request was unsuccessful.');
    }
    final payload = map(json['data'] ?? json);
    if (payload['summary'] is! Map || payload['access'] is! Map) {
      throw const FormatException('Invalid dashboard response.');
    }
    return DashboardModel._(payload);
  }

  static Map<String, dynamic> map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};
  static List<Map<String, dynamic>> list(dynamic value) => value is List
      ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : [];
  static num number(dynamic value) {
    final n = value is num ? value : num.tryParse('$value') ?? 0;
    return n.isFinite && n >= 0 ? n : 0;
  }

  bool access(String key) => map(data['access'])['is_${key}_access'] == true;
  num summary(String group, String key) =>
      number(map(map(data['summary'])[group])[key]);
  List<Map<String, dynamic>> recent(String key) =>
      list(map(data['recent'])[key]);
  List<Map<String, dynamic>> chart(String key) =>
      list(map(data['charts'])[key]);
  List<Map<String, dynamic>> volume(bool quarterly) => list(
    map(map(data['charts'])['transaction_volume'])[quarterly
        ? 'quarterly'
        : 'monthly'],
  );
}
