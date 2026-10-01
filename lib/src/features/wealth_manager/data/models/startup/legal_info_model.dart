import 'package:private_deals/src/shared/functions/parse.dart';

class LegalInfoModel {
  String companyName;
  String companyPan;
  String cin;
  String bankAcName;
  String bankName;
  int bankAcNo;
  String bankIfsc;
  String bankUan;
  int dpiit;
  DateTime incorporationDate;

  LegalInfoModel({
    this.companyName = "",
    this.companyPan = "",
    this.cin = "",
    this.bankAcName = "",
    this.bankName = "",
    this.bankAcNo = 0,
    this.bankIfsc = "",
    this.bankUan = "",
    this.dpiit = 0,
    required this.incorporationDate,
  });

  factory LegalInfoModel.fromJson(Map<String, dynamic> json) => LegalInfoModel(
        companyName: Parse.toStrings(json["company_name"]),
        companyPan: Parse.toStrings(json["company_pan"]),
        cin: Parse.toStrings(json["cin"]),
        bankAcName: Parse.toStrings(json["bank_ac_name"]),
        bankName: Parse.toStrings(json["bank_name"]),
        bankAcNo: Parse.toInt(json["bank_ac_no"]),
        bankIfsc: Parse.toStrings(json["bank_ifsc"]),
        bankUan: Parse.toStrings(json["bank_uan"]),
        dpiit: Parse.toInt(json["dpiit"]),
        incorporationDate: Parse.toDateTime(json["incorporation_date"]),
      );

  Map<String, dynamic> toJson() => {
        "company_name": companyName,
        "company_pan": companyPan,
        "cin": cin,
        "bank_ac_name": bankAcName,
        "bank_name": bankName,
        "bank_ac_no": bankAcNo,
        "bank_ifsc": bankIfsc,
        "bank_uan": bankUan,
        "dpiit": dpiit,
        "incorporation_date": incorporationDate.toIso8601String(),
      };
}
