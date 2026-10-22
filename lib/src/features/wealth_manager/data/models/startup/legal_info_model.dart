import 'package:private_deals/src/shared/functions/parse.dart';

class LegalInfoModel {
  String cin;
  DateTime incorporationDate;

  LegalInfoModel({
    this.cin = "",
    required this.incorporationDate,
  });

  factory LegalInfoModel.fromJson(Map<String, dynamic> json) => LegalInfoModel(
        cin: Parse.toStrings(json["cin"]),
        incorporationDate: Parse.toDateTime(json["incorporation_date"]),
      );

  Map<String, dynamic> toJson() => {
        "cin": cin,
        "incorporation_date": incorporationDate.toIso8601String(),
      };
}
