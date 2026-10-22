import 'package:private_deals/src/shared/functions/parse.dart';

class AifModel {
  int id;
  int investorId;
  int status;
  DateTime createdAt;
  DateTime updatedAt;

  AifModel({
    this.id = 0,
    this.investorId = 0,
    this.status = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AifModel.fromJson(Map<String, dynamic> json) => AifModel(
        id: Parse.toInt(json["id"]),
        investorId: Parse.toInt(json["investor_id"]),
        status: Parse.toInt(json["status"]),
        createdAt: Parse.toDateTime(json["created_at"]),
        updatedAt: Parse.toDateTime(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "investor_id": investorId,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
