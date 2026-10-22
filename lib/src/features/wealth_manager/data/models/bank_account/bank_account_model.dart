import 'package:private_deals/src/shared/functions/parse.dart';

class BankAccountModel {
  int id;
  int investorId;
  int accountNumber;
  String bankName;
  String ifscCode;
  DateTime createdAt;

  BankAccountModel({
    this.id = 0,
    this.investorId = 0,
    this.accountNumber = 0,
    this.bankName = '',
    this.ifscCode = '',
    required this.createdAt,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) =>
      BankAccountModel(
        id: Parse.toInt(json["id"]),
        investorId: Parse.toInt(json["investor_id"]),
        accountNumber: Parse.toInt(json["account_number"]),
        bankName: Parse.toStrings(json["bank_name"]),
        ifscCode: Parse.toStrings(json["ifsc_code"]),
        createdAt: Parse.toDateTime(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "investor_id": investorId,
        "account_number": accountNumber,
        "bank_name": bankName,
        "ifsc_code": ifscCode,
        "created_at": createdAt.toIso8601String(),
      };
}
