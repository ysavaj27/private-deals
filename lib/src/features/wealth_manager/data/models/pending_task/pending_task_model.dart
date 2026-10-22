import 'package:private_deals/src/features/investors/data/investor_model.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

class PendingTaskModel {
  PendingKycSection pendingKyc;
  PendingDocumentsSection pendingDocuments;
  PendingFundTransferSection pendingFundTransfer;

  PendingTaskModel({
    PendingKycSection? pendingKyc,
    PendingDocumentsSection? pendingDocuments,
    PendingFundTransferSection? pendingFundTransfer,
  })  : pendingKyc = pendingKyc ?? PendingKycSection(),
        pendingDocuments = pendingDocuments ?? PendingDocumentsSection(),
        pendingFundTransfer =
            pendingFundTransfer ?? PendingFundTransferSection();

  factory PendingTaskModel.fromJson(Map<String, dynamic> json) =>
      PendingTaskModel(
        pendingKyc: PendingKycSection.fromJson(_asMap(json['pending_kyc'])),
        pendingDocuments: PendingDocumentsSection.fromJson(
          _asMap(json['pending_documents']),
        ),
        pendingFundTransfer: PendingFundTransferSection.fromJson(
          _asMap(json['pending_fund_transfer']),
        ),
      );

  Map<String, dynamic> toJson() => {
        'pending_kyc': pendingKyc.toJson(),
        'pending_documents': pendingDocuments.toJson(),
        'pending_fund_transfer': pendingFundTransfer.toJson(),
      };
}

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

class PendingKycSection {
  int count;
  List<InvestorModel> investors;

  PendingKycSection({
    this.count = 0,
    List<InvestorModel>? investors,
  }) : investors = investors ?? [];

  factory PendingKycSection.fromJson(Map<String, dynamic> json) {
    final investors = List<InvestorModel>.from(
      (json['investors'] as List?)?.map((x) => InvestorModel.fromJson(x)) ?? [],
    );
    final count = json.containsKey('count')
        ? Parse.toInt(json['count'])
        : investors.length;
    return PendingKycSection(count: count, investors: investors);
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'investors': investors.map((x) => x.toJson()).toList(),
      };
}

class PendingDocumentsSection {
  int count;
  List<PendingDocumentItem> documents;

  PendingDocumentsSection({
    this.count = 0,
    List<PendingDocumentItem>? documents,
  }) : documents = documents ?? [];

  factory PendingDocumentsSection.fromJson(Map<String, dynamic> json) {
    final documents = List<PendingDocumentItem>.from(
      (json['documents'] as List?)
              ?.map((x) => PendingDocumentItem.fromJson(x)) ??
          [],
    );
    final count = json.containsKey('count')
        ? Parse.toInt(json['count'])
        : documents.length;
    return PendingDocumentsSection(count: count, documents: documents);
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'documents': documents.map((x) => x.toJson()).toList(),
      };
}

class PendingFundTransferSection {
  int count;
  List<PendingFundTransferItem> transactions;

  PendingFundTransferSection({
    this.count = 0,
    List<PendingFundTransferItem>? transactions,
  }) : transactions = transactions ?? [];

  factory PendingFundTransferSection.fromJson(Map<String, dynamic> json) {
    final transactions = List<PendingFundTransferItem>.from(
      (json['transactions'] as List?)
              ?.map((x) => PendingFundTransferItem.fromJson(x)) ??
          [],
    );
    final count = json.containsKey('count')
        ? Parse.toInt(json['count'])
        : transactions.length;
    return PendingFundTransferSection(count: count, transactions: transactions);
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'transactions': transactions.map((x) => x.toJson()).toList(),
      };
}

class PendingTaskParty {
  int id;
  String name;
  int mobileNumber;
  String profilePhoto;

  PendingTaskParty({
    this.id = 0,
    this.name = '',
    this.mobileNumber = 0,
    this.profilePhoto = '',
  });

  String get mobileDisplay =>
      mobileNumber == 0 ? '' : mobileNumber.toString();

  String get profile => Parse.parseUrl(profilePhoto);

  factory PendingTaskParty.fromJson(Map<String, dynamic> json) =>
      PendingTaskParty(
        id: Parse.toInt(json['id']),
        name: Parse.toStrings(json['name']),
        mobileNumber: Parse.toInt(json['mobile_number']),
        profilePhoto: Parse.toStrings(json['profile_photo']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobile_number': mobileNumber,
        'profile_photo': profilePhoto,
      };
}

class PendingTaskCompany {
  int id;
  String brandName;
  String logo;

  PendingTaskCompany({
    this.id = 0,
    this.brandName = '',
    this.logo = '',
  });

  String get logoUrl => Parse.parseUrl(logo);

  factory PendingTaskCompany.fromJson(Map<String, dynamic> json) =>
      PendingTaskCompany(
        id: Parse.toInt(json['id']),
        brandName: Parse.toStrings(json['brand_name']),
        logo: Parse.toStrings(json['logo']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand_name': brandName,
        'logo': logo,
      };
}

class PendingDocumentItem {
  int id;
  String type;
  String name;
  DateTime createdAt;
  String link;
  DateTime? expireOn;
  PendingTaskParty investor;
  int transactionId;
  String transactionInvoiceNo;
  PendingTaskCompany company;

  PendingDocumentItem({
    this.id = 0,
    this.type = '',
    this.name = '',
    DateTime? createdAt,
    this.link = '',
    this.expireOn,
    PendingTaskParty? investor,
    this.transactionId = 0,
    this.transactionInvoiceNo = '',
    PendingTaskCompany? company,
  })  : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        investor = investor ?? PendingTaskParty(),
        company = company ?? PendingTaskCompany();

  String get resolvedLink {
    final text = link.trim();
    if (text.isEmpty) return '';
    if (text.startsWith('http://') || text.startsWith('https://')) return text;
    return Parse.parseUrl(text);
  }

  factory PendingDocumentItem.fromJson(Map<String, dynamic> json) =>
      PendingDocumentItem(
        id: Parse.toInt(json['id']),
        type: Parse.toStrings(json['type']),
        name: Parse.toStrings(json['name']),
        createdAt: Parse.toDateTime(json['created_at']),
        link: Parse.toStrings(json['link']),
        expireOn: json['expire_on'] == null ||
                Parse.toStrings(json['expire_on']).isEmpty
            ? null
            : Parse.toDateTime(json['expire_on']),
        investor: PendingTaskParty.fromJson(_asMap(json['investor'])),
        transactionId: Parse.toInt(json['transaction_id']),
        transactionInvoiceNo: Parse.toStrings(json['transaction_invoice_no']),
        company: PendingTaskCompany.fromJson(_asMap(json['company'])),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'created_at': createdAt.toIso8601String(),
        'link': link,
        'expire_on': expireOn?.toIso8601String(),
        'investor': investor.toJson(),
        'transaction_id': transactionId,
        'transaction_invoice_no': transactionInvoiceNo,
        'company': company.toJson(),
      };
}

class PendingFundTransferItem {
  int id;
  String transactionInvoiceNo;
  PendingTaskParty investor;
  PendingTaskCompany company;
  double shares;
  double sharePrice;
  double investmentAmount;
  double payableAmount;
  String instrument;
  String orderStep;
  int status;
  DateTime? settlementDate;

  PendingFundTransferItem({
    this.id = 0,
    this.transactionInvoiceNo = '',
    PendingTaskParty? investor,
    PendingTaskCompany? company,
    this.shares = 0,
    this.sharePrice = 0,
    this.investmentAmount = 0,
    this.payableAmount = 0,
    this.instrument = '',
    this.orderStep = '',
    this.status = 0,
    this.settlementDate,
  })  : investor = investor ?? PendingTaskParty(),
        company = company ?? PendingTaskCompany();

  factory PendingFundTransferItem.fromJson(Map<String, dynamic> json) =>
      PendingFundTransferItem(
        id: Parse.toInt(json['id']),
        transactionInvoiceNo: Parse.toStrings(json['transaction_invoice_no']),
        investor: PendingTaskParty.fromJson(_asMap(json['investor'])),
        company: PendingTaskCompany.fromJson(_asMap(json['company'])),
        shares: Parse.toDouble(json['shares']),
        sharePrice: Parse.toDouble(json['share_price']),
        investmentAmount: Parse.toDouble(json['investment_amount']),
        payableAmount: Parse.toDouble(json['payable_amount']),
        instrument: Parse.toStrings(json['instrument']),
        orderStep: Parse.toStrings(json['order_step']),
        status: Parse.toInt(json['status']),
        settlementDate: json['settlement_date'] == null ||
                Parse.toStrings(json['settlement_date']).isEmpty
            ? null
            : Parse.toDateTime(json['settlement_date']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'transaction_invoice_no': transactionInvoiceNo,
        'investor': investor.toJson(),
        'company': company.toJson(),
        'shares': shares,
        'share_price': sharePrice,
        'investment_amount': investmentAmount,
        'payable_amount': payableAmount,
        'instrument': instrument,
        'order_step': orderStep,
        'status': status,
        'settlement_date': settlementDate?.toIso8601String(),
      };
}
