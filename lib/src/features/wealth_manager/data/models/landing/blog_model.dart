import 'package:private_deals/src/shared/functions/parse.dart';

class BlogModel {
  int id;
  int type;
  String banner;
  String title;
  String urlSlug;
  String shortDescription;
  String longDescription;
  int displayOrder;
  DateTime createdAt;
  DateTime updatedAt;

  BlogModel({
    this.id = 0,
    this.type = 0,
    this.banner = '',
    this.title = '',
    this.urlSlug = '',
    this.shortDescription = '',
    this.longDescription = '',
    this.displayOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) => BlogModel(
        id: Parse.toInt(json["id"]),
        type: Parse.toInt(json["type"]),
        banner: Parse.parseUrl(json["banner"]),
        title: Parse.toStrings(json["title"]),
        urlSlug: Parse.toStrings(json["url_slug"]),
        shortDescription: Parse.toStrings(json["short_description"]),
        longDescription: Parse.toStrings(json["long_description"]),
        displayOrder: Parse.toInt(json["display_order"]),
        createdAt: Parse.toDateTime(json["created_at"]),
        updatedAt: Parse.toDateTime(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "banner": banner,
        "title": title,
        "url_slug": urlSlug,
        "short_description": shortDescription,
        "long_description": longDescription,
        "display_order": displayOrder,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
