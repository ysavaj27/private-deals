import 'package:private_deals/src/features/institution/data/models/company/lite_company_model.dart';
import 'package:private_deals/src/features/institution/support/extensions/date_extensions.dart';
import 'package:private_deals/src/features/institution/support/functions/parse.dart';

class DealModel {
  String uuid;
  String dealType;
  double availableQuantity;
  double sharePrice;
  double? basePrice;
  double minimumQty;
  double processingFeePercentage;
  String status;
  bool isHotDeal;
  DateTime expiredAt;
  bool isExpired;
  bool isMine;
  LiteCompanyModel company;

  bool get isExpiryDate => expiredAt.isNotEmpty;

  bool get isBuyDeal => dealType.toLowerCase() == 'buy';

  String get dealTypeLabel => isBuyDeal ? 'Buy' : 'Sell';

  String get quantityLabel => isBuyDeal ? 'Required qty' : 'Available qty';

  String get priceLabel => isBuyDeal ? 'Offer price' : 'Share price';

  DealModel({
    this.uuid = "",
    this.dealType = "",
    this.availableQuantity = 0.0,
    this.sharePrice = 0.0,
    this.basePrice,
    this.minimumQty = 0.0,
    this.processingFeePercentage = 0.0,
    this.status = "",
    this.isHotDeal = false,
    DateTime? expiredAt,
    this.isExpired = false,
    this.isMine = false,
    LiteCompanyModel? company,
  }) : expiredAt = expiredAt ?? DateTime(0),
       company = company ?? LiteCompanyModel();

  factory DealModel.fromJson(Map<String, dynamic> json) {
    return DealModel(
      uuid: Parse.toStrings(json['uuid']),
      dealType: Parse.toStrings(json['deal_type']),
      availableQuantity: Parse.toDouble(json['available_quantity']),
      sharePrice: Parse.toDouble(json['share_price']),
      basePrice: double.tryParse(json['base_price']?.toString() ?? ''),
      minimumQty: Parse.toDouble(json['minimum_qty']),
      processingFeePercentage: Parse.toDouble(
        json['processing_fee_percentage'],
      ),
      status: Parse.toStrings(json['status']),
      isHotDeal: Parse.toBool(json['is_hot_deal']),
      expiredAt: Parse.toDateTime(json['expired_at']),
      isExpired: Parse.toBool(json['is_expired']),
      isMine: Parse.toBool(json['is_mine']),
      company: LiteCompanyModel.fromJson(
        Map<String, dynamic>.from(json['company'] as Map? ?? {}),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "deal_type": dealType,
      "available_quantity": availableQuantity,
      "share_price": sharePrice,
      "base_price": basePrice,
      "minimum_qty": minimumQty,
      "processing_fee_percentage": processingFeePercentage,
      "status": status,
      "is_hot_deal": isHotDeal,
      "expired_at": expiredAt.toIso8601String(),
      "is_expired": isExpired,
      "is_mine": isMine,
      "company": company.toJson(),
    };
  }
}
