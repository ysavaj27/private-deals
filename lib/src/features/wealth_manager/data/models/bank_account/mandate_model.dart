import 'package:private_deals/src/shared/functions/parse.dart';

class MandateModel {
  int id;
  int investorId;
  int mandateId;
  int bankId;
  String umrnNo;
  String state;
  int amount;
  int bankAccountNo;
  String bankAccountType;
  String bankIfscCode;
  DateTime createdAt;
  DateTime updatedAt;
  BankModel bank;

  MandateModel({
    this.id = 0,
    this.investorId = 0,
    this.mandateId = 0,
    this.bankId = 0,
    this.umrnNo = "",
    this.state = "",
    this.amount = 0,
    this.bankAccountNo = 0,
    this.bankAccountType = "",
    this.bankIfscCode = "",
    required this.createdAt,
    required this.updatedAt,
    required this.bank,
  });

  factory MandateModel.fromJson(Map<String, dynamic> json) => MandateModel(
        id: Parse.toInt(json["id"]),
        investorId: Parse.toInt(json["investor_id"]),
        mandateId: Parse.toInt(json["mandate_id"]),
        bankId: Parse.toInt(json["bank_id"]),
        umrnNo: Parse.toStrings(json["umrn_no"]),
        state: Parse.toStrings(json["state"]),
        amount: Parse.toInt(json["amount"]),
        bankAccountNo: Parse.toInt(json["bank_account_no"]),
        bankIfscCode: Parse.toStrings(json["bank_ifsc_code"]),
        createdAt: Parse.toDateTime(json["created_at"]),
        updatedAt: Parse.toDateTime(json["updated_at"]),
        bank: BankModel.fromJson(json["bank"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "investor_id": investorId,
        "mandate_id": mandateId,
        "bank_id": bankId,
        "umrn_no": umrnNo,
        "state": state,
        "amount": amount,
        "bank_account_no": bankAccountNo,
        "bank_account_type": bankAccountType,
        "bank_ifsc_code": bankIfscCode,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "bank": bank.toJson(),
      };
}

class BankModel {
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  BankModel({
    this.name = "",
    required this.createdAt,
    required this.updatedAt,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) => BankModel(
        name: Parse.toStrings(json["name"]),
        createdAt: Parse.toDateTime(json["created_at"]),
        updatedAt: Parse.toDateTime(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
