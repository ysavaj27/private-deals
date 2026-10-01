import 'package:private_deals/src/shared/functions/parse.dart';

class UpdateModel {
  String title;
  String description;
  String image;
  DateTime createdAt;

  UpdateModel({
    this.title = '',
    this.description = '',
    this.image = '',
    required this.createdAt,
  });

  factory UpdateModel.fromJson(Map<String, dynamic> json) => UpdateModel(
        title: Parse.toStrings(json["title"]),
        description: Parse.toStrings(json["description"]),
        image: Parse.parseUrl(json["image"]),
        createdAt: Parse.toDateTime(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "image": image,
        "created_at": createdAt.toIso8601String(),
      };
}
