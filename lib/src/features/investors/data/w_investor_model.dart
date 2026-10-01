import 'package:private_deals/src/shared/functions/parse.dart';

class WInvestorModel {
  int investorId;
  String name;
  String profilePhoto;
  int totalStartups;
  double totalInvestment;
  double commissionEarned;
  double amountInvested;

  WInvestorModel({
    this.investorId = 0,
    this.name = '',
    this.profilePhoto = '',
    this.totalStartups = 0,
    this.totalInvestment = 0.0,
    this.commissionEarned = 0.0,
    this.amountInvested = 0.0,
  });

  factory WInvestorModel.fromJson(Map<String, dynamic> json) => WInvestorModel(
    investorId: Parse.toInt(json["investor_id"]),
    name: Parse.toStrings(json["name"]),
    profilePhoto: Parse.parseUrl(json["profile_photo"]),
    totalStartups: Parse.toInt(json["total_startups"]),
    totalInvestment: Parse.toDouble(json["total_investment"]),
    commissionEarned: Parse.toDouble(json["commission_earned"]),
    amountInvested: Parse.toDouble(json["amount_invested"]),
  );

  Map<String, dynamic> toJson() => {
    "investor_id": investorId,
    "name": name,
    "profile_photo": profilePhoto,
    "total_startups": totalStartups,
    "total_investment": totalInvestment,
    "commission_earned": commissionEarned,
    "amount_invested": amountInvested,
  };
}
