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
    required this.createdAt,
  });

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
        "created_at": createdAt.toIso8601String(),
      };
}
