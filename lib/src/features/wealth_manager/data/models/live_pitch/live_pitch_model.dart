import 'package:private_deals/src/features/wealth_manager/data/models/startup/pitch_model.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/startup/startup_model.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

class LivePitchModel {
  int id;
  int investorId;
  int pitchId;
  int startupId;
  String status;
  DateTime createdAt;
  DateTime updatedAt;
  PitchModel startupPitch;
  StartupModel startup;

  LivePitchModel({
    this.id = 0,
    this.investorId = 0,
    this.pitchId = 0,
    this.startupId = 0,
    this.status = "",
    required this.createdAt,
    required this.updatedAt,
    required this.startupPitch,
    required this.startup,
  });

  factory LivePitchModel.fromJson(Map<String, dynamic> json) => LivePitchModel(
        id: Parse.toInt(json["id"]),
        investorId: Parse.toInt(json["investor_id"]),
        pitchId: Parse.toInt(json["pitch_id"]),
        startupId: Parse.toInt(json["startup_id"]),
        status: Parse.toStrings(json["status"]),
        createdAt: Parse.toDateTime(json["created_at"]),
        updatedAt: Parse.toDateTime(json["updatedAt"]),
        startupPitch: PitchModel.fromJson(json["startup_pitch"] ?? {}),
        startup: StartupModel.fromJson(json["startup"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "investor_id": investorId,
        "pitch_id": pitchId,
        "startup_id": startupId,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "startup_pitch": startupPitch.toJson(),
        "startup": startup.toJson(),
      };
}
