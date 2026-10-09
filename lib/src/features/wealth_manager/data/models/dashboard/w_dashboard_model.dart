import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

class WDashboardModel {
  int totalStartups;
  int totalInvestors;
  double totalAmountInvested;
  double pendingPayment;
  int pendingDocumentSign;
  int pendingKyc;
  double averageTicketSize;
  List<WInvestorModel> investors;
  List<WInvestorModel> topInvestors;
  List<WSector> sectors;
  List<InvestmentGrowthModel> investmentGrowth;
  InvestmentTimeline investments;
  InvestorChartModel investorChartModel;

  WDashboardModel({
    this.totalStartups = 0,
    this.totalInvestors = 0,
    this.totalAmountInvested = 0.0,
    this.averageTicketSize = 0.0,
    this.pendingPayment = 0,
    this.pendingDocumentSign = 0,
    this.pendingKyc = 0,
    required this.investors,
    required this.topInvestors,
    required this.sectors,
    required this.investmentGrowth,
    required this.investments,
    required this.investorChartModel,
  });

  factory WDashboardModel.fromJson(Map<String, dynamic> json) =>
      WDashboardModel(
        totalStartups: Parse.toInt(json["total_startups"]),
        totalInvestors: Parse.toInt(json["total_investors"]),
        pendingDocumentSign: Parse.toInt(json["pending_document_sign"]),
        pendingKyc: Parse.toInt(json["pending_kyc"]),
        totalAmountInvested: Parse.toDouble(json["total_amount_invested"]),
        averageTicketSize: Parse.toDouble(json["average_ticket_size"]),
        pendingPayment: Parse.toDouble(json["pending_payment"]),
        investors: List<WInvestorModel>.from(
          json["investors"]?.map((x) => WInvestorModel.fromJson(x)) ?? [],
        ),
        topInvestors: List<WInvestorModel>.from(
          json["top_investors"]?.map((x) => WInvestorModel.fromJson(x)) ?? [],
        ),
        sectors: List<WSector>.from(
          json["sectors"]?.map((x) => WSector.fromJson(x)) ?? [],
        ),
        investmentGrowth: List<InvestmentGrowthModel>.from(
          json["investment_growth"]?.map(
                (x) => InvestmentGrowthModel.fromJson(x),
              ) ??
              [],
        ),
        investments: InvestmentTimeline.fromJson(json["investments"] ?? {}),
        investorChartModel: InvestorChartModel.fromJson(
          json["investor_chart"] ?? {},
        ),
      );

  Map<String, dynamic> toJson() => {
    "total_startups": totalStartups,
    "total_investors": totalInvestors,
    "total_amount_invested": totalAmountInvested,
    "average_ticket_size": averageTicketSize,
    "pending_payment": pendingPayment,
    "pending_document_sign": pendingDocumentSign,
    "pending_kyc": pendingKyc,
    "investors": List<dynamic>.from(investors.map((x) => x.toJson())),
    "top_investors": List<dynamic>.from(topInvestors.map((x) => x.toJson())),
    "sectors": List<dynamic>.from(sectors.map((x) => x.toJson())),
    "investment_growth": List<dynamic>.from(
      investmentGrowth.map((x) => x.toJson()),
    ),
    "investments": investments.toJson(),
    "investor_chart": investorChartModel.toJson(),
  };
}

class WSector {
  int id;
  String name;
  double totalInvestment;
  List<WStartup> startups;

  WSector({
    this.id = 0,
    this.name = '',
    this.totalInvestment = 0.0,
    required this.startups,
  });

  factory WSector.fromJson(Map<String, dynamic> json) => WSector(
    id: Parse.toInt(json["id"]),
    name: Parse.toStrings(json["name"]), // Use Parse.toStrings for name
    totalInvestment: Parse.toDouble(json["total_investment"]),
    startups: List<WStartup>.from(
      json["startups"]?.map((x) => WStartup.fromJson(x)) ?? [],
    ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "total_investment": totalInvestment,
    "startups": List<dynamic>.from(startups.map((x) => x.toJson())),
  };
}

class WStartup {
  int startupId;
  String startupName;
  String investorName;
  double investmentAmount;
  double currentValue;
  double purchasePrice;
  double shares;
  DateTime createdAt;

  WStartup({
    this.startupId = 0,
    this.startupName = '',
    this.investorName = '',
    this.investmentAmount = 0.0,
    this.currentValue = 0.0,
    this.purchasePrice = 0.0,
    this.shares = 0,
    required this.createdAt,
  });

  factory WStartup.fromJson(Map<String, dynamic> json) => WStartup(
    startupId: Parse.toInt(json["startup_id"]),
    // Use Parse.toInt for startupId
    startupName: Parse.toStrings(json["startup_name"]),
    // Use Parse.toStrings for startupName
    investorName: Parse.toStrings(json["investor_name"]),
    // Use Parse.toStrings for investorName
    investmentAmount: Parse.toDouble(json["investment_amount"]),
    // Use Parse.toDouble for investmentAmount
    currentValue: Parse.toDouble(json["current_value"]),
    // Use Parse.toDouble for currentValue
    purchasePrice: Parse.toDouble(json["purchase_price"]),
    // Use Parse.toDouble for purchasePrice
    shares: Parse.toDouble(json["shares"]),
    // Use Parse.toInt for shares
    createdAt: Parse.toDateTime(
      json["created_at"],
    ), // Use Parse.toDateTime for createdAt
  );

  Map<String, dynamic> toJson() => {
    "startup_id": startupId,
    "startup_name": startupName,
    "investor_name": investorName,
    "investment_amount": investmentAmount,
    "current_value": currentValue,
    "purchase_price": purchasePrice,
    "shares": shares,
    "created_at": createdAt.toIso8601String(),
  };
}

class InvestmentGrowthModel {
  int startupId;
  String startupName;
  double totalInvestedAmount;
  double currentValue;
  bool hasCurrentValue;
  String logo;

  InvestmentGrowthModel({
    this.startupId = 0,
    this.startupName = '',
    this.totalInvestedAmount = 0.0,
    this.currentValue = 0.0,
    this.hasCurrentValue = true,
    this.logo = '',
  });

  factory InvestmentGrowthModel.fromJson(Map<String, dynamic> json) =>
      InvestmentGrowthModel(
        startupId: Parse.toInt(json["startup_id"]),
        // Use Parse.toInt for startupId
        startupName: Parse.toStrings(json["startup_name"]),
        // Use Parse.toStrings for startupName
        totalInvestedAmount: Parse.toDouble(json["total_invested_amount"]),
        // Use Parse.toDouble for totalInvestedAmount
        currentValue: Parse.toDouble(json["current_value"]),
        hasCurrentValue:
            double.tryParse(json["current_value"].toString())?.isFinite ??
            false,
        // Use Parse.toDouble for currentValue
        logo: Parse.parseUrl(json["logo"]),
      );

  Map<String, dynamic> toJson() => {
    "startup_id": startupId,
    "startup_name": startupName,
    "total_invested_amount": totalInvestedAmount,
    "current_value": hasCurrentValue ? currentValue : null,
    "logo": logo,
  };
}

class InvestmentTimeline {
  List<MonthlyInvestmentModel> monthly;
  List<QuarterlyInvestmentModel> quarterly;

  InvestmentTimeline({required this.monthly, required this.quarterly});

  factory InvestmentTimeline.fromJson(Map<String, dynamic> json) =>
      InvestmentTimeline(
        monthly: List<MonthlyInvestmentModel>.from(
          json["monthly"]?.map((x) => MonthlyInvestmentModel.fromJson(x)) ?? [],
        ),
        quarterly: List<QuarterlyInvestmentModel>.from(
          json["quarterly"]?.map((x) => QuarterlyInvestmentModel.fromJson(x)) ??
              [],
        ),
      );

  Map<String, dynamic> toJson() => {
    "monthly": List<dynamic>.from(monthly.map((x) => x.toJson())),
    "quarterly": List<dynamic>.from(quarterly.map((x) => x.toJson())),
  };
}

class MonthlyInvestmentModel {
  String month;
  double totalInvestment;

  MonthlyInvestmentModel({this.month = '', this.totalInvestment = 0.0});

  factory MonthlyInvestmentModel.fromJson(Map<String, dynamic> json) =>
      MonthlyInvestmentModel(
        month: Parse.toStrings(json["month"]), // Use Parse.toStrings for month
        totalInvestment: Parse.toDouble(
          json["total_investment"],
        ), // Use Parse.toDouble for totalInvestment
      );

  Map<String, dynamic> toJson() => {
    "month": month,
    "total_investment": totalInvestment,
  };
}

class QuarterlyInvestmentModel {
  String quarter;
  DateTime start;
  DateTime end;
  double totalInvestment;

  QuarterlyInvestmentModel({
    this.quarter = '',
    required this.start,
    required this.end,
    this.totalInvestment = 0.0,
  });

  factory QuarterlyInvestmentModel.fromJson(Map<String, dynamic> json) =>
      QuarterlyInvestmentModel(
        quarter: Parse.toStrings(json["quarter"] ?? json["quater"]),
        start: Parse.toDateTime(json["start"]),
        end: Parse.toDateTime(json["end"]),
        totalInvestment: Parse.toDouble(json["total_investment"]),
      );

  Map<String, dynamic> toJson() => {
    "quater": quarter,
    "start": start.toIso8601String(),
    "end": end.toIso8601String(),
    "total_investment": totalInvestment,
  };
}

class InvestorChartModel {
  List<Active> kyc;
  List<Active> active;

  InvestorChartModel({
    this.kyc = const [], // Initialize with an empty list
    this.active = const [], // Initialize with an empty list
  });

  factory InvestorChartModel.fromJson(Map<String, dynamic> json) =>
      InvestorChartModel(
        kyc: json["kyc"] != null
            ? List<Active>.from(json["kyc"].map((x) => Active.fromJson(x)))
            : const [],
        active: json["active"] != null
            ? List<Active>.from(json["active"].map((x) => Active.fromJson(x)))
            : const [],
      );

  Map<String, dynamic> toJson() => {
    "kyc": List<dynamic>.from(kyc.map((x) => x.toJson())),
    "active": List<dynamic>.from(active.map((x) => x.toJson())),
  };
}

class Active {
  int id;
  String name;
  int mobileNumber;
  String email;
  int isActive;
  int kycStatus;

  Active({
    this.id = 0,
    this.name = '',
    this.mobileNumber = 0,
    this.email = '',
    this.isActive = 0,
    this.kycStatus = 0,
  });

  factory Active.fromJson(Map<String, dynamic> json) => Active(
    id: Parse.toInt(json["id"]),
    name: Parse.toStrings(json["name"]),
    mobileNumber: Parse.toInt(json["mobile_number"]),
    email: Parse.toStrings(json["email"]),
    isActive: Parse.toInt(json["is_active"], -1),
    kycStatus: Parse.toInt(json["kyc_status"], -1),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "mobile_number": mobileNumber,
    "email": email,
    "is_active": isActive,
    "kyc_status": kycStatus,
  };
}
