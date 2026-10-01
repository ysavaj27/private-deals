import 'package:private_deals/src/features/wealth_manager/data/models/document/document_model.dart';
import 'package:private_deals/src/features/investors/data/investor_model.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

enum TransactionStatusEnum { processing, rejected, completed }

class PreIPOTransactionModel {
  int id;
  int investorId;
  int companyId;
  int status;
  int shares;
  double sharePrice;
  double investmentAmount;
  double percentage;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime settlementDate;
  DateTime transactionCancelTimer;
  String currentStatus;
  String nextStep;
  String transactionInvoiceNo;
  String timerDesc;
  Company company;
  DocumentModel dealSlip;
  PaymentModel payment;
  InvestorModel investor;
  List<TransactionStatusModel> statusList;

  //
  // Color get borderColor {
  //   switch (currentStatus) {
  //     case TransactionStatusEnum.processing:
  //       return Color.fromRGBO(183, 129, 3, 0.3);
  //     case TransactionStatusEnum.rejected:
  //       return Color.fromRGBO(223, 78, 78, 0.3);
  //     case TransactionStatusEnum.completed:
  //       return Color.fromRGBO(178, 217, 178, 1);
  //   }
  // }

  // Color get backgroundColor {
  //   switch (currentStatus) {
  //     case TransactionStatusEnum.processing:
  //       return Color.fromRGBO(255, 244, 204, 1);
  //     case TransactionStatusEnum.rejected:
  //       return Color.fromRGBO(252, 237, 237, 1);
  //     case TransactionStatusEnum.completed:
  //       return Color.fromRGBO(229, 242, 229, 1);
  //   }
  // }

  // Color get textColor {
  //   switch (currentStatus) {
  //     case TransactionStatusEnum.processing:
  //       return Color.fromRGBO(183, 129, 3, 1);
  //     case TransactionStatusEnum.rejected:
  //       return Color.fromRGBO(223, 78, 78, 1);
  //     case TransactionStatusEnum.completed:
  //       return Color.fromRGBO(0, 128, 0, 1);
  //   }
  // }

  bool get isTimerExpired {
    return DateTime.now().isAfter(transactionCancelTimer);
  }

  bool get isTimerActive => !isTimerExpired;

  PreIPOTransactionModel({
    this.id = 0,
    this.investorId = 0,
    this.companyId = 0,
    this.status = 0,
    this.shares = 0,
    this.sharePrice = 0.0,
    this.investmentAmount = 0.0,
    this.percentage = 0.0,
    required this.createdAt,
    required this.updatedAt,
    required this.currentStatus,
    this.nextStep = 'N/A',
    this.timerDesc = '',
    this.transactionInvoiceNo = '',
    required this.company,
    required this.dealSlip,
    required this.payment,
    required this.investor,
    DateTime? settlementDate,
    DateTime? transactionCancelTimer,
    this.statusList = const [],
  })  : settlementDate = settlementDate ?? DateTime(0),
        transactionCancelTimer = transactionCancelTimer ?? DateTime(0);

  factory PreIPOTransactionModel.fromJson(Map<String, dynamic> json) {
    return PreIPOTransactionModel(
      id: Parse.toInt(json["id"]),
      investorId: Parse.toInt(json["investor_id"]),
      companyId: Parse.toInt(json["company_id"]),
      status: Parse.toInt(json["status"]),
      shares: Parse.toInt(json["shares"]),
      sharePrice: Parse.toDouble(json["share_price"]),
      investmentAmount: Parse.toDouble(json["investment_amount"]),
      percentage: Parse.toDouble(json["percentage"]),
      createdAt: Parse.toDateTime(json["created_at"]),
      updatedAt: Parse.toDateTime(json["updated_at"]),
      settlementDate: Parse.toDateTime(json['settlement_date']),
      transactionCancelTimer: Parse.toDateTime(
        json['transaction_cancel_timer'],
      ),
      currentStatus: Parse.toStrings(json['current_status']),
      nextStep: Parse.toStrings(json["next_step"], 'N/A'),
      timerDesc: Parse.toStrings(json["timer_desc"]),
      transactionInvoiceNo: Parse.toStrings(json["transaction_invoice_no"]),
      company: Company.fromJson(json["company"] ?? {}),
      dealSlip: DocumentModel.fromJson(json["deal_slip"] ?? {}),
      investor: InvestorModel.fromJson(json["investor"] ?? {}),
      payment: PaymentModel.fromJson(json["payment"] ?? {}),
      statusList: json["status_list"] != null
          ? List<TransactionStatusModel>.from(
              json["status_list"].map(
                (x) => TransactionStatusModel.fromJson(x),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "investor_id": investorId,
      "company_id": companyId,
      "status": status,
      "shares": shares,
      "share_price": sharePrice,
      "investment_amount": investmentAmount,
      "percentage": percentage,
      "transaction_invoice_no": transactionInvoiceNo,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "settlement_date": settlementDate.toIso8601String(),
      "transactionCancelTimer": transactionCancelTimer.toIso8601String(),
      "current_status": currentStatus,
      "next_step": nextStep,
      "timer_desc": timerDesc,
      "company": company.toJson(),
      "deal_slip": dealSlip.toJson(),
      "payment": payment.toJson(),
      "investor": investor.toJson(),
      "status_list": List<dynamic>.from(statusList.map((x) => x.toJson())),
    };
  }
}

class TransactionStatusModel {
  String title;
  String description;
  DateTime date;
  DocumentModel document;
  ActionData action;
  bool isActive;
  bool isCompleted;

  TransactionStatusModel({
    this.title = '',
    this.description = '',
    required this.date,
    required this.document,
    required this.action,
    this.isCompleted = false,
    this.isActive = false,
  });

  factory TransactionStatusModel.fromJson(Map<String, dynamic> json) =>
      TransactionStatusModel(
        title: Parse.toStrings(json["title"]),
        description: Parse.toStrings(json["description"]),
        date: Parse.toDateTime(json["date"]),
        document: DocumentModel.fromJson(json["document"] ?? {}),
        action: ActionData.fromJson(json["action"] ?? {}),
        isActive: Parse.toBool(json["is_active"]),
        isCompleted: Parse.toBool(json["is_completed"]),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "date": date.toIso8601String(),
        "document": document.toJson(),
        "action": action.toJson(),
        "is_active": isActive,
        "is_completed": isCompleted,
      };
}

class BankDetailModel {
  String companyName;
  String bankName;
  String accountNumber;
  String ifsc;
  String branch;

  BankDetailModel({
    this.companyName = "",
    this.bankName = "",
    this.accountNumber = "",
    this.ifsc = "",
    this.branch = "",
  });

  factory BankDetailModel.fromJson(Map<String, dynamic> json) {
    return BankDetailModel(
      companyName: Parse.toStrings(json['company_name']),
      bankName: Parse.toStrings(json['bank_name']),
      accountNumber: Parse.toStrings(json['account_number']),
      ifsc: Parse.toStrings(json['ifsc']),
      branch: Parse.toStrings(json['branch']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "company_name": companyName,
      "bank_name": bankName,
      "account_number": accountNumber,
      "ifsc": ifsc,
      "branch": branch,
    };
  }
}

class ActionData {
  String type;
  String btnName;
  String url;
  BankDetailModel details;

  ActionData({
    this.type = "",
    this.btnName = "",
    this.url = "",
    required this.details,
  });

  factory ActionData.fromJson(Map<String, dynamic> json) {
    return ActionData(
      type: Parse.toStrings(json['type']),
      btnName: Parse.toStrings(json['btn_name']),
      url: Parse.toStrings(json['url']),
      details: BankDetailModel.fromJson(json["details"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "btn_name": btnName,
      "url": url,
      "details": details.toJson(),
    };
  }
}

class PaymentModel {
  DocumentModel document;

  PaymentModel({DocumentModel? document})
      : document = document ?? DocumentModel.fromJson({});

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      document: DocumentModel.fromJson(json['document'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {"document": document.toJson()};
  }
}

// class PrivateEquityTransactionModel {
//   int id;
//   int investorId;
//   int companyId;
//   int status;
//   int shares;
//   double sharePrice;
//   double investmentAmount;
//   DateTime createdAt;
//   DateTime updatedAt;
//   String currentStatus;
//   String nextStep;
//   Company company;
//   InvestorModel investor;
//   DocumentModel dealSlip;
//
//   PrivateEquityTransactionModel({
//     this.id = 0,
//     this.investorId = 0,
//     this.companyId = 0,
//     this.status = 0,
//     this.shares = 0,
//     this.sharePrice = 0.0,
//     this.investmentAmount = 0.0,
//     required this.createdAt,
//     required this.updatedAt,
//     this.currentStatus = '',
//     this.nextStep = 'N/A',
//     required this.company,
//     required this.investor,
//     required this.dealSlip,
//   });
//
//   factory PrivateEquityTransactionModel.fromJson(Map<String, dynamic> json) {
//     return PrivateEquityTransactionModel(
//       id: Parse.toInt(json["id"]),
//       investorId: Parse.toInt(json["investor_id"]),
//       companyId: Parse.toInt(json["company_id"]),
//       status: Parse.toInt(json["status"]),
//       shares: Parse.toInt(json["shares"]),
//       sharePrice: Parse.toDouble(json["share_price"]),
//       investmentAmount: Parse.toDouble(json["investment_amount"]),
//       createdAt: Parse.toDateTime(json["created_at"]),
//       updatedAt: Parse.toDateTime(json["updated_at"]),
//       currentStatus: Parse.toStrings(json["current_status"]),
//       nextStep: Parse.toStrings(json["next_step"], 'N/A'),
//       company: Company.fromJson(json["company"] ?? {}),
//       investor: InvestorModel.fromJson(json["investor"] ?? {}),
//       dealSlip: DocumentModel.fromJson(json["deal_slip"] ?? {}),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "investor_id": investorId,
//       "company_id": companyId,
//       "status": status,
//       "shares": shares,
//       "share_price": sharePrice,
//       "investment_amount": investmentAmount,
//       "created_at": createdAt.toIso8601String(),
//       "updated_at": updatedAt.toIso8601String(),
//       "current_status": currentStatus,
//       "next_step": nextStep,
//       "company": company.toJson(),
//       "investor": investor.toJson(),
//       "deal_slip": dealSlip.toJson(),
//     };
//   }
// }
//
class Company {
  int id;
  String uuid;
  String logo;
  int sectorId;
  String brandName;
  String companyName;
  String about;
  int isDeleted;
  DateTime createdAt;
  DateTime updatedAt;
  double sharePrice;

  Company({
    this.id = 0,
    this.uuid = '',
    this.logo = '',
    this.sectorId = 0,
    this.brandName = '',
    this.companyName = '',
    this.about = '',
    this.isDeleted = 0,
    required this.createdAt,
    required this.updatedAt,
    this.sharePrice = 0,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: Parse.toInt(json["id"]),
      uuid: Parse.toStrings(json["uuid"]),
      logo: Parse.parseUrl(json["logo"]),
      sectorId: Parse.toInt(json["sector_id"]),
      brandName: Parse.toStrings(json["brand_name"]),
      companyName: Parse.toStrings(json["company_name"]),
      about: Parse.toStrings(json["about"]),
      isDeleted: Parse.toInt(json["is_deleted"]),
      createdAt: Parse.toDateTime(json["created_at"]),
      updatedAt: Parse.toDateTime(json["updated_at"]),
      sharePrice: Parse.toDouble(json["share_price"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "uuid": uuid,
      "logo": logo,
      "sector_id": sectorId,
      "brand_name": brandName,
      "company_name": companyName,
      "about": about,
      "is_deleted": isDeleted,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "share_price": sharePrice,
    };
  }
}
