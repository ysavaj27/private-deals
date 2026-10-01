import 'package:private_deals/src/shared/functions/parse.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/startup/startup_model.dart';

class FavoriteModel {
  int id;
  int startupId;
  int investorId;
  DateTime createdAt;
  DateTime updatedAt;
  StartupModel startup;

  FavoriteModel({
    this.id = 0,
    this.startupId = 0,
    this.investorId = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.startup,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) => FavoriteModel(
        id: Parse.toInt(json["id"]),
        startupId: Parse.toInt(json["startup_id"]),
        investorId: Parse.toInt(json["investor_id"]),
        createdAt: Parse.toDateTime(json["created_at"]),
        updatedAt: Parse.toDateTime(json["updated_at"]),
        startup: StartupModel.fromJson(json["startup"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "startup_id": startupId,
        "investor_id": investorId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "startup": startup.toJson(),
      };
}
