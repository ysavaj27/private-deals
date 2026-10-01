import 'package:private_deals/src/features/wealth_manager/data/models/startup/startup_round_model.dart';

import 'package:private_deals/src/features/wealth_manager/data/models/landing/statistics_model.dart';

class LandingPageModel {
  StatisticsModel statistics;
  List<StartupRoundModel> raisingNow;
  List<StartupRoundModel> comingSoon;
  List<StartupRoundModel> completed;

  LandingPageModel({
    required this.statistics,
    required this.raisingNow,
    required this.comingSoon,
    required this.completed,
  });

  factory LandingPageModel.fromJson(Map<String, dynamic> json) =>
      LandingPageModel(
        statistics: StatisticsModel.fromJson(json["statistics"] ?? {}),
        raisingNow: json["raisingNow"] != null
            ? List<StartupRoundModel>.from(
                json["raisingNow"].map((x) => StartupRoundModel.fromJson(x)))
            : [],
        comingSoon: json["comingSoon"] != null
            ? List<StartupRoundModel>.from(
                json["comingSoon"].map((x) => StartupRoundModel.fromJson(x)))
            : [],
        completed: json["completed"] != null
            ? List<StartupRoundModel>.from(
                json["completed"].map((x) => StartupRoundModel.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "statistics": statistics.toJson(),
        "raisingNow": List<dynamic>.from(raisingNow.map((x) => x.toJson())),
        "comingSoon": List<dynamic>.from(comingSoon.map((x) => x.toJson())),
        "completed": List<dynamic>.from(completed.map((x) => x.toJson())),
      };
}
