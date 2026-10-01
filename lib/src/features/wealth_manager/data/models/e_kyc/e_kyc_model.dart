import 'package:private_deals/src/shared/functions/parse.dart';

class EKycModel {
  int status;
  String token;
  String entityId;
  int mobile;

  EKycModel({
    this.status = 0,
    this.token = "",
    this.entityId = "",
    this.mobile = 0,
  });

  factory EKycModel.fromJson(Map<String, dynamic> json) => EKycModel(
        status: Parse.toInt(json["status"]),
        token: Parse.toStrings(json["token"]),
        entityId: Parse.toStrings(json["entity_id"]),
        mobile: Parse.toInt(json["mobile"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "token": token,
        "entity_id": entityId,
        "mobile": mobile,
      };
}
