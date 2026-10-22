import 'package:private_deals/src/shared/functions/parse.dart';
import 'package:private_deals/src/shared/models/settlement_option.dart';

class ConfigModel {
  String s3Baseurl;
  double preIpoMinSellAmount;
  EnumValues enumValues;
  List<SettlementOption> settlementDays;

  ConfigModel({
    this.s3Baseurl = '',
    this.preIpoMinSellAmount = 0,
    required this.enumValues,
    this.settlementDays = const [],
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) => ConfigModel(
        s3Baseurl: Parse.toStrings(json["s3-baseurl"]),
        preIpoMinSellAmount: Parse.toDouble(json["pre_ipo_min_sell_amount"]),
        enumValues: EnumValues.fromJson(json["enum"] ?? {}),
        settlementDays: json["settlement_days"] is List
            ? (json["settlement_days"] as List)
                .whereType<Map>()
                .map(
                  (item) => SettlementOption.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((option) => option.value >= 1 && option.value <= 30)
                .toList()
            : const [],
      );

  Map<String, dynamic> toJson() => {
        "s3-baseurl": s3Baseurl,
        "pre_ipo_min_sell_amount": preIpoMinSellAmount,
        "enum": enumValues.toJson(),
        "settlement_days":
            List<dynamic>.from(settlementDays.map((x) => x.toJson())),
      };
}

class EnumValues {
  Gender gender;
  DocumentType documentType;
  InstrumentType instrumentType;
  InvestorProfileVisibility investorProfileVisibility;
  PartnerType partnerType;
  PrimaryTransactionPaymentMode primaryTransactionPaymentMode;
  StartupPrimaryRoundStatus startupPrimaryRoundStatus;
  MinInvestmentType minInvestmentType;
  Status status;
  PreIpoCategoryModel preIpoCategory;

  EnumValues({
    required this.gender,
    required this.documentType,
    required this.instrumentType,
    required this.investorProfileVisibility,
    required this.partnerType,
    required this.primaryTransactionPaymentMode,
    required this.startupPrimaryRoundStatus,
    required this.status,
    required this.minInvestmentType,
    required this.preIpoCategory,
  });

  factory EnumValues.fromJson(Map<String, dynamic> json) => EnumValues(
        gender: Gender.fromJson(json["gender"] ?? {}),
        documentType: DocumentType.fromJson(json["document_type"]),
        instrumentType: InstrumentType.fromJson(json["instrument_type"] ?? {}),
        investorProfileVisibility: InvestorProfileVisibility.fromJson(
            json["investor_profile_visibility"] ?? {}),
        partnerType: PartnerType.fromJson(json["partner_type"] ?? {}),
        primaryTransactionPaymentMode: PrimaryTransactionPaymentMode.fromJson(
            json["primary_transaction_payment_mode"] ?? {}),
        startupPrimaryRoundStatus: StartupPrimaryRoundStatus.fromJson(
            json["startup_primary_round_status"] ?? {}),
        status: Status.fromJson(json["status"] ?? {}),
        minInvestmentType:
            MinInvestmentType.fromJson(json["min_investment_type"] ?? {}),
        preIpoCategory:
            PreIpoCategoryModel.fromJson(json["preipo_category"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "gender": gender.toJson(),
        "document_type": documentType.toJson(),
        "instrument_type": instrumentType.toJson(),
        "investor_profile_visibility": investorProfileVisibility.toJson(),
        "partner_type": partnerType.toJson(),
        "primary_transaction_payment_mode":
            primaryTransactionPaymentMode.toJson(),
        "startup_primary_round_status": startupPrimaryRoundStatus.toJson(),
        "min_investment_type": minInvestmentType.toJson(),
        "status": status.toJson(),
        "preipo_category": preIpoCategory.toJson(),
      };
}

class Gender {
  String male;
  String female;
  String other;

  Gender({
    this.male = '',
    this.female = '',
    this.other = '',
  });

  factory Gender.fromJson(Map<String, dynamic> json) => Gender(
        male: Parse.toStrings(json["male"]),
        female: Parse.toStrings(json["female"]),
        other: Parse.toStrings(json["other"]),
      );

  Map<String, dynamic> toJson() => {
        "male": male,
        "female": female,
        "other": other,
      };
}

/// One entry from get-config `enum.document_type` (client document types only).
class DocumentTypeOption {
  final String value;
  final String label;

  const DocumentTypeOption({required this.value, required this.label});
}

/// Dynamic document types from get-config. Do not hardcode SSA/PAN/etc.
class DocumentType {
  final List<DocumentTypeOption> options;

  const DocumentType({this.options = const []});

  List<String> get values =>
      options.map((option) => option.value).toList(growable: false);

  factory DocumentType.fromJson(dynamic raw) {
    if (raw is List) {
      final options = <DocumentTypeOption>[];
      for (final item in raw) {
        final value = Parse.toStrings(item).trim();
        if (value.isEmpty) continue;
        options.add(DocumentTypeOption(value: value, label: value));
      }
      return DocumentType(options: options);
    }

    if (raw is Map) {
      final options = <DocumentTypeOption>[];
      raw.forEach((key, value) {
        final keyText = Parse.toStrings(key).trim();
        final valueText = Parse.toStrings(value).trim();
        // Prefer the API string (value) when present; fall back to key.
        final filterValue = valueText.isNotEmpty ? valueText : keyText;
        if (filterValue.isEmpty) return;
        final label = valueText.isNotEmpty ? valueText : keyText;
        options.add(DocumentTypeOption(value: filterValue, label: label));
      });
      return DocumentType(options: options);
    }

    return const DocumentType();
  }

  Map<String, dynamic> toJson() => {
        for (final option in options) option.value: option.label,
      };
}

class InstrumentType {
  String equity;
  String ccps;
  String ccd;

  InstrumentType({
    this.equity = '',
    this.ccps = '',
    this.ccd = '',
  });

  factory InstrumentType.fromJson(Map<String, dynamic> json) => InstrumentType(
        equity: Parse.toStrings(json["equity"]),
        ccps: Parse.toStrings(json["ccps"]),
        ccd: Parse.toStrings(json["ccd"]),
      );

  Map<String, dynamic> toJson() => {
        "equity": equity,
        "ccps": ccps,
        "ccd": ccd,
      };
}

class InvestorProfileVisibility {
  String public;
  String nameonly;
  String private;

  InvestorProfileVisibility({
    this.public = '',
    this.nameonly = '',
    this.private = '',
  });

  factory InvestorProfileVisibility.fromJson(Map<String, dynamic> json) =>
      InvestorProfileVisibility(
        public: Parse.toStrings(json["public"]),
        nameonly: Parse.toStrings(json["nameonly"]),
        private: Parse.toStrings(json["Private"]),
      );

  Map<String, dynamic> toJson() => {
        "public": public,
        "nameonly": nameonly,
        "private": private,
      };
}

class PartnerType {
  String wealthmanager;
  String distributor;
  String retailer;
  String relationManager;
  String institution;

  PartnerType({
    this.wealthmanager = '',
    this.distributor = '',
    this.retailer = '',
    this.relationManager = '',
    this.institution = '',
  });

  factory PartnerType.fromJson(Map<String, dynamic> json) => PartnerType(
        wealthmanager: Parse.toStrings(json["wealthmanager"]),
        distributor: Parse.toStrings(json["distributor"]),
        retailer: Parse.toStrings(json["retailer"]),
        relationManager: Parse.toStrings(json["relationmanager"]),
        institution: Parse.toStrings(json["institution"]),
      );

  Map<String, dynamic> toJson() => {
        "wealthmanager": wealthmanager,
        "distributor": distributor,
        "retailer": retailer,
        "relationmanager": relationManager,
        "institution": institution,
      };
}

class PrimaryTransactionPaymentMode {
  String rtgs;
  String cheque;
  String mandate;

  PrimaryTransactionPaymentMode({
    this.rtgs = '',
    this.cheque = '',
    this.mandate = '',
  });

  factory PrimaryTransactionPaymentMode.fromJson(Map<String, dynamic> json) =>
      PrimaryTransactionPaymentMode(
        rtgs: Parse.toStrings(json["rtgs"]),
        cheque: Parse.toStrings(json["cheque"]),
        mandate: Parse.toStrings(json["mandate"]),
      );

  Map<String, dynamic> toJson() => {
        "rtgs": rtgs,
        "cheque": cheque,
        "mandate": mandate,
      };
}

class StartupPrimaryRoundStatus {
  String pending;
  String comingsoon;
  String raisingnow;
  String completed;

  StartupPrimaryRoundStatus({
    this.pending = '',
    this.comingsoon = '',
    this.raisingnow = '',
    this.completed = '',
  });

  factory StartupPrimaryRoundStatus.fromJson(Map<String, dynamic> json) =>
      StartupPrimaryRoundStatus(
        pending: Parse.toStrings(json["pending"]),
        comingsoon: Parse.toStrings(json["comingsoon"]),
        raisingnow: Parse.toStrings(json["raisingnow"]),
        completed: Parse.toStrings(json["completed"]),
      );

  Map<String, dynamic> toJson() => {
        "pending": pending,
        "comingsoon": comingsoon,
        "raisingnow": raisingnow,
        "completed": completed,
      };
}

class Status {
  String pending;
  String approved;
  String rejected;

  Status({
    this.pending = '',
    this.approved = '',
    this.rejected = '',
  });

  factory Status.fromJson(Map<String, dynamic> json) => Status(
        pending: Parse.toStrings(json["pending"]),
        approved: Parse.toStrings(json["approved"]),
        rejected: Parse.toStrings(json["rejected"]),
      );

  Map<String, dynamic> toJson() => {
        "pending": pending,
        "approved": approved,
        "rejected": rejected,
      };
}

class MinInvestmentType {
  String quantity;
  String amount;

  MinInvestmentType({
    this.quantity = '',
    this.amount = '',
  });

  factory MinInvestmentType.fromJson(Map<String, dynamic> json) =>
      MinInvestmentType(
        quantity: Parse.toStrings(json["quantity"]),
        amount: Parse.toStrings(json["amount"]),
      );

  Map<String, dynamic> toJson() => {
        "quantity": quantity,
        "amount": amount,
      };
}

class PreIpoCategoryModel {
  String trending;
  String comingSoon;
  String listed;
  String liquidStocks;
  String exclusiveDeals;

  PreIpoCategoryModel({
    this.trending = '',
    this.comingSoon = '',
    this.listed = '',
    this.liquidStocks = '',
    this.exclusiveDeals = '',
  });

  factory PreIpoCategoryModel.fromJson(Map<String, dynamic> json) =>
      PreIpoCategoryModel(
        trending: Parse.toStrings(json["trending"]),
        comingSoon: Parse.toStrings(json["coming_soon"]),
        listed: Parse.toStrings(json["listed"]),
        liquidStocks: Parse.toStrings(json["liquid_stocks"]),
        exclusiveDeals: Parse.toStrings(json["exclusive_deals"]),
      );

  Map<String, dynamic> toJson() => {
        "trending": trending,
        "coming_soon": comingSoon,
        "listed": listed,
        "liquid_stocks": liquidStocks,
        "exclusive_deals": exclusiveDeals,
      };
}
