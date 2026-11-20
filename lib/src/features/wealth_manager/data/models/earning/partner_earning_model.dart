import 'package:private_deals/src/shared/functions/parse.dart';

class PartnerEarningModel {
  double totalCommissionEarned;
  List<PartnerModel> list;

  PartnerEarningModel({this.totalCommissionEarned = 0.0, this.list = const []});

  factory PartnerEarningModel.fromJson(Map<String, dynamic> json) =>
      PartnerEarningModel(
        totalCommissionEarned: Parse.toDouble(json["total_commission_earned"]),
        list: json["list"] is List
            ? (json["list"] as List)
                  .map((x) => PartnerModel.fromJson(x))
                  .toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
    "total_commission_earned": totalCommissionEarned,
    "list": List<dynamic>.from(list.map((x) => x.toJson())),
  };
}

class PartnerModel {
  int partnerId;
  String name;
  String type;
  double commissionEarned;

  PartnerModel({
    this.partnerId = 0,
    this.name = '',
    this.type = '',
    this.commissionEarned = 0.0,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) => PartnerModel(
    partnerId: Parse.toInt(json["partner_id"]),
    name: Parse.toStrings(json["name"]),
    type: Parse.toStrings(json["type"]),
    commissionEarned: Parse.toDouble(json["commission_earned"]),
  );

  Map<String, dynamic> toJson() => {
    "partner_id": partnerId,
    "name": name,
    "type": type,
    "commission_earned": commissionEarned,
  };
}
