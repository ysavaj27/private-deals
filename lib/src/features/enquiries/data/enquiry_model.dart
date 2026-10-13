import 'package:private_deals/src/core/session/partner_user.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

/// A counter-offer from an Institution on an open partner enquiry.
class EnquiryQuote {
  EnquiryQuote.fromJson(Map<String, dynamic> json)
    : uuid = Parse.toStrings(json['uuid']),
      quantity = Parse.toInt(json['quantity']),
      basePrice = Parse.toDouble(json['base_price']),
      sharePrice = Parse.toDouble(json['share_price']),
      settlementDays = _readSettlementDays(json['settlement_days']),
      settlementLabel = _readSettlementLabel(json['settlement_label']),
      status = Parse.toStrings(json['status']),
      institutionId = Parse.toInt((json['institution'] as Map?)?['id']),
      institutionName = Parse.toStrings((json['institution'] as Map?)?['name']);

  final String uuid, status, institutionName;
  final int quantity, institutionId;
  final int? settlementDays;
  final String? settlementLabel;
  final double basePrice, sharePrice;

  bool get isPending {
    final normalized = status.trim().toLowerCase();
    return normalized.isEmpty ||
        normalized == 'pending' ||
        normalized == 'open';
  }

  String get statusLabel => switch (status.trim().toLowerCase()) {
    'pending' || 'open' || '' => 'Pending',
    'withdrawn' => 'Withdrawn',
    'accepted' => 'Accepted',
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
}

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
      partnerId = Parse.toInt(
        (json['partner'] as Map?)?['id'] ?? json['partner_id'],
      ),
      partnerParentId = Parse.toInt((json['partner'] as Map?)?['parent_id']),
      counterpartyFlag = json['can_accept_counterparty'] == null
          ? null
          : Parse.toBool(json['can_accept_counterparty']),
      institutionName = Parse.toStrings(
        (json['accepted_by_institution'] as Map?)?['name'],
      ),
      hasInstitution = json['accepted_by_institution'] is Map,
      createdAt = Parse.toStrings(json['created_at']),
      quotes = _readQuotes(json['quotes']),
      myQuote = _readMyQuote(json['my_quote']);

  final String uuid, dealType, status, notes, rejectionReason;
  final String companyName,
      companyLogo,
      partnerName,
      institutionName,
      createdAt;
  final int quantity;
  final int partnerId, partnerParentId;
  final int? settlementDays;
  final String? settlementLabel;
  final double basePrice, sharePrice;
  final bool hasInstitution;
  final List<EnquiryQuote> quotes;
  final EnquiryQuote? myQuote;

  /// Server decision on accept-counterparty; overrides the local checks.
  final bool? counterpartyFlag;

  bool get isSell => dealType == 'sell';
  bool get isBuy => dealType == 'buy';

  bool get canSellerRespond =>
      uuid.isNotEmpty && status == 'open' && !hasInstitution;

  bool get hasPendingQuote => myQuote?.isPending == true;

  bool get canAcceptOriginal => canSellerRespond && !hasPendingQuote;

  bool get canSendQuote => canSellerRespond && !hasPendingQuote;

  bool get canReplaceQuote => canSellerRespond && hasPendingQuote;

  bool get canWithdrawQuote => canSellerRespond && hasPendingQuote;

  List<EnquiryQuote> get actionableQuotes => status != 'open'
      ? const []
      : quotes.where((quote) => quote.isPending && quote.uuid.isNotEmpty).toList();

  /// Lists without a partner id only ever contained the caller's own enquiries.
  bool isMine(PartnerUser me) => partnerId <= 0 || partnerId == me.id;

  /// A Wealth Manager and their own Relation Manager count as one side.
  bool isSameDesk(PartnerUser me) =>
      (partnerParentId > 0 && partnerParentId == me.id) ||
      (me.parentId > 0 && partnerId == me.parentId);

  bool canWithdraw(PartnerUser me) => canSellerRespond && isMine(me);
  bool canPartnerRespond(PartnerUser me) =>
      uuid.isNotEmpty && status == 'locked' && isMine(me);

  bool canAcceptCounterparty(PartnerUser me) {
    if (!canSellerRespond || isMine(me)) return false;
    return counterpartyFlag ?? !isSameDesk(me);
  }

  String get typeLabel => switch (dealType) {
    'buy' => 'Buy enquiry',
    'sell' => 'Sell enquiry',
    _ => 'Enquiry',
  };
  String statusLabel(bool institution, {bool mine = true}) => switch (status) {
    'open' => 'Open',
    'locked' when !institution && !mine => 'Locked',
    'locked' =>
      institution ? 'Waiting for wealth manager' : 'Awaiting your decision',
    'withdrawn' => 'Withdrawn',
    'rejected' => 'Rejected by wealth manager',
    'converted' => 'Converted to transaction',
    _ => status.isEmpty ? 'Unknown' : status,
  };

  static List<EnquiryQuote> _readQuotes(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => EnquiryQuote.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static EnquiryQuote? _readMyQuote(dynamic value) {
    if (value is! Map) return null;
    final quote = EnquiryQuote.fromJson(Map<String, dynamic>.from(value));
    return quote.uuid.isEmpty ? null : quote;
  }

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
