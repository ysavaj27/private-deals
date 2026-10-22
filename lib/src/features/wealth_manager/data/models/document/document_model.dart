import 'package:private_deals/src/shared/functions/parse.dart';

class DocumentModel {
  int id;
  String path;
  String signedPath;
  int status;
  String type;
  String displayName;
  MetaModel meta;
  DateTime createdAt;
  DateTime updatedAt;

  DocumentModel({
    this.id = 0,
    this.path = '',
    this.signedPath = '',
    this.status = 0,
    this.type = '',
    this.displayName = '',
    required this.meta,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
        id: Parse.toInt(json["id"]),
        path: Parse.parseUrl(json["path"]),
        signedPath: Parse.parseUrl(json["signed_path"]),
        status: Parse.toInt(json["status"]),
        type: Parse.toStrings(json["type"]),
        displayName: Parse.toStrings(json["display_name"]),
        meta: MetaModel.fromJson(json["meta"] ?? {}),
        createdAt: Parse.toDateTime(json["created_at"]),
        updatedAt: Parse.toDateTime(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "path": path,
        "signed_path": signedPath,
        "status": status,
        "type": type,
        "display_name": displayName,
        "meta": meta.toJson(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class MetaModel {
  String name;
  List<int> startup;
  List<int> investor;

  MetaModel({
    this.name = "",
    this.startup = const [],
    this.investor = const [],
  });

  factory MetaModel.fromJson(Map<String, dynamic> json) => MetaModel(
        name: Parse.toStrings(json["name"]),
        startup: json["startup"] is List
            ? (json["startup"] as List).map(Parse.toInt).toList()
            : const [],
        investor: json["investor"] is List
            ? (json["investor"] as List).map(Parse.toInt).toList()
            : const [],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "startup": startup,
        "investor": investor,
      };
}
