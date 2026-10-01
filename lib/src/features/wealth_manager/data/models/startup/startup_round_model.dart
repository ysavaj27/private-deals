import 'package:private_deals/src/shared/models/enums.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/startup/startup_model.dart';

import 'package:private_deals/src/shared/functions/parse.dart';

class StartupRoundModel {
  int id;
  int startupId;
  String name;
  String roundType;
  String roundStatus;
  double sharePrice;
  double shuruCommission;
  int isDeleted;
  int createdBy;
  int updatedBy;
  DateTime createdAt;
  DateTime updatedAt;
  StartupModel startup;

  StartupRoundModel({
    this.id = 0,
    this.startupId = 0,
    this.name = "",
    this.roundType = "",
    this.roundStatus = "",
    this.sharePrice = 0.0,
    this.shuruCommission = 0.0,
    this.isDeleted = 0,
    this.createdBy = 0,
    this.updatedBy = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.startup,
  });

  // Helper function to map the round status to an enum
  StartupStatusEnum get type {
    switch (roundStatus) {
      case "Coming Soon":
        return StartupStatusEnum.comingsoon;
      case "Raising Now":
        return StartupStatusEnum.raisingnow;
      case "Completed":
        return StartupStatusEnum.completed;
      case "Pending":
        return StartupStatusEnum.pending;
      default:
        return StartupStatusEnum.pending;
    }
  }

  factory StartupRoundModel.fromJson(Map<String, dynamic> json) =>
      StartupRoundModel(
        id: Parse.toInt(json["id"]),
        startupId: Parse.toInt(json["startup_id"]),
        name: Parse.toStrings(json["name"]),
        roundType: Parse.toStrings(json["round_type"]),
        roundStatus: Parse.toStrings(json["round_status"]),
        sharePrice: Parse.toDouble(json["share_price"]),
        shuruCommission: Parse.toDouble(json["shuru_commission"]),
        isDeleted: Parse.toInt(json["is_deleted"]),
        createdBy: Parse.toInt(json["created_by"]),
        updatedBy: Parse.toInt(json["updated_by"]),
        createdAt: Parse.toDateTime(json["created_at"]),
        updatedAt: Parse.toDateTime(json["updated_at"]),
        startup: StartupModel.fromJson(json["startup"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "startup_id": startupId,
        "name": name,
        "round_type": roundType,
        "round_status": roundStatus,
        "share_price": sharePrice,
        "shuru_commission": shuruCommission,
        "is_deleted": isDeleted,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "startup": startup.toJson(),
      };
}
