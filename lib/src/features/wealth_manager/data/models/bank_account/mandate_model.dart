import 'package:private_deals/src/shared/functions/parse.dart';

class MandateModel {
  int id;
  int investorId;
  String state;
  int amount;
  String bankAccountType;
  DateTime createdAt;
  DateTime updatedAt;

  MandateModel({
    this.id = 0,
    this.investorId = 0,
    this.state = "",
    this.amount = 0,
    this.bankAccountType = "",
    required this.createdAt,
    required this.updatedAt,
  });

  factory MandateModel.fromJson(Map<String, dynamic> json) => MandateModel(
        id: Parse.toInt(json["id"]),
        investorId: Parse.toInt(json["investor_id"]),
        state: Parse.toStrings(json["state"]),
        amount: Parse.toInt(json["amount"]),
        bankAccountType: Parse.toStrings(json["bank_account_type"]),
        createdAt: Parse.toDateTime(json["created_at"]),
        updatedAt: Parse.toDateTime(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "investor_id": investorId,
        "state": state,
        "amount": amount,
        "bank_account_type": bankAccountType,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
