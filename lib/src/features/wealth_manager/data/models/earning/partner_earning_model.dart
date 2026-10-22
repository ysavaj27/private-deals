import 'package:private_deals/src/shared/functions/parse.dart';

class PartnerEarningModel {
  int totalPartners;
  double totalInvestment;
  double totalCommissionEarned;
  List<PartnerModel> list;

  PartnerEarningModel({
    this.totalPartners = 0,
    this.totalInvestment = 0.0,
    this.totalCommissionEarned = 0.0,
    this.list = const [],
  });

  factory PartnerEarningModel.fromJson(Map<String, dynamic> json) =>
      PartnerEarningModel(
        totalPartners: Parse.toInt(json["total_partners"]),
        totalInvestment: Parse.toDouble(json["total_investment"]),
        totalCommissionEarned: Parse.toDouble(json["total_commission_earned"]),
        list: json["list"] is List
            ? (json["list"] as List)
                .map((x) => PartnerModel.fromJson(x))
                .toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        "total_partners": totalPartners,
        "total_investment": totalInvestment,
        "total_commission_earned": totalCommissionEarned,
        "list": List<dynamic>.from(list.map((x) => x.toJson())),
      };
}

class PartnerModel {
  int partnerId;
  String name;
  double partnerTotalInvestment;
  double commissionEarnedFromThisPartner;

  PartnerModel({
    this.partnerId = 0,
    this.name = '',
    this.partnerTotalInvestment = 0.0,
    this.commissionEarnedFromThisPartner = 0.0,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) => PartnerModel(
        partnerId: Parse.toInt(json["partner_id"]),
        name: Parse.toStrings(json["name"]),
        partnerTotalInvestment:
            Parse.toDouble(json["partner_total_investment"]),
        commissionEarnedFromThisPartner:
            Parse.toDouble(json["commission_earned_from_this_partner"]),
      );

  Map<String, dynamic> toJson() => {
        "partner_id": partnerId,
        "name": name,
        "partner_total_investment": partnerTotalInvestment,
        "commission_earned_from_this_partner": commissionEarnedFromThisPartner,
      };
}
