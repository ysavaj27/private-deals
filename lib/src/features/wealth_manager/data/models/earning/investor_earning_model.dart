import 'package:private_deals/src/features/investors/data/w_investor_model.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

class InvestorEarningModel {
  int totalInvestors;
  double totalInvestment;
  double commissionEarned;
  List<WInvestorModel> investorsList;

  InvestorEarningModel({
    this.totalInvestors = 0,
    this.totalInvestment = 0.0,
    this.commissionEarned = 0.0,
    required this.investorsList,
  });

  factory InvestorEarningModel.fromJson(Map<String, dynamic> json) =>
      InvestorEarningModel(
        totalInvestors: Parse.toInt(json["total_investors"]),
        totalInvestment: Parse.toDouble(json["total_investment"]),
        commissionEarned: Parse.toDouble(json["commission_earned"]),
        investorsList: List<WInvestorModel>.from(
            json["investors_list"]?.map((x) => WInvestorModel.fromJson(x)) ??
                []),
      );

  Map<String, dynamic> toJson() => {
        "total_investors": totalInvestors,
        "total_investment": totalInvestment,
        "commission_earned": commissionEarned,
        "investors_list":
            List<dynamic>.from(investorsList.map((x) => x.toJson())),
      };
}
