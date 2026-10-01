import 'package:private_deals/src/shared/functions/parse.dart';

class DocumentModel {
  int id;
  String apiId;
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
    this.apiId = '',
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
        apiId: Parse.toStrings(json["apiId"]),
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
  String sname;
  List<int> startup;
  List<int> investor;
  List<int> primaryTransactions;

  MetaModel({
    this.name = "",
    this.sname = "",
    this.startup = const [],
    this.investor = const [],
    this.primaryTransactions = const [],
  });

  factory MetaModel.fromJson(Map<String, dynamic> json) => MetaModel(
        name: Parse.toStrings(json["name"]),
        sname: Parse.toStrings(json["sname"]),
        startup: List<int>.from(json["startup"] ?? []),
        investor: List<int>.from(json["investor"] ?? []),
        primaryTransactions: List<int>.from(json["primary_transactions"] ?? []),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "sname": sname,
        "startup": startup,
        "investor": investor,
        "primary_transactions": primaryTransactions,
      };
}
