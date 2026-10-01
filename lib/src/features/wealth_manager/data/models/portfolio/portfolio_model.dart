import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/startup/startup_model.dart';
import 'package:private_deals/src/features/investors/data/investor_model.dart';
import 'package:private_deals/src/shared/functions/parse.dart';
import 'package:flutter/material.dart';

class StartupPortfolioListModel {
  final PortfolioInvestor investor;
  final int totalCompanyCount;
  final double totalInvestmentAmount;
  final List<PortfolioModel> holdings;

  StartupPortfolioListModel({
    required this.investor,
    required this.totalCompanyCount,
    required this.totalInvestmentAmount,
    required this.holdings,
  });

  factory StartupPortfolioListModel.fromJson(Map<String, dynamic> json) {
    return StartupPortfolioListModel(
      investor: PortfolioInvestor.fromJson(json['investor'] ?? {}),
      totalCompanyCount: Parse.toInt(json['total_company_count']),
      totalInvestmentAmount: Parse.toDouble(json['total_investment_amount']),
      holdings: json["holdings"] != null
          ? List<PortfolioModel>.from(
              json["holdings"].map((x) => PortfolioModel.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'investor': investor.toJson(),
      'total_company_count': totalCompanyCount,
      'total_investment_amount': totalInvestmentAmount,
      "holdings": List<dynamic>.from(holdings.map((x) => x.toJson())),
    };
  }
}

class PortfolioModel {
  int id;
  int investorId;
  int startupId;
  double shares;
  double purchasePrice;
  double investmentAmount;
  double currentSharePrice;
  double lastTradedPrice;
  String instrument;
  int isShareTransferred;
  int createdBy;
  int updatedBy;
  double minimumShares;
  double sharesSold;
  double onSellShares;
  bool isPrimaryTransaction;
  bool isSecondaryTransaction;
  DateTime createdAt;
  DateTime updatedAt;
  StartupModel startup;
  InvestorModel investor;

  bool get canSell => availableShares != 0 &&
          availableSharesPrices >= app.config.preIpoMinSellAmount
      ? true
      : false;

  bool get isAvailableShare => availableShares != 0 ? true : false;

  String get name => "From: "
          "${isPrimaryTransaction ? "Primary" : ""}"
          "${isSecondaryTransaction ? " Secondary" : ""}"
      .trim();

  double get availableSharesPrices => availableShares * currentSharePrice;

  double get availableShares =>
      (shares - onSellShares) < 0 ? 0 : shares - onSellShares;

  // Getter for total current price
  double get totalCurrentPrice => shares * currentSharePrice;

  // Getter for total purchase price
  double get totalPurchasePrice => shares * purchasePrice;

  // Getter for profit amount
  double get profitAmount => totalCurrentPrice - totalPurchasePrice;

  // Getter for profit percentage
  String get profitPercentage {
    if (totalPurchasePrice == 0) {
      return "0%"; // To avoid division by zero
    }
    return "${((profitAmount / totalPurchasePrice) * 100).toStringAsFixed(2)}%";
  }

  // Getter for color based on profit/loss status
  Color? get profitColor {
    if (profitAmount > 0) {
      return Colors.green; // Profit
    } else if (profitAmount < 0) {
      return Colors.red; // Loss
    } else {
      return null; // No profit, no loss
    }
  }

  PortfolioModel({
    this.id = 0,
    this.investorId = 0,
    this.startupId = 0,
    this.shares = 0,
    this.purchasePrice = 0.0,
    this.investmentAmount = 0.0,
    this.currentSharePrice = 0.0,
    this.lastTradedPrice = 0.0,
    this.instrument = '',
    this.isShareTransferred = 0,
    this.createdBy = 0,
    this.updatedBy = 0,
    this.minimumShares = 0,
    this.sharesSold = 0,
    this.onSellShares = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.startup,
    required this.investor,
    this.isPrimaryTransaction = false,
    this.isSecondaryTransaction = false,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) => PortfolioModel(
        id: Parse.toInt(json["id"]),
        investorId: Parse.toInt(json["investor_id"]),
        startupId: Parse.toInt(json["startup_id"]),
        shares: Parse.toDouble(json["shares"]),
        purchasePrice: Parse.toDouble(json["purchase_price"]),
        investmentAmount: Parse.toDouble(json["investment_amount"]),
        currentSharePrice: Parse.toDouble(json["current_share_price"]),
        lastTradedPrice: Parse.toDouble(json["last_traded_price"]),
        instrument: Parse.toStrings(json["instrument"]),
        isShareTransferred: Parse.toInt(json["is_share_transfered"]),
        createdBy: Parse.toInt(json["created_by"]),
        updatedBy: Parse.toInt(json["updated_by"]),
        minimumShares: Parse.toDouble(json["minimum_shares"]),
        sharesSold: Parse.toDouble(json["shares_sold"]),
        onSellShares: Parse.toDouble(json["on_sell_shares"]),
        isPrimaryTransaction: json["is_primary_transaction"] ?? false,
        isSecondaryTransaction: json["is_secondary_transaction"] ?? false,
        createdAt: Parse.toDateTime(json["created_at"]),
        updatedAt: Parse.toDateTime(json["updated_at"]),
        startup: StartupModel.fromJson(json["startup"] ?? {}),
        investor: InvestorModel.fromJson(json["investor"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "investor_id": investorId,
        "startup_id": startupId,
        "shares": shares,
        "purchase_price": purchasePrice,
        "last_traded_price": lastTradedPrice,
        "investment_amount": investmentAmount,
        "instrument": instrument,
        "is_share_transfered": isShareTransferred,
        "created_by": createdBy,
        "current_share_price": currentSharePrice,
        "updated_by": updatedBy,
        "minimum_shares": minimumShares,
        "shares_sold": sharesSold,
        "on_sell_shares": onSellShares,
        "is_primary_transaction": isPrimaryTransaction,
        "is_secondary_transaction": isSecondaryTransaction,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "startup": startup.toJson(),
        "investor": investor.toJson(),
      };
}

class PortfolioInvestor {
  final int id;
  final String uuid;
  final String name;
  final String profilePhoto;

  PortfolioInvestor({
    required this.id,
    required this.uuid,
    required this.name,
    required this.profilePhoto,
  });

  factory PortfolioInvestor.fromJson(Map<String, dynamic> json) {
    return PortfolioInvestor(
      id: Parse.toInt(json['id']),
      uuid: Parse.toStrings(json['uuid']),
      name: Parse.toStrings(json['name']),
      profilePhoto: Parse.parseUrl(
        Parse.toStrings(json['profile_photo']),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'profile_photo': profilePhoto,
    };
  }
}
