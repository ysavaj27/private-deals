import 'package:private_deals/src/shared/functions/parse.dart';

import 'package:private_deals/src/features/wealth_manager/data/models/pre_ipo/pre_ipo_transaction_model.dart';

class PreIpoSellTransactionModel {
  int id;
  int status;
  int companyId;
  int portfolioId;
  int investorId;
  int shares;
  double price;
  double purchasePrice;
  double currentPrice;
  double lastTradedPrice;
  String file;
  DateTime createdAt;
  DateTime updatedAt;
  String currentStatus;
  String nextStep;
  Company company;

  PreIpoSellTransactionModel({
    this.id = 0,
    this.status = 0,
    this.companyId = 0,
    this.portfolioId = 0,
    this.investorId = 0,
    this.shares = 0,
    this.price = 0,
    this.purchasePrice = 0,
    this.currentPrice = 0,
    this.lastTradedPrice = 0,
    this.file = '',
    required this.createdAt,
    required this.updatedAt,
    this.currentStatus = '',
    this.nextStep = '',
    required this.company,
  });

  factory PreIpoSellTransactionModel.fromJson(Map<String, dynamic> json) {
    return PreIpoSellTransactionModel(
      id: Parse.toInt(json["id"]),
      status: Parse.toInt(json["status"]),
      companyId: Parse.toInt(json["company_id"]),
      portfolioId: Parse.toInt(json["portfolio_id"]),
      investorId: Parse.toInt(json["investor_id"]),
      shares: Parse.toInt(json["shares"]),
      price: Parse.toDouble(json["price"]),
      purchasePrice: Parse.toDouble(json["purchase_price"]),
      currentPrice: Parse.toDouble(json["current_price"]),
      lastTradedPrice: Parse.toDouble(json["last_traded_price"]),
      file: Parse.parseUrl(json["file"]),
      createdAt: Parse.toDateTime(json["created_at"]),
      updatedAt: Parse.toDateTime(json["updated_at"]),
      currentStatus: Parse.toStrings(json["current_status"]),
      nextStep: Parse.toStrings(json["next_step"]),
      company: Company.fromJson(json["company"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "status": status,
      "company_id": companyId,
      "portfolio_id": portfolioId,
      "investor_id": investorId,
      "shares": shares,
      "price": price,
      "purchase_price": purchasePrice,
      "current_price": currentPrice,
      "last_traded_price": lastTradedPrice,
      "file": file,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "current_status": currentStatus,
      "next_step": nextStep,
      "company": company.toJson(),
    };
  }
}
