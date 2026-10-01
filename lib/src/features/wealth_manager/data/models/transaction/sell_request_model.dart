import 'package:private_deals/src/shared/functions/parse.dart';

import 'package:private_deals/src/shared/app_exports.dart';

class SellRequestModel {
  int id;
  int status;
  String instrument;
  int startupId;
  int portfolioId;
  int investorId;
  double shares;
  double availableShares;
  double minimumShares;
  double soldShares;
  double price;
  double purchasePrice;
  double currentPrice;
  double lastTradedPrice;
  String currentStatus;
  String startupName;
  String startupLogo;
  DateTime createdAt;
  DateTime updatedAt;
  StartupModel startup;
  List<SecondaryTransactionModel> transactions;

  SellRequestModel({
    this.id = 0,
    this.status = 0,
    this.instrument = "",
    this.startupId = 0,
    this.portfolioId = 0,
    this.investorId = 0,
    this.shares = 0,
    this.availableShares = 0,
    this.minimumShares = 0,
    this.soldShares = 0,
    this.price = 0.0,
    this.lastTradedPrice = 0.0,
    this.purchasePrice = 0.0,
    this.currentPrice = 0.0,
    this.currentStatus = "",
    this.startupName = '',
    this.startupLogo = '',
    required this.createdAt,
    required this.updatedAt,
    required this.startup,
    this.transactions = const [],
  });

  factory SellRequestModel.fromJson(Map<String, dynamic> json) {
    return SellRequestModel(
      id: Parse.toInt(json["id"]),
      status: Parse.toInt(json["status"]),
      instrument: Parse.toStrings(json["instrument"]),
      startupId: Parse.toInt(json["startup_id"]),
      portfolioId: Parse.toInt(json["portfolio_id"]),
      investorId: Parse.toInt(json["investor_id"]),
      shares: Parse.toDouble(json["shares"]),
      availableShares: Parse.toDouble(json["available_shares"]),
      minimumShares: Parse.toDouble(json["minimum_shares"]),
      soldShares: Parse.toDouble(json["sold_shares"]),
      price: Parse.toDouble(json["price"]),
      purchasePrice: Parse.toDouble(json["purchase_price"]),
      currentPrice: Parse.toDouble(json["current_price"]),
      lastTradedPrice: Parse.toDouble(json["last_traded_price"]),
      currentStatus: Parse.toStrings(json["current_status"]),
      startupName: Parse.toStrings(json["startup"]?["brand"]),
      startupLogo: Parse.parseUrl(json["startup"]?["startup_logo"]),
      createdAt: Parse.toDateTime(json["created_at"]),
      updatedAt: Parse.toDateTime(json["updated_at"]),
      startup: StartupModel.fromJson(json["startup"] ?? {}),
      transactions: json["transactions"] != null
          ? List<SecondaryTransactionModel>.from(json["transactions"]
              .map((x) => SecondaryTransactionModel.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "instrument": instrument,
        "startup_id": startupId,
        "portfolio_id": portfolioId,
        "investor_id": investorId,
        "shares": shares,
        "price": price,
        "available_shares": availableShares,
        "minimum_shares": minimumShares,
        "sold_shares": soldShares,
        "purchase_price": purchasePrice,
        "current_price": currentPrice,
        "last_traded_price": lastTradedPrice,
        "current_status": currentStatus,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "startup_name": startupName,
        "startup_logo": startupLogo,
        "startup": startup.toJson(),
        "transactions": List<dynamic>.from(transactions.map((x) => x.toJson())),
      };
}
