import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/shared/functions/parse.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/startup/startup_model.dart';

class SecondaryOpportunitiesModel {
  int id;
  String status;
  int buyerId;
  int sellerId;
  int portfolioId;
  int sellRequestId;
  int startupId;
  double shares;
  double price;
  DateTime expiredAt;
  bool isPromoter;
  DateTime createdAt;
  DateTime updatedAt;
  StartupModel startup;

  bool get isRejected => status == app.config.enumValues.status.rejected;

  bool get isPending => status == app.config.enumValues.status.pending;

  String get message {
    if (isPending) {
      return "You have 15 days to approve or decline this share transfer request.";
    } else if (isRejected) {
      return "Request rejected.";
    } else {
      return "Your request has been approved.";
    }
  }

  SecondaryOpportunitiesModel({
    this.id = 0,
    this.status = '',
    this.buyerId = 0,
    this.sellerId = 0,
    this.portfolioId = 0,
    this.sellRequestId = 0,
    this.startupId = 0,
    this.shares = 0,
    this.price = 0.0,
    required this.expiredAt,
    this.isPromoter = false,
    required this.createdAt,
    required this.updatedAt,
    required this.startup,
  });

  factory SecondaryOpportunitiesModel.fromJson(Map<String, dynamic> json) {
    return SecondaryOpportunitiesModel(
      id: Parse.toInt(json["id"]),
      status: Parse.toStrings(json["status"]),
      buyerId: Parse.toInt(json["buyer_id"]),
      sellerId: Parse.toInt(json["seller_id"]),
      portfolioId: Parse.toInt(json["portfolio_id"]),
      sellRequestId: Parse.toInt(json["sell_request_id"]),
      startupId: Parse.toInt(json["startup_id"]),
      shares: Parse.toDouble(json["shares"]),
      price: Parse.toDouble(json["price"]),
      expiredAt: Parse.toDateTime(json["expired_at"]),
      isPromoter: json["is_promoter"] == 1,
      createdAt: Parse.toDateTime(json["created_at"]),
      updatedAt: Parse.toDateTime(json["updated_at"]),
      startup: StartupModel.fromJson(json["startup"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "status": status,
      "buyer_id": buyerId,
      "seller_id": sellerId,
      "portfolio_id": portfolioId,
      "sell_request_id": sellRequestId,
      "startup_id": startupId,
      "shares": shares,
      "price": price,
      "expired_at": expiredAt.toIso8601String(),
      "is_promoter": isPromoter ? 1 : 0,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "startup": startup.toJson(),
    };
  }
}
