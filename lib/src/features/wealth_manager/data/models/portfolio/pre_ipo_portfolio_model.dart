import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/portfolio/portfolio_model.dart';
import 'package:private_deals/src/features/investors/data/investor_model.dart';
import 'package:private_deals/src/shared/functions/parse.dart';
import 'package:flutter/material.dart';

class PreIPOPortfolioListModel {
  final PortfolioInvestor investor;
  final int totalCompanyCount;
  final double totalInvestmentAmount;
  final List<PreIPOPortfolioModel> holdings;

  PreIPOPortfolioListModel({
    required this.investor,
    required this.totalCompanyCount,
    required this.totalInvestmentAmount,
    required this.holdings,
  });

  factory PreIPOPortfolioListModel.fromJson(Map<String, dynamic> json) {
    return PreIPOPortfolioListModel(
      investor: PortfolioInvestor.fromJson(
        json['investor'] as Map<String, dynamic>? ?? {},
      ),
      totalCompanyCount: Parse.toInt(json['total_company_count']),
      totalInvestmentAmount: Parse.toDouble(json['total_investment_amount']),
      holdings: json["holdings"] != null
          ? List<PreIPOPortfolioModel>.from(
              json["holdings"].map((x) => PreIPOPortfolioModel.fromJson(x)))
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

class PreIPOPortfolioModel {
  int id;
  double shares;
  double purchasePrice;
  double investmentAmount;
  CompanyData company;
  InvestorModel investor;
  double currentSharePrice;
  double lastTradedPrice;
  double sharesSold;
  double onSellShares;

  bool get isAvailableShare => availableShares != 0 ? true : false;

  bool get canSell => availableSharesPrices >= app.config.preIpoMinSellAmount;

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

  PreIPOPortfolioModel({
    this.id = 0,
    this.shares = 0,
    this.purchasePrice = 0.0,
    this.investmentAmount = 0.0,
    required this.company,
    required this.investor,
    this.currentSharePrice = 0.0,
    this.lastTradedPrice = 0.0,
    this.sharesSold = 0,
    this.onSellShares = 0,
  });

  factory PreIPOPortfolioModel.fromJson(Map<String, dynamic> json) =>
      PreIPOPortfolioModel(
        id: Parse.toInt(json["id"]),
        shares: Parse.toDouble(json["shares"]),
        purchasePrice: Parse.toDouble(json["purchase_price"]),
        investmentAmount: Parse.toDouble(json["investment_amount"]),
        currentSharePrice: Parse.toDouble(json["current_share_price"]),
        lastTradedPrice: Parse.toDouble(json["last_traded_price"]),
        sharesSold: Parse.toDouble(json["shares_sold"]),
        onSellShares: Parse.toDouble(json["on_sell_shares"]),
        company: CompanyData.fromJson(json["company"] ?? {}),
        investor: InvestorModel.fromJson(json["investor"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "shares": shares,
        "purchase_price": purchasePrice,
        "investment_amount": investmentAmount,
        "last_traded_price": lastTradedPrice,
        "shares_sold": sharesSold,
        "on_sell_shares": onSellShares,
        "current_share_price": currentSharePrice,
        "company": company.toJson(),
        "investor": investor.toJson(),
      };
}

class CompanyData {
  int id;
  String brandName;
  String logo;

  CompanyData({
    this.id = 0,
    this.brandName = '',
    this.logo = '',
  });

  factory CompanyData.fromJson(Map<String, dynamic> json) => CompanyData(
        id: Parse.toInt(json["id"]),
        brandName: Parse.toStrings(json["brand_name"]),
        logo: Parse.parseUrl(json["logo"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "brand_name": brandName,
        "logo": logo,
      };
}
