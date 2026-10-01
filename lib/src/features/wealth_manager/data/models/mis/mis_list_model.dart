import 'package:private_deals/src/shared/functions/parse.dart';

class MisListModel {
  int id;
  String title;
  String document;
  String description;
  DateTime createdAt;

  MisListModel({
    this.id = 0,
    this.title = '',
    this.document = '',
    this.description = '',
    required this.createdAt,
  });

  factory MisListModel.fromJson(Map<String, dynamic> json) => MisListModel(
        id: Parse.toInt(json["id"]),
        title: Parse.toStrings(json["title"]),
        document: Parse.parseUrl(json["document"]),
        description: Parse.toStrings(json["description"]),
        createdAt: Parse.toDateTime(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "document": document,
        "description": description,
        "created_at": createdAt.toIso8601String(),
      };
}
