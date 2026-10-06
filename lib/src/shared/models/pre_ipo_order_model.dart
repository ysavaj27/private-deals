import 'package:private_deals/src/shared/functions/parse.dart';

/// New Pre-IPO order driven by [orderStep] / [current] / [next] / [action].
/// Used by buying partner and Institution transaction screens.
class PreIpoOrderModel {
  final int id;
  final String orderStep;
  final String tradeSide;
  final String orderSource;
  final String current;
  final String? next;
  final List<String>? action;
  final String? signLink;
  final int shares;
  final double basePrice;
  final double distributerPrice;
  final double sharePrice;
  final double payableAmount;
  final String? cancellationReason;
  final bool? mandateSent;
  final PreIpoOrderInvestor investor;
  final PreIpoOrderCompany company;
  final PreIpoPaymentDetails? paymentDetails;
  final PreIpoOrderReceipt? paymentReceipt;
  final PreIpoOrderReceipt? shareTransferReceipt;
  final List<PreIpoOrderDocument> documents;

  /// Optional seller-style detail fields. These do not drive order actions.
  final String? transactionInvoiceNo;
  final DateTime? createdAt;
  final int? settlementDays;
  final String? settlementLabel;
  final DateTime? settlementDate;
  final String? paymentMode;
  final String? instrument;
  final double? investmentAmount;
  final double? processingFee;
  final double? couponDiscountAmount;
  final double? percentage;
  final String? currentStatus;
  final String? nextStep;
  final List<PreIpoOrderStatus> statusList;

  const PreIpoOrderModel({
    this.id = 0,
    this.orderStep = '',
    this.tradeSide = '',
    this.orderSource = '',
    this.current = '',
    this.next,
    this.action,
    this.signLink,
    this.shares = 0,
    this.basePrice = 0,
    this.distributerPrice = 0,
    this.sharePrice = 0,
    this.payableAmount = 0,
    this.cancellationReason,
    this.mandateSent,
    this.investor = const PreIpoOrderInvestor(),
    this.company = const PreIpoOrderCompany(),
    this.paymentDetails,
    this.paymentReceipt,
    this.shareTransferReceipt,
    this.documents = const [],
    this.transactionInvoiceNo,
    this.createdAt,
    this.settlementDays,
    this.settlementLabel,
    this.settlementDate,
    this.paymentMode,
    this.instrument,
    this.investmentAmount,
    this.processingFee,
    this.couponDiscountAmount,
    this.percentage,
    this.currentStatus,
    this.nextStep,
    this.statusList = const [],
  });

  bool get isNewFlow => orderStep.isNotEmpty;

  bool get hasAction => action != null && action!.isNotEmpty;

  bool get hasDocuments => documents.isNotEmpty;

  bool get isSelfInvestor => investor.isSelf;

  bool get isCancelled => orderStep == 'cancelled';

  bool get isCompleted => orderStep == 'completed';

  String get nextLabel {
    if (next == null || next == 'N/A') return 'N/A';
    return next!;
  }

  bool hasActionNamed(String name) => action?.contains(name) ?? false;

  factory PreIpoOrderModel.fromJson(Map<String, dynamic> json) {
    List<String>? actions;
    final rawAction = json['action'];
    if (rawAction is List) {
      actions = rawAction.map((e) => e.toString()).toList();
    }

    return PreIpoOrderModel(
      id: Parse.toInt(json['id']),
      orderStep: Parse.toStrings(json['order_step']),
      tradeSide: Parse.toStrings(json['trade_side']),
      orderSource: Parse.toStrings(json['order_source']),
      current:
          _nullableString(json['current_step']) ??
          _nullableString(json['current']) ??
          '',
      next: _nullableString(json['next_step']) ?? _nullableString(json['next']),
      action: actions,
      signLink: _nullableString(json['sign_link']),
      shares: Parse.toInt(json['shares']),
      basePrice: Parse.toDouble(json['base_price']),
      distributerPrice: Parse.toDouble(json['distributer_price']),
      sharePrice: Parse.toDouble(json['share_price']),
      payableAmount: Parse.toDouble(
        json['payable_amount'] ?? json['investment_amount'],
      ),
      cancellationReason: _nullableString(json['cancellation_reason']),
      mandateSent: json.containsKey('mandate_sent')
          ? Parse.toBool(json['mandate_sent'])
          : null,
      investor: PreIpoOrderInvestor.fromJson(
        Map<String, dynamic>.from(json['investor'] ?? {}),
      ),
      company: PreIpoOrderCompany.fromJson(
        Map<String, dynamic>.from(json['company'] ?? {}),
      ),
      paymentDetails: json['payment_details'] is Map
          ? PreIpoPaymentDetails.fromJson(
              Map<String, dynamic>.from(json['payment_details']),
            )
          : null,
      paymentReceipt: json['payment_receipt'] is Map
          ? PreIpoOrderReceipt.fromJson(
              Map<String, dynamic>.from(json['payment_receipt']),
            )
          : null,
      shareTransferReceipt: json['share_transfer_receipt'] is Map
          ? PreIpoOrderReceipt.fromJson(
              Map<String, dynamic>.from(json['share_transfer_receipt']),
            )
          : null,
      documents: (json['documents'] as List? ?? [])
          .whereType<Map>()
          .map(
            (e) => PreIpoOrderDocument.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
      transactionInvoiceNo: _nullableString(json['transaction_invoice_no']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      settlementDays: _nullableSettlementDays(json['settlement_days']),
      settlementLabel: _nullableString(json['settlement_label']),
      settlementDate: DateTime.tryParse(
        json['settlement_date']?.toString() ?? '',
      ),
      paymentMode: _nullableString(json['payment_mode']),
      instrument: _nullableString(json['instrument']),
      investmentAmount: _nullableDouble(json['investment_amount']),
      processingFee: _nullableDouble(json['processing_fee']),
      couponDiscountAmount: _nullableDouble(json['coupon_discount_amount']),
      percentage: _nullableDouble(json['percentage']),
      currentStatus: _nullableString(json['current_status']),
      nextStep: _nullableString(json['next_step']),
      statusList: json['status_list'] is List
          ? (json['status_list'] as List)
                .whereType<Map>()
                .map(
                  (e) =>
                      PreIpoOrderStatus.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
    );
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final text = Parse.toStrings(value).trim();
    return text.isEmpty ? null : text;
  }

  static int? _nullableSettlementDays(dynamic value) {
    if (value == null) return null;
    final days = Parse.toInt(value);
    return days < 1 ? null : days;
  }

  static double? _nullableDouble(dynamic value) {
    final number = double.tryParse(value?.toString() ?? '');
    return number != null && number.isFinite ? number : null;
  }
}

/// Read-only timeline entry from `status_list`, in the server's display order.
/// Actions continue to come exclusively from the order's top-level `action`.
class PreIpoOrderStatus {
  final String title;
  final String description;
  final DateTime? date;
  final bool isActive;
  final bool? isCompleted;
  final PreIpoOrderDocument? document;

  bool get completed => isCompleted ?? (date != null);

  const PreIpoOrderStatus({
    this.title = '',
    this.description = '',
    this.date,
    this.isActive = false,
    this.isCompleted,
    this.document,
  });

  factory PreIpoOrderStatus.fromJson(Map<String, dynamic> json) =>
      PreIpoOrderStatus(
        title: Parse.toStrings(json['title']),
        description: Parse.toStrings(json['description']),
        date: DateTime.tryParse(json['date']?.toString() ?? ''),
        isActive: Parse.toBool(json['is_active']),
        isCompleted: json['is_completed'] == null
            ? null
            : Parse.toBool(json['is_completed']),
        document: json['document'] is Map
            ? PreIpoOrderDocument.fromJson(
                Map<String, dynamic>.from(json['document']),
              )
            : null,
      );
}

class PreIpoOrderInvestor {
  final int id;
  final String name;
  final bool isSelf;
  final int partnerId;

  const PreIpoOrderInvestor({
    this.id = 0,
    this.name = '',
    this.isSelf = false,
    this.partnerId = 0,
  });

  /// Name shown in UI; prefixes `[Self]` when this is the logged-in investor.
  String get displayName => isSelf ? '[Self] $name' : name;

  factory PreIpoOrderInvestor.fromJson(Map<String, dynamic> json) {
    return PreIpoOrderInvestor(
      id: Parse.toInt(json['id']),
      name: Parse.toStrings(json['name']),
      isSelf: Parse.toBool(json['is_self']),
      partnerId: Parse.toInt(json['partner_id']),
    );
  }
}

class PreIpoOrderCompany {
  final int id;
  final String uuid;
  final String brandName;
  final String logo;

  const PreIpoOrderCompany({
    this.id = 0,
    this.uuid = '',
    this.brandName = '',
    this.logo = '',
  });

  factory PreIpoOrderCompany.fromJson(Map<String, dynamic> json) {
    return PreIpoOrderCompany(
      id: Parse.toInt(json['id']),
      uuid: Parse.toStrings(json['uuid']),
      brandName: Parse.toStrings(json['brand_name']),
      logo: _resolveUrl(json['logo']),
    );
  }
}

class PreIpoPaymentDetails {
  final double amount;
  final PreIpoBankAccount? account;

  const PreIpoPaymentDetails({this.amount = 0, this.account});

  factory PreIpoPaymentDetails.fromJson(Map<String, dynamic> json) {
    return PreIpoPaymentDetails(
      amount: Parse.toDouble(json['amount']),
      account: json['account'] is Map
          ? PreIpoBankAccount.fromJson(
              Map<String, dynamic>.from(json['account']),
            )
          : null,
    );
  }
}

class PreIpoBankAccount {
  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String ifscCode;

  const PreIpoBankAccount({
    this.accountHolderName = '',
    this.bankName = '',
    this.accountNumber = '',
    this.ifscCode = '',
  });

  factory PreIpoBankAccount.fromJson(Map<String, dynamic> json) {
    return PreIpoBankAccount(
      accountHolderName: Parse.toStrings(json['account_holder_name']),
      bankName: Parse.toStrings(json['bank_name']),
      accountNumber: Parse.toStrings(json['account_number']),
      ifscCode: Parse.toStrings(json['ifsc_code']),
    );
  }
}

class PreIpoOrderReceipt {
  final int id;
  final String name;
  final String path;
  final String url;

  const PreIpoOrderReceipt({
    this.id = 0,
    this.name = '',
    this.path = '',
    this.url = '',
  });

  factory PreIpoOrderReceipt.fromJson(Map<String, dynamic> json) {
    return PreIpoOrderReceipt(
      id: Parse.toInt(json['id']),
      name: Parse.toStrings(json['name']),
      path: Parse.toStrings(json['path']),
      url: _resolveUrl(json['url']),
    );
  }
}

/// Unified order file from the `documents` array (oldest first).
class PreIpoOrderDocument {
  final int id;
  final String type;
  final String? name;
  final String path;
  final String url;

  const PreIpoOrderDocument({
    this.id = 0,
    this.type = '',
    this.name,
    this.path = '',
    this.url = '',
  });

  String get displayName {
    final label = name?.trim();
    if (label != null && label.isNotEmpty) return label;
    if (type.isNotEmpty) return type;
    return 'Document';
  }

  factory PreIpoOrderDocument.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'];
    return PreIpoOrderDocument(
      id: Parse.toInt(json['id']),
      type: Parse.toStrings(json['type']),
      name: rawName == null ? null : Parse.toStrings(rawName),
      path: Parse.toStrings(json['path']),
      url: _resolveUrl(json['url']),
    );
  }
}

/// Known `documents[].type` values from the Pre-IPO order API.
abstract final class PreIpoDocumentType {
  static const buyMandate = 'BuyMandate';
  static const dealSlip = 'Pre-IPO Deal Slip';
  static const paymentReceipt = 'Payment Receipt';
  static const shareTransferReceipt = 'Pre-IPO Share Transfer Receipt';
}

String _resolveUrl(dynamic value) {
  final text = Parse.toStrings(value);
  if (text.isEmpty) return '';
  if (text.startsWith('http://') || text.startsWith('https://')) return text;
  return Parse.parseUrl(text);
}

/// Action keys returned in [PreIpoOrderModel.action].
abstract final class PreIpoOrderAction {
  static const cancel = 'cancel';
  static const showMandateSignLink = 'show_mandate_sign_link';
  static const showDealSlipSignLink = 'show_deal_slip_sign_link';
  static const viewPaymentDetails = 'view_payment_details';
  static const uploadPaymentReceipt = 'upload_payment_receipt';
  static const approve = 'approve';
  static const reject = 'reject';
  static const viewPaymentReceipt = 'view_payment_receipt';
  static const confirmPayment = 'confirm_payment';
  static const uploadShareTransferReceipt = 'upload_share_transfer_receipt';
  static const viewShareTransferReceipt = 'view_share_transfer_receipt';
  static const confirmShareTransfer = 'confirm_share_transfer';

  static String label(String action) {
    switch (action) {
      case cancel:
        return 'Cancel';
      case showMandateSignLink:
        return 'Sign mandate';
      case showDealSlipSignLink:
        return 'Sign deal slip';
      case viewPaymentDetails:
        return 'Payment details';
      case uploadPaymentReceipt:
        return 'Upload receipt';
      case approve:
        return 'Approve';
      case reject:
        return 'Reject';
      case viewPaymentReceipt:
        return 'View receipt';
      case confirmPayment:
        return 'Confirm payment';
      case uploadShareTransferReceipt:
        return 'Upload transfer';
      case viewShareTransferReceipt:
        return 'View transfer';
      case confirmShareTransfer:
        return 'Confirm transfer';
      default:
        return action.replaceAll('_', ' ');
    }
  }
}
