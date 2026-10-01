import 'package:private_deals/src/features/institution/support/functions/parse.dart';

class PreIPOTransactionModel {
  final int id;
  final String transactionInvoiceNo;
  final int status;
  final int investorId;
  final int companyId;
  final int investorCouponId;
  final String couponCodeSnapshot;
  final double couponDiscountAmount;
  final int portfolioId;
  final int sellerId;
  final int shares;
  final double sharePrice;
  final double distributerPrice;
  final double shuruPrice;
  final double investmentAmount;
  final double processingFee;
  final double payableAmount;
  final DateTime? settlementDate;
  final DateTime? transactionCancelTimer;
  final String timerDesc;
  final bool isDistributer;
  final String instrument;
  final String paymentMode;
  final bool isValid;
  final String otherName;
  final String notes;
  final bool isCancelledByInvestor;
  final String cancellationReason;
  final int createdBy;
  final int updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double percentage;
  final String currentStatus;
  final String nextStep;
  final bool isProcessing;
  final List<TransactionStatusModel> statusList;
  final TransactionCompanyModel company;
  final TransactionInvestorModel investor;
  final TransactionDocumentModel? dealSlip;
  final TransactionDocumentModel? approvalFile;
  final TransactionDocumentModel? rejectionFile;
  final Map<String, dynamic>? seller;
  final Map<String, dynamic>? payment;

  PreIPOTransactionModel({
    this.id = 0,
    this.transactionInvoiceNo = '',
    this.status = 0,
    this.investorId = 0,
    this.companyId = 0,
    this.investorCouponId = 0,
    this.couponCodeSnapshot = '',
    this.couponDiscountAmount = 0,
    this.portfolioId = 0,
    this.sellerId = 0,
    this.shares = 0,
    this.sharePrice = 0,
    this.distributerPrice = 0,
    this.shuruPrice = 0,
    this.investmentAmount = 0,
    this.processingFee = 0,
    this.payableAmount = 0,
    this.settlementDate,
    this.transactionCancelTimer,
    this.timerDesc = '',
    this.isDistributer = false,
    this.instrument = '',
    this.paymentMode = '',
    this.isValid = false,
    this.otherName = '',
    this.notes = '',
    this.isCancelledByInvestor = false,
    this.cancellationReason = '',
    this.createdBy = 0,
    this.updatedBy = 0,
    this.createdAt,
    this.updatedAt,
    this.percentage = 0,
    this.currentStatus = '',
    this.nextStep = '',
    this.isProcessing = false,
    this.statusList = const [],
    required this.company,
    required this.investor,
    this.dealSlip,
    this.approvalFile,
    this.rejectionFile,
    this.seller,
    this.payment,
  });

  factory PreIPOTransactionModel.fromJson(Map<String, dynamic> json) =>
      PreIPOTransactionModel(
        id: Parse.toInt(json['id']),
        transactionInvoiceNo: Parse.toStrings(json['transaction_invoice_no']),
        status: Parse.toInt(json['status']),
        investorId: Parse.toInt(json['investor_id']),
        companyId: Parse.toInt(json['company_id']),
        investorCouponId: Parse.toInt(json['investor_coupon_id']),
        couponCodeSnapshot: Parse.toStrings(json['coupon_code_snapshot']),
        couponDiscountAmount: Parse.toDouble(json['coupon_discount_amount']),
        portfolioId: Parse.toInt(json['portfolio_id']),
        sellerId: Parse.toInt(json['seller_id']),
        shares: Parse.toInt(json['shares']),
        sharePrice: Parse.toDouble(json['share_price']),
        distributerPrice: Parse.toDouble(json['distributer_price']),
        shuruPrice: Parse.toDouble(json['shuru_price']),
        investmentAmount: Parse.toDouble(json['investment_amount']),
        processingFee: Parse.toDouble(json['processing_fee']),
        payableAmount: Parse.toDouble(json['payable_amount']),
        settlementDate: DateTime.tryParse(
          json['settlement_date']?.toString() ?? '',
        ),
        transactionCancelTimer: DateTime.tryParse(
          json['transaction_cancel_timer']?.toString() ?? '',
        ),
        timerDesc: Parse.toStrings(json['timer_desc']),
        isDistributer: Parse.toBool(json['is_distributer']),
        instrument: Parse.toStrings(json['instrument']),
        paymentMode: Parse.toStrings(json['payment_mode']),
        isValid: Parse.toBool(json['is_valid']),
        otherName: Parse.toStrings(json['other_name']),
        notes: Parse.toStrings(json['notes']),
        isCancelledByInvestor: Parse.toBool(json['is_cancelled_by_investor']),
        cancellationReason: Parse.toStrings(json['cancellation_reason']),
        createdBy: Parse.toInt(json['created_by']),
        updatedBy: Parse.toInt(json['updated_by']),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
        updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
        percentage: Parse.toDouble(json['percentage']),
        currentStatus: Parse.toStrings(json['current_status']),
        nextStep: Parse.toStrings(json['next_step']),
        isProcessing: Parse.toBool(json['is_processing']),
        statusList: (json['status_list'] as List? ?? [])
            .map(
              (e) =>
                  TransactionStatusModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
        company: TransactionCompanyModel.fromJson(
          Map<String, dynamic>.from(json['company'] ?? {}),
        ),
        investor: TransactionInvestorModel.fromJson(
          Map<String, dynamic>.from(json['investor'] ?? {}),
        ),
        dealSlip: json['deal_slip'] is Map
            ? TransactionDocumentModel.fromJson(
                Map<String, dynamic>.from(json['deal_slip']),
              )
            : null,
        approvalFile: json['approval_file'] is Map
            ? TransactionDocumentModel.fromJson(
                Map<String, dynamic>.from(json['approval_file']),
              )
            : null,
        rejectionFile: json['rejection_file'] is Map
            ? TransactionDocumentModel.fromJson(
                Map<String, dynamic>.from(json['rejection_file']),
              )
            : null,
        seller: json['seller'] is Map
            ? Map<String, dynamic>.from(json['seller'])
            : null,
        payment: json['payment'] is Map
            ? Map<String, dynamic>.from(json['payment'])
            : null,
      );
}

class TransactionCompanyModel {
  final int id;
  final String uuid;
  final String brandName;
  final String logo;
  TransactionCompanyModel({
    this.id = 0,
    this.uuid = '',
    this.brandName = '',
    this.logo = '',
  });
  factory TransactionCompanyModel.fromJson(Map<String, dynamic> json) =>
      TransactionCompanyModel(
        id: Parse.toInt(json['id']),
        uuid: Parse.toStrings(json['uuid']),
        brandName: Parse.toStrings(json['brand_name']),
        logo: Parse.toStrings(json['logo']),
      );
}

class TransactionInvestorModel {
  final int id;
  final String name;
  TransactionInvestorModel({this.id = 0, this.name = ''});
  factory TransactionInvestorModel.fromJson(Map<String, dynamic> json) =>
      TransactionInvestorModel(
        id: Parse.toInt(json['id']),
        name: Parse.toStrings(json['name']),
      );
}

class TransactionStatusModel {
  final String title;
  final String description;
  final DateTime? date;
  final bool isActive;
  final Map<String, dynamic>? action;
  final dynamic document;
  TransactionStatusModel({
    this.title = '',
    this.description = '',
    this.date,
    this.isActive = false,
    this.action,
    this.document,
  });
  factory TransactionStatusModel.fromJson(Map<String, dynamic> json) =>
      TransactionStatusModel(
        title: Parse.toStrings(json['title']),
        description: Parse.toStrings(json['description']),
        date: DateTime.tryParse(json['date']?.toString() ?? ''),
        isActive: Parse.toBool(json['is_active']),
        action: json['action'] is Map
            ? Map<String, dynamic>.from(json['action'])
            : null,
        document: json['document'],
      );
}

class TransactionDocumentModel {
  final int id;
  final int status;
  final String apiId;
  final String path;
  final String signedPath;
  final String type;
  final String displayName;
  final Map<String, dynamic>? meta;
  TransactionDocumentModel({
    this.id = 0,
    this.status = 0,
    this.apiId = '',
    this.path = '',
    this.signedPath = '',
    this.type = '',
    this.displayName = '',
    this.meta,
  });
  factory TransactionDocumentModel.fromJson(Map<String, dynamic> json) =>
      TransactionDocumentModel(
        id: Parse.toInt(json['id']),
        status: Parse.toInt(json['status']),
        apiId: Parse.toStrings(json['api_id']),
        path: Parse.toStrings(json['path']),
        signedPath: Parse.toStrings(json['signed_path']),
        type: Parse.toStrings(json['type']),
        displayName: Parse.toStrings(json['display_name']),
        meta: json['meta'] is Map
            ? Map<String, dynamic>.from(json['meta'])
            : null,
      );
}
