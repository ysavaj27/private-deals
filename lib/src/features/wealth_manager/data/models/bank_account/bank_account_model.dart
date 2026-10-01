import 'package:private_deals/src/shared/functions/parse.dart';

class BankAccountModel {
  int id;
  int investorId;
  int castlerPayeeId;
  String accountName;
  int accountNumber;
  String bankName;
  String ifscCode;
  String bankAddress;
  int isDefault;
  DateTime createdAt;

  BankAccountModel({
    this.id = 0,
    this.investorId = 0,
    this.castlerPayeeId = 0,
    this.accountName = '',
    this.accountNumber = 0,
    this.bankName = '',
    this.ifscCode = '',
    this.bankAddress = '',
    this.isDefault = 0,
    required this.createdAt,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) =>
      BankAccountModel(
        id: Parse.toInt(json["id"]),
        investorId: Parse.toInt(json["investor_id"]),
        castlerPayeeId: Parse.toInt(json["castler_payee_id"]),
        accountName: Parse.toStrings(json["account_name"]),
        accountNumber: Parse.toInt(json["account_number"]),
        bankName: Parse.toStrings(json["bank_name"]),
        ifscCode: Parse.toStrings(json["ifsc_code"]),
        bankAddress: Parse.toStrings(json["bank_address"]),
        isDefault: Parse.toInt(json["is_default"]),
        createdAt: Parse.toDateTime(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "investor_id": investorId,
        "castler_payee_id": castlerPayeeId,
        "account_name": accountName,
        "account_number": accountNumber,
        "bank_name": bankName,
        "ifsc_code": ifscCode,
        "bank_address": bankAddress,
        "is_default": isDefault,
        "created_at": createdAt.toIso8601String(),
      };
}
