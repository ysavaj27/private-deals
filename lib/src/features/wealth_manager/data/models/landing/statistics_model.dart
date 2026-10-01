import 'package:private_deals/src/shared/functions/parse.dart';

class StatisticsModel {
  int investment;
  int secondary;
  int current;
  int funded;

  StatisticsModel({
    this.investment = 0,
    this.secondary = 0,
    this.current = 0,
    this.funded = 0,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) =>
      StatisticsModel(
        investment: Parse.toInt(json["investment"]),
        secondary: Parse.toInt(json["secondary"]),
        current: Parse.toInt(json["current"]),
        funded: Parse.toInt(json["funded"]),
      );

  Map<String, dynamic> toJson() => {
        "investment": investment,
        "secondary": secondary,
        "current": current,
        "funded": funded,
      };
}
