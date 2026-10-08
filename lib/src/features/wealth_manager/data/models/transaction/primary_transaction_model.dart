import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

class PrimaryTransactionModel {
  int id;
  String type;
  int investorId;
  int startupId;
  int roundId;
  String instrument;
  double shares;
  double sharePrice;
  double investmentAmount;
  int paymentStatus;
  String paymentMode;
  int isShareTransfered;
  int status;
  DateTime createdAt;
  DateTime updatedAt;
  String currentStatus;
  String nextStep;
  double percentage;
  DocumentModel ssaDocument;
  DocumentModel mgtChallanDocument;
  DocumentModel mgtZipDocument;
  DocumentModel offerDocument;
  DocumentModel counterSlip;
  DocumentModel rtgsReceipt;
  DocumentModel shaDocument;
  InvestorModel investor;
  StartupModel startup;

  bool get isVisible {
    return ssaDocument.signedPath.isNotEmpty ||
        offerDocument.signedPath.isNotEmpty ||
        shaDocument.signedPath.isNotEmpty;
  }

  bool get isReceiptUpload =>
      status == 2 && type == PrimaryInvestmentType.Captable.name ? true : false;

  bool get isNotEmpty => id == 0 ? false : true;

  String paymentSlipMessage() {
    if (app.config.enumValues.primaryTransactionPaymentMode.cheque ==
        paymentMode) {
      return "Upload Counter Slip";
    } else if (app.config.enumValues.primaryTransactionPaymentMode.rtgs ==
        paymentMode) {
      return "Upload Payment Receipt";
    }
    return '';
  }

  PrimaryTransactionModel({
    this.id = 0,
    this.type = "",
    this.investorId = 0,
    this.startupId = 0,
    this.roundId = 0,
    this.instrument = '',
    this.shares = 0,
    this.sharePrice = 0.0,
    this.investmentAmount = 0.0,
    this.paymentStatus = 0,
    this.paymentMode = "",
    this.isShareTransfered = 0,
    this.status = 0,
    required this.createdAt,
    required this.updatedAt,
    this.currentStatus = '',
    this.nextStep = '',
    this.percentage = 0,
    required this.ssaDocument,
    required this.mgtChallanDocument,
    required this.mgtZipDocument,
    required this.offerDocument,
    required this.counterSlip,
    required this.rtgsReceipt,
    required this.shaDocument,
    required this.startup,
    required this.investor,
  });

  factory PrimaryTransactionModel.fromJson(Map<String, dynamic> json) =>
      PrimaryTransactionModel(
        id: Parse.toInt(json["id"]),
        type: Parse.toStrings(json["type"]),
        investorId: Parse.toInt(json["investor_id"]),
        startupId: Parse.toInt(json["startup_id"]),
        roundId: Parse.toInt(json["round_id"]),
        instrument: Parse.toStrings(json["instrument"]),
        shares: Parse.toDouble(json["shares"]),
        sharePrice: Parse.toDouble(json["share_price"]),
        investmentAmount: Parse.toDouble(json["investment_amount"]),
        paymentStatus: Parse.toInt(json["payment_status"]),
        paymentMode: Parse.toStrings(json["payment_mode"]),
        isShareTransfered: Parse.toInt(json["is_share_transfered"]),
        status: Parse.toInt(json["status"]),
        createdAt: Parse.toDateTime(json["created_at"]),
        updatedAt: Parse.toDateTime(json["updated_at"]),
        currentStatus: Parse.toStrings(json["current_status"]),
        nextStep: Parse.toStrings(json["next_step"]),
        percentage: Parse.toDouble(json["percentage"]),
        ssaDocument: DocumentModel.fromJson(json["ssa_document"] ?? {}),
        mgtChallanDocument: DocumentModel.fromJson(
          json["mgt_challan_document"] ?? {},
        ),
        mgtZipDocument: DocumentModel.fromJson(json["mgt_zip_document"] ?? {}),
        offerDocument: DocumentModel.fromJson(json["offer_document"] ?? {}),
        counterSlip: DocumentModel.fromJson(json["counter_slip"] ?? {}),
        rtgsReceipt: DocumentModel.fromJson(json["rtgs_receipt"] ?? {}),
        shaDocument: DocumentModel.fromJson(json["sha_document"] ?? {}),
        startup: StartupModel.fromJson(json["startup"] ?? {}),
        investor: InvestorModel.fromJson(json["investor"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "investor_id": investorId,
    "startup_id": startupId,
    "round_id": roundId,
    "instrument": instrument,
    "shares": shares,
    "share_price": sharePrice,
    "investment_amount": investmentAmount,
    "payment_status": paymentStatus,
    "payment_mode": paymentMode,
    "is_share_transfered": isShareTransfered,
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "current_status": currentStatus,
    "next_step": nextStep,
    "percentage": percentage,
    "ssa_document": ssaDocument.toJson(),
    "mgt_challan_document": mgtChallanDocument.toJson(),
    "mgt_zip_document": mgtZipDocument.toJson(),
    "offer_document": offerDocument.toJson(),
    "counter_slip": counterSlip.toJson(),
    "rtgs_receipt": rtgsReceipt.toJson(),
    "sha_document": shaDocument.toJson(),
    "startup": startup.toJson(),
    "investor": investor.toJson(),
  };
}
