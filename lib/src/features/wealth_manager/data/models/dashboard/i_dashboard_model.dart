import 'package:private_deals/src/features/wealth_manager/data/models/mis/mis_model.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

class IDashboardModel {
  Statistics statistics;
  PendingTasks pendingTasks;
  List<MisModel> mis;
  List<Sector> sectors;
  List<InvestmentGrowth> investmentGrowth;
  Investments investments;

  IDashboardModel({
    required this.statistics,
    required this.pendingTasks,
    required this.mis,
    required this.sectors,
    required this.investmentGrowth,
    required this.investments,
  });

  factory IDashboardModel.fromJson(Map<String, dynamic> json) =>
      IDashboardModel(
        statistics: Statistics.fromJson(json["statistics"] ?? {}),
        pendingTasks: PendingTasks.fromJson(json["pending_tasks"] ?? {}),
        mis: List<MisModel>.from(
            json["mis"]?.map((x) => MisModel.fromJson(x)) ?? []),
        sectors: List<Sector>.from(
            json["sectors"]?.map((x) => Sector.fromJson(x)) ?? []),
        investmentGrowth: List<InvestmentGrowth>.from(json["investment_growth"]
                ?.map((x) => InvestmentGrowth.fromJson(x)) ??
            []),
        investments: Investments.fromJson(json["investments"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "statistics": statistics.toJson(),
        "pending_tasks": pendingTasks.toJson(),
        "mis": List<dynamic>.from(mis.map((x) => x.toJson())),
        "sectors": List<dynamic>.from(sectors.map((x) => x.toJson())),
        "investment_growth":
            List<dynamic>.from(investmentGrowth.map((x) => x.toJson())),
        "investments": investments.toJson(),
      };
}

class Statistics {
  int totalStartupInvested;
  double totalInvestmentAmount;
  double profitBooked;
  double currentPortfolioValue;
  List<InvestmentList> list;

  Statistics({
    this.totalStartupInvested = 0,
    this.totalInvestmentAmount = 0.0,
    this.profitBooked = 0.0,
    this.currentPortfolioValue = 0.0,
    required this.list,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) => Statistics(
        totalStartupInvested: Parse.toInt(json["total_startup_invested"]),
        totalInvestmentAmount: Parse.toDouble(json["total_investment_amount"]),
        profitBooked: Parse.toDouble(json["profit_booked"]),
        currentPortfolioValue: Parse.toDouble(json["current_portfolio_value"]),
        list: List<InvestmentList>.from(
            json["list"]?.map((x) => InvestmentList.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "total_startup_invested": totalStartupInvested,
        "total_investment_amount": totalInvestmentAmount,
        "profit_booked": profitBooked,
        "current_portfolio_value": currentPortfolioValue,
        "list": List<dynamic>.from(list.map((x) => x.toJson())),
      };
}

class InvestmentList {
  String logo;
  int startupId;
  String startupName;
  double shares;
  double purchasePrice;
  double investmentAmount;
  double currentValue;
  DateTime createdAt;

  InvestmentList({
    this.logo = "",
    this.startupId = 0,
    this.startupName = "",
    this.shares = 0.0,
    this.purchasePrice = 0.0,
    this.investmentAmount = 0.0,
    this.currentValue = 0.0,
    required this.createdAt,
  });

  factory InvestmentList.fromJson(Map<String, dynamic> json) => InvestmentList(
        logo: Parse.parseUrl(json["logo"]),
        startupId: Parse.toInt(json["startup_id"]),
        startupName: Parse.toStrings(json["startup_name"]),
        shares: Parse.toDouble(json["shares"]),
        purchasePrice: Parse.toDouble(json["purchase_price"]),
        investmentAmount: Parse.toDouble(json["investment_amount"]),
        currentValue: Parse.toDouble(json["current_value"]),
        createdAt: Parse.toDateTime(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "logo": logo,
        "startup_id": startupId,
        "startup_name": startupName,
        "shares": shares,
        "purchase_price": purchasePrice,
        "investment_amount": investmentAmount,
        "current_value": currentValue,
        "created_at": createdAt.toIso8601String(),
      };
}

class PendingTasks {
  int ssaSign;
  int offerSign;
  int shaSign;
  int fundTransfer;
  int shareTransfer;

  PendingTasks({
    this.ssaSign = 0,
    this.offerSign = 0,
    this.shaSign = 0,
    this.fundTransfer = 0,
    this.shareTransfer = 0,
  });

  factory PendingTasks.fromJson(Map<String, dynamic> json) => PendingTasks(
        ssaSign: Parse.toInt(json["ssa_sign"]),
        offerSign: Parse.toInt(json["offer_sign"]),
        shaSign: Parse.toInt(json["sha_sign"]),
        fundTransfer: Parse.toInt(json["fund_transfer"]),
        shareTransfer: Parse.toInt(json["share_transfer"]),
      );

  Map<String, dynamic> toJson() => {
        "ssa_sign": ssaSign,
        "offer_sign": offerSign,
        "sha_sign": shaSign,
        "fund_transfer": fundTransfer,
        "share_transfer": shareTransfer,
      };
}

class Sector {
  int id;
  String name;
  double totalInvestment;
  List<SectorStartup> startups;

  Sector({
    this.id = 0,
    this.name = "",
    this.totalInvestment = 0,
    required this.startups,
  });

  factory Sector.fromJson(Map<String, dynamic> json) => Sector(
        id: Parse.toInt(json["id"]),
        name: Parse.toStrings(json["name"]),
        totalInvestment: Parse.toDouble(json["total_investment"]),
        startups: List<SectorStartup>.from(
            (json["startups"] ?? []).map((x) => SectorStartup.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "total_investment": totalInvestment,
        "startups": List<dynamic>.from(startups.map((x) => x.toJson())),
      };
}

class SectorStartup {
  int startupId;
  String startupName;
  double investmentAmount;
  double currentValue;
  double purchasePrice;
  double shares;
  DateTime createdAt;

  SectorStartup({
    this.startupId = 0,
    this.startupName = "",
    this.investmentAmount = 0.0,
    this.currentValue = 0.0,
    this.purchasePrice = 0.0,
    this.shares = 0.0,
    required this.createdAt,
  });

  factory SectorStartup.fromJson(Map<String, dynamic> json) => SectorStartup(
        startupId: Parse.toInt(json["startup_id"]),
        startupName: Parse.toStrings(json["startup_name"]),
        investmentAmount: Parse.toDouble(json["investment_amount"]),
        currentValue: Parse.toDouble(json["current_value"]),
        purchasePrice: Parse.toDouble(json["purchase_price"]),
        shares: Parse.toDouble(json["shares"]),
        createdAt: Parse.toDateTime(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "startup_id": startupId,
        "startup_name": startupName,
        "investment_amount": investmentAmount,
        "current_value": currentValue,
        "purchase_price": purchasePrice,
        "shares": shares,
        "created_at": createdAt.toIso8601String(),
      };
}

class InvestmentGrowth {
  int startupId;
  String startupName;
  double totalInvestedAmount;
  double currentValue;
  String logo;

  InvestmentGrowth({
    this.startupId = 0,
    this.startupName = "",
    this.totalInvestedAmount = 0.0,
    this.currentValue = 0.0,
    this.logo = "",
  });

  factory InvestmentGrowth.fromJson(Map<String, dynamic> json) =>
      InvestmentGrowth(
        startupId: Parse.toInt(json["startup_id"]),
        startupName: Parse.toStrings(json["startup_name"]),
        totalInvestedAmount: Parse.toDouble(json["total_invested_amount"]),
        currentValue: Parse.toDouble(json["current_value"]),
        logo: Parse.parseUrl(json["logo"]),
      );

  Map<String, dynamic> toJson() => {
        "startup_id": startupId,
        "startup_name": startupName,
        "total_invested_amount": totalInvestedAmount,
        "current_value": currentValue,
        "logo": logo,
      };
}

class Investments {
  List<MonthlyInvestment> monthly;
  List<QuarterlyInvestment> quarterly;

  Investments({
    required this.monthly,
    required this.quarterly,
  });

  factory Investments.fromJson(Map<String, dynamic> json) => Investments(
        monthly: List<MonthlyInvestment>.from(
            json["monthly"]?.map((x) => MonthlyInvestment.fromJson(x)) ?? []),
        quarterly: List<QuarterlyInvestment>.from(
            json["quarterly"]?.map((x) => QuarterlyInvestment.fromJson(x)) ??
                []),
      );

  Map<String, dynamic> toJson() => {
        "monthly": List<dynamic>.from(monthly.map((x) => x.toJson())),
        "quarterly": List<dynamic>.from(quarterly.map((x) => x.toJson())),
      };
}

class MonthlyInvestment {
  String month;
  double totalInvestment;

  MonthlyInvestment({
    this.month = "",
    this.totalInvestment = 0,
  });

  factory MonthlyInvestment.fromJson(Map<String, dynamic> json) =>
      MonthlyInvestment(
        month: Parse.toStrings(json["month"]),
        totalInvestment: Parse.toDouble(json["total_investment"]),
      );

  Map<String, dynamic> toJson() => {
        "month": month,
        "total_investment": totalInvestment,
      };
}

class QuarterlyInvestment {
  String quarter;
  DateTime start;
  DateTime end;
  double totalInvestment;

  QuarterlyInvestment({
    this.quarter = "",
    required this.start,
    required this.end,
    this.totalInvestment = 0,
  });

  factory QuarterlyInvestment.fromJson(Map<String, dynamic> json) =>
      QuarterlyInvestment(
        quarter: Parse.toStrings(json["quarter"]),
        start: Parse.toDateTime(json["start"]),
        end: Parse.toDateTime(json["end"]),
        totalInvestment: Parse.toDouble(json["total_investment"]),
      );

  Map<String, dynamic> toJson() => {
        "quarter": quarter,
        "start": start.toIso8601String(),
        "end": end.toIso8601String(),
        "total_investment": totalInvestment,
      };
}
