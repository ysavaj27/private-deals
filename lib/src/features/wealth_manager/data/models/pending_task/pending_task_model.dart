import 'package:private_deals/src/shared/functions/parse.dart';

class PendingTaskModel {
  int pendingPayment;
  int documentSign;
  int pendingKyc;
  int pendingAif;

  PendingTaskModel({
    this.pendingPayment = 0,
    this.documentSign = 0,
    this.pendingKyc = 0,
    this.pendingAif = 0,
  });

  factory PendingTaskModel.fromJson(Map<String, dynamic> json) =>
      PendingTaskModel(
        pendingPayment: Parse.toInt(json["pending_payment"]),
        documentSign: Parse.toInt(json["document_sign"]),
        pendingKyc: Parse.toInt(json["pending_kyc"]),
        pendingAif: Parse.toInt(json["pending_aif"]),
      );

  Map<String, dynamic> toJson() => {
        "pending_payment": pendingPayment,
        "document_sign": documentSign,
        "pending_kyc": pendingKyc,
        "pending_aif": pendingAif,
      };
}
