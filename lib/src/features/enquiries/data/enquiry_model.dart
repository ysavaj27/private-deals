import 'package:private_deals/src/shared/functions/parse.dart';

/// Inquiry lifecycle is independent of the subsequent order's order_step.
class EnquiryModel {
  EnquiryModel.fromJson(Map<String, dynamic> json)
    : uuid = Parse.toStrings(json['uuid']),
      dealType = Parse.toStrings(json['deal_type']),
      status = Parse.toStrings(json['enquiry_status']),
      quantity = Parse.toInt(json['quantity']),
      basePrice = Parse.toDouble(json['base_price']),
      sharePrice = Parse.toDouble(json['share_price']),
      settlementDays = _readSettlementDays(json['settlement_days']),
      settlementLabel = _readSettlementLabel(json['settlement_label']),
      notes = Parse.toStrings(json['notes']),
      rejectionReason = Parse.toStrings(json['partner_response_reason']),
      companyName = Parse.toStrings((json['company'] as Map?)?['brand_name']),
      companyLogo = _readLogo((json['company'] as Map?)?['logo']),
      partnerName = Parse.toStrings((json['partner'] as Map?)?['name']),
      institutionName = Parse.toStrings(
        (json['accepted_by_institution'] as Map?)?['name'],
      ),
      hasInstitution = json['accepted_by_institution'] is Map,
      createdAt = Parse.toStrings(json['created_at']);

  final String uuid, dealType, status, notes, rejectionReason;
  final String companyName, companyLogo, partnerName, institutionName, createdAt;
  final int quantity;
  final int? settlementDays;
  final String? settlementLabel;
  final double basePrice, sharePrice;
  final bool hasInstitution;

  bool get isSell => dealType == 'sell';
  bool get isBuy => dealType == 'buy';

  bool get canSellerRespond =>
      uuid.isNotEmpty && status == 'open' && !hasInstitution;
  bool get canWithdraw => canSellerRespond;
  bool get canPartnerRespond => uuid.isNotEmpty && status == 'locked';
  String get typeLabel => switch (dealType) {
    'buy' => 'Buy enquiry',
    'sell' => 'Sell enquiry',
    _ => 'Enquiry',
  };
  String statusLabel(bool institution) => switch (status) {
    'open' => 'Open',
    'locked' =>
      institution ? 'Waiting for wealth manager' : 'Awaiting your decision',
    'withdrawn' => 'Withdrawn',
    'rejected' => 'Rejected by wealth manager',
    'converted' => 'Converted to transaction',
    _ => status.isEmpty ? 'Unknown' : status,
  };

  static int? _readSettlementDays(dynamic value) {
    if (value == null) return null;
    final days = Parse.toInt(value);
    return days < 1 ? null : days;
  }

  static String? _readSettlementLabel(dynamic value) {
    final label = Parse.toStrings(value);
    return label.isEmpty ? null : label;
  }

  static String _readLogo(dynamic value) {
    final text = Parse.toStrings(value);
    if (text.isEmpty) return '';
    if (text.startsWith('http://') || text.startsWith('https://')) return text;
    return Parse.parseUrl(text);
  }
}
