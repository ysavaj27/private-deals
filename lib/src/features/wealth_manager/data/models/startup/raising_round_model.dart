import 'package:private_deals/src/shared/functions/parse.dart';

class RaisingRoundModel {
  int id;
  String name;
  String roundType;
  String roundStatus;
  double sharePrice;
  double shuruCommission;
  String instrument;
  double floor;
  double cap;
  double equityOffered;
  double minimumInvestment;
  double minimumInvestmentAif;
  double totalFundRequirement;
  double fundRequirement;

  RaisingRoundModel({
    this.id = 0,
    this.name = '',
    this.roundType = '',
    this.roundStatus = '',
    this.sharePrice = 0.0,
    this.shuruCommission = 0.0,
    this.instrument = '',
    this.floor = 0.0,
    this.cap = 0.0,
    this.equityOffered = 0.0,
    this.minimumInvestment = 0,
    this.minimumInvestmentAif = 0,
    this.totalFundRequirement = 0,
    this.fundRequirement = 0,
  });

  factory RaisingRoundModel.fromJson(Map<String, dynamic> json) =>
      RaisingRoundModel(
        id: Parse.toInt(json["id"]),
        name: Parse.toStrings(json["name"]),
        roundType: Parse.toStrings(json["round_type"]),
        roundStatus: Parse.toStrings(json["round_status"]),
        sharePrice: Parse.toDouble(json["share_price"]),
        shuruCommission: Parse.toDouble(json["shuru_commission"]),
        instrument: Parse.toStrings(json["instrument"]),
        floor: Parse.toDouble(json["floor"]),
        cap: Parse.toDouble(json["cap"]),
        equityOffered: Parse.toDouble(json["equity_offered"]),
        minimumInvestment: Parse.toDouble(json["minimum_investment"]),
        minimumInvestmentAif: Parse.toDouble(json["minimum_investment_aif"]),
        totalFundRequirement: Parse.toDouble(json["total_fund_requirement"]),
        fundRequirement: Parse.toDouble(json["fund_requirement"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "round_type": roundType,
        "round_status": roundStatus,
        "share_price": sharePrice,
        "shuru_commission": shuruCommission,
        "instrument": instrument,
        "floor": floor,
        "cap": cap,
        "equity_offered": equityOffered,
        "minimum_investment": minimumInvestment,
        "minimum_investment_aif": minimumInvestmentAif,
        "total_fund_requirement": totalFundRequirement,
        "fund_requirement": fundRequirement,
      };
}
