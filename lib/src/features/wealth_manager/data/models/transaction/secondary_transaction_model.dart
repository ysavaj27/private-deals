import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

class SecondaryTransactionModel {
  int id;
  int status;
  int startupId;
  int portfolioId;
  int buyerId;
  int sellerId;
  int sellRequestId;
  String instrument;
  double shares;
  double sharePrice;
  double investmentAmount;
  bool isPromoter;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime expiredAt;
  String currentStatus;
  String nextStep;
  double percentage;
  DocumentModel sh4Document;
  DocumentModel paymentReceipt;
  DocumentModel shareTransferReceipt;
  StartupModel startup;
  InvestorModel buyer;

  bool get translationStart => status >= 4;

  bool get waiting => status == 0;

  bool get showExpire => status == 0 || status == 1;

  bool get upload => (status == 6 && sellerId == app.iUser.id) ? true : false;

  bool get approve => status == 7 && buyerId == app.iUser.id;

  bool get rejected => status == 2 || status == 3;

  Color get color {
    var days = expiredAt.timeRemainingValue;
    if (days <= 15 || days >= 11) {
      return Color(0xff41740D);
    } else if (days <= 10 || days >= 6) {
      return Color(0xffB7650F);
    } else {
      return Color(0xff6A0E0D);
    }
  }

  String get paymentSlipMessage {
    if (status == 6) {
      return "Upload share transfer receipt";
    }
    return '';
  }

  String get name {
    if (app.iUser.id == buyerId) {
      return 'Buy Request Transaction';
    } else if (app.iUser.id == sellerId) {
      return 'Sell Request Transaction';
    }
    return '';
  }

  SecondaryTransactionModel({
    this.id = 0,
    this.status = 0,
    this.startupId = 0,
    this.portfolioId = 0,
    this.buyerId = 0,
    this.sellerId = 0,
    this.sellRequestId = 0,
    this.instrument = '',
    this.shares = 0,
    this.sharePrice = 0,
    this.investmentAmount = 0,
    this.isPromoter = false,
    required this.createdAt,
    required this.updatedAt,
    required this.expiredAt,
    this.currentStatus = '',
    this.nextStep = '',
    this.percentage = 0.0,
    required this.sh4Document,
    required this.shareTransferReceipt,
    required this.paymentReceipt,
    required this.startup,
    required this.buyer,
  });

  factory SecondaryTransactionModel.fromJson(Map<String, dynamic> json) {
    return SecondaryTransactionModel(
      id: Parse.toInt(json["id"]),
      status: Parse.toInt(json["status"]),
      startupId: Parse.toInt(json["startup_id"]),
      portfolioId: Parse.toInt(json["portfolio_id"]),
      buyerId: Parse.toInt(json["buyer_id"]),
      sellerId: Parse.toInt(json["seller_id"]),
      sellRequestId: Parse.toInt(json["sell_request_id"]),
      instrument: Parse.toStrings(json["instrument"]),
      shares: Parse.toDouble(json["shares"]),
      sharePrice: Parse.toDouble(json["share_price"]),
      investmentAmount: Parse.toDouble(json["investment_amount"]),
      isPromoter: json["is_promoter"] == 1,
      createdAt: Parse.toDateTime(json["created_at"]),
      updatedAt: Parse.toDateTime(json["updated_at"]),
      expiredAt: Parse.toDateTime(json["expired_at"]),
      currentStatus: Parse.toStrings(json["current_status"]),
      nextStep: Parse.toStrings(json["next_step"]),
      percentage: Parse.toDouble(json["percentage"]),
      sh4Document: DocumentModel.fromJson(json["sh4_document"] ?? {}),
      paymentReceipt: DocumentModel.fromJson(json["payment_receipt"] ?? {}),
      shareTransferReceipt:
          DocumentModel.fromJson(json["share_transfer_receipt"] ?? {}),
      startup: StartupModel.fromJson(json["startup"] ?? {}),
      buyer: InvestorModel.fromJson(json["buyer"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "status": status,
      "startup_id": startupId,
      "portfolio_id": portfolioId,
      "buyer_id": buyerId,
      "seller_id": sellerId,
      "sell_request_id": sellRequestId,
      "instrument": instrument,
      "shares": shares,
      "share_price": sharePrice,
      "investment_amount": investmentAmount,
      "is_promoter": isPromoter ? 1 : 0,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "expired_at": expiredAt.toIso8601String(),
      "current_status": currentStatus,
      "next_step": nextStep,
      "percentage": percentage,
      "sh4_document": sh4Document.toJson(),
      "payment_receipt": paymentReceipt.toJson(),
      "share_transfer_receipt": shareTransferReceipt.toJson(),
      "startup": startup.toJson(),
      "buyer": buyer.toJson(),
    };
  }
}
