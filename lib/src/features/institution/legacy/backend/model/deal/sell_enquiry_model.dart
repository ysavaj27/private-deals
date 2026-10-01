import 'package:private_deals/src/features/institution/data/models/company/lite_company_model.dart';
import 'package:private_deals/src/features/institution/support/functions/parse.dart';

class SellEnquiryModel {
  final String uuid;
  final String enquiryType;
  final String status;
  final double quantity;
  final double offerPrice;
  final DateTime? offerValidTill;
  final String notes;
  final String createdAt;
  final LiteCompanyModel company;
  final String partnerName;

  SellEnquiryModel.fromJson(Map<String, dynamic> json)
    : uuid = Parse.toStrings(json['uuid']),
      enquiryType = Parse.toStrings(json['enquiry_type']),
      status = Parse.toStrings(json['status']),
      quantity = Parse.toDouble(json['quantity']),
      offerPrice = Parse.toDouble(json['offer_price']),
      offerValidTill = DateTime.tryParse('${json['offer_valid_till'] ?? ''}'),
      notes = Parse.toStrings(json['notes']),
      createdAt = Parse.toStrings(json['created_at']),
      company = LiteCompanyModel.fromJson(json['company'] ?? {}),
      partnerName = Parse.toStrings(json['partner']?['name']);

  // Date-only offers remain valid through the end of the stated day in IST.
  bool isExpiredAt(DateTime now) {
    final date = offerValidTill;
    if (date == null) return false;
    final end = DateTime.utc(
      date.year,
      date.month,
      date.day + 1,
    ).subtract(const Duration(hours: 5, minutes: 30));
    return !now.toUtc().isBefore(end);
  }

  bool canShowActions(DateTime now) =>
      status.toLowerCase() == 'pending' &&
      offerValidTill != null &&
      !isExpiredAt(now);
}
