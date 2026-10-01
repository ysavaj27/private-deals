import 'package:private_deals/src/shared/functions/parse.dart';

class PitchModel {
  int id;
  int startupId;
  String title;
  String description;
  DateTime scheduledDate;
  String hostUrl;
  String userUrl;

  PitchModel({
    this.id = 0,
    this.startupId = 0,
    this.title = "",
    this.description = "",
    required this.scheduledDate,
    this.hostUrl = "",
    this.userUrl = "",
  });

  factory PitchModel.fromJson(Map<String, dynamic> json) => PitchModel(
        id: Parse.toInt(json["id"]),
        startupId: Parse.toInt(json["startup_id"]),
        title: Parse.toStrings(json["title"]),
        description: Parse.toStrings(json["description"]),
        scheduledDate: Parse.toDateTime(json["scheduled_date"]),
        hostUrl: Parse.toStrings(json["host_url"]),
        userUrl: Parse.toStrings(json["user_url"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "startup_id": startupId,
        "title": title,
        "description": description,
        "scheduled_date": scheduledDate.toIso8601String(),
        "host_url": hostUrl,
        "user_url": userUrl,
      };
}
