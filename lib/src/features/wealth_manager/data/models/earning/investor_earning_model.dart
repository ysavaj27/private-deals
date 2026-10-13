import 'package:private_deals/src/features/investors/data/w_investor_model.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

class InvestorEarningModel {
  double amountInvested;
  int totalTransactions;
  double commissionEarned;
  List<WInvestorModel> investorsList;

  InvestorEarningModel({
    this.amountInvested = 0.0,
    this.totalTransactions = 0,
    this.commissionEarned = 0.0,
    required this.investorsList,
  });

  factory InvestorEarningModel.fromJson(Map<String, dynamic> json) =>
      InvestorEarningModel(
        amountInvested: Parse.toDouble(json["amount_invested"]),
        totalTransactions: Parse.toInt(json["total_transactions"]),
        commissionEarned: Parse.toDouble(json["commission_earned"]),
        investorsList: List<WInvestorModel>.from(
            json["investors_list"]?.map((x) => WInvestorModel.fromJson(x)) ??
                []),
      );

  Map<String, dynamic> toJson() => {
        "amount_invested": amountInvested,
        "total_transactions": totalTransactions,
        "commission_earned": commissionEarned,
        "investors_list":
            List<dynamic>.from(investorsList.map((x) => x.toJson())),
      };
}
