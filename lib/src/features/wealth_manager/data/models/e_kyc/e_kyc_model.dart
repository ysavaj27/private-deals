import 'package:private_deals/src/shared/functions/parse.dart';

class EKycModel {
  int status;
  String token;
  int mobile;

  EKycModel({
    this.status = 0,
    this.token = "",
    this.mobile = 0,
  });

  factory EKycModel.fromJson(Map<String, dynamic> json) => EKycModel(
        status: Parse.toInt(json["status"]),
        token: Parse.toStrings(json["token"]),
        mobile: Parse.toInt(json["mobile"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "token": token,
        "mobile": mobile,
      };
}
