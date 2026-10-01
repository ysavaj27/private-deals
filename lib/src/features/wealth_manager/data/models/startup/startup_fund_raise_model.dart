import 'package:private_deals/src/shared/functions/parse.dart';

class StartupFundRaiseModel {
  double fundRequirement;
  double currentFundRaise;
  double fundsRequiredFromShuru;
  double minTicketSize;
  double preMoneyValuation;
  double previousFundRaisedAmount;
  double valuationOfPreviousRound;

  StartupFundRaiseModel({
    this.fundRequirement = 0.0,
    this.currentFundRaise = 0.0,
    this.fundsRequiredFromShuru = 0.0,
    this.minTicketSize = 0.0,
    this.preMoneyValuation = 0.0,
    this.previousFundRaisedAmount = 0.0,
    this.valuationOfPreviousRound = 0.0,
  });

  factory StartupFundRaiseModel.fromJson(Map<String, dynamic> json) =>
      StartupFundRaiseModel(
        fundRequirement: Parse.toDouble(json["fund_requirement"]),
        currentFundRaise: Parse.toDouble(json["current_fund_raise"]),
        fundsRequiredFromShuru:
            Parse.toDouble(json["funds_required_from_shuru"]),
        minTicketSize: Parse.toDouble(json["min_ticket_size"]),
        preMoneyValuation: Parse.toDouble(json["pre_money_valuation"]),
        previousFundRaisedAmount:
            Parse.toDouble(json["previous_fund_raised_amount"]),
        valuationOfPreviousRound:
            Parse.toDouble(json["valuation_of_previous_round"]),
      );

  Map<String, dynamic> toJson() => {
        "fund_requirement": fundRequirement,
        "current_fund_raise": currentFundRaise,
        "funds_required_from_shuru": fundsRequiredFromShuru,
        "min_ticket_size": minTicketSize,
        "pre_money_valuation": preMoneyValuation,
        "previous_fund_raised_amount": previousFundRaisedAmount,
        "valuation_of_previous_round": valuationOfPreviousRound,
      };
}
