import 'package:private_deals/src/shared/functions/parse.dart';

class NotificationModel {
  int id;
  int status;
  int posted;
  String userType;
  int user;
  String title;
  String body;
  String redirection;
  String image;
  DateTime createdAt;

  NotificationModel({
    this.id = 0,
    this.status = 0,
    this.posted = 0,
    this.userType = "",
    this.user = 0,
    this.title = '',
    this.body = '',
    this.redirection = '',
    this.image = '',
    required this.createdAt,
  });

  bool get hasImage => image.trim().isNotEmpty;

  /// Recent enough to surface a subtle "New" cue in the list.
  bool get isRecent {
    if (createdAt.year <= 1) return false;
    return DateTime.now().difference(createdAt) < const Duration(hours: 24);
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: Parse.toInt(json["id"]),
        status: Parse.toInt(json["status"]),
        posted: Parse.toInt(json["posted"]),
        userType: Parse.toStrings(json["user_type"]),
        user: Parse.toInt(json["user"]),
        title: Parse.toStrings(json["title"]),
        body: Parse.toStrings(json["body"]),
        redirection: Parse.toStrings(json["redirection"]),
        image: Parse.parseUrl(_resolveImage(json)),
        createdAt: Parse.toDateTime(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "posted": posted,
        "user_type": userType,
        "user": user,
        "title": title,
        "body": body,
        "redirection": redirection,
        "image": image,
        "created_at": createdAt.toIso8601String(),
      };

  /// Accepts common API shapes: flat string keys or nested `{ url: ... }`.
  static String _resolveImage(Map<String, dynamic> json) {
    const keys = [
      'image',
      'image_url',
      'icon',
      'icon_image',
      'thumbnail',
      'photo',
      'media',
    ];
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is Map) {
        final url = value['url'] ?? value['image'] ?? value['image_url'];
        if (url != null && url.toString().trim().isNotEmpty) {
          return url.toString().trim();
        }
      }
    }
    return '';
  }
}
