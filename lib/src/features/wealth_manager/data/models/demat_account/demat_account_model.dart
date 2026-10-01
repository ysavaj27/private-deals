import 'package:private_deals/src/shared/functions/parse.dart';

class DematAccountModel {
  int id;
  int investorId;
  String dpId;
  String clientId;
  String dematAccount;
  DateTime createdAt;
  DateTime updatedAt;

  DematAccountModel({
    this.id = 0,
    this.investorId = 0,
    this.dpId = "",
    this.clientId = "",
    this.dematAccount = "",
    required this.createdAt,
    required this.updatedAt,
  });

  factory DematAccountModel.fromJson(Map<String, dynamic> json) =>
      DematAccountModel(
        id: Parse.toInt(json["id"]),
        investorId: Parse.toInt(json["investor_id"]),
        dpId: Parse.toStrings(json["dp_id"]),
        clientId: Parse.toStrings(json["client_id"]),
        dematAccount: Parse.toStrings(json["demat_account"]),
        createdAt: Parse.toDateTime(json["created_at"]),
        updatedAt: Parse.toDateTime(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "investor_id": investorId,
    "dp_id": dpId,
    "client_id": clientId,
    "demat_account": dematAccount,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
