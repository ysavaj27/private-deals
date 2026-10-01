import 'package:private_deals/src/features/wealth_manager/data/models/startup/startup_model.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

class MisModel {
  int id;
  int startupId;
  String title;
  String document;
  String description;
  String status;
  DateTime createdAt;
  DateTime updatedAt;
  StartupModel startup;

  MisModel({
    this.id = 0,
    this.startupId = 0,
    this.title = "",
    this.document = "",
    this.description = "",
    this.status = "",
    required this.createdAt,
    required this.updatedAt,
    required this.startup,
  });

  factory MisModel.fromJson(Map<String, dynamic> json) => MisModel(
        id: Parse.toInt(json["id"]),
        startupId: Parse.toInt(json["startup_id"]),
        title: Parse.toStrings(json["title"]),
        document: Parse.parseUrl(json["document"]),
        description: Parse.toStrings(json["description"]),
        status: Parse.toStrings(json["status"]),
        createdAt: Parse.toDateTime(json["created_at"]),
        updatedAt: Parse.toDateTime(json["updated_at"]),
        startup: StartupModel.fromJson(json["startup"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "startup_id": startupId,
        "title": title,
        "document": document,
        "description": description,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "startup": startup.toJson(),
      };
}
