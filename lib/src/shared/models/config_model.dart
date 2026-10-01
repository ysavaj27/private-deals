import 'package:private_deals/src/core/configuration/init_config.dart';

import 'package:private_deals/src/shared/functions/parse.dart';

class ConfigModel {
  Document document;
  Document image;
  Document video;
  String s3Baseurl;
  int appPaginationPageLimit;
  double preIpoMinSellAmount;
  EnumValues enumValues;
  LandingBanner landingBanner;
  List<String> notes;
  String preIpoBuyButton;
  String currentApiVersion;
  List<AppVersionModel> appVersion;
  BuildModel build;

  ConfigModel({
    required this.document,
    required this.image,
    required this.video,
    this.s3Baseurl = '',
    this.appPaginationPageLimit = 0,
    this.preIpoMinSellAmount = 0,
    required this.enumValues,
    required this.landingBanner,
    required this.notes,
    this.currentApiVersion = '',
    this.preIpoBuyButton = '',
    this.appVersion = const [],
    required this.build,
  });

  InfoModel get version {
    var model = appVersion.firstWhere((e) => e.type == init.packageName);
    var data = model.data.firstWhere((e) => e.device == init.deviceOs);
    return data;
  }

  factory ConfigModel.fromJson(Map<String, dynamic> json) => ConfigModel(
        document: Document.fromJson(json["document"] ?? {}),
        image: Document.fromJson(json["image"] ?? {}),
        video: Document.fromJson(json["video"] ?? {}),
        s3Baseurl: Parse.toStrings(json["s3-baseurl"]),
        appPaginationPageLimit: Parse.toInt(json["app_pagination_page_limit"]),
        preIpoMinSellAmount: Parse.toDouble(json["pre_ipo_min_sell_amount"]),
        enumValues: EnumValues.fromJson(json["enum"] ?? {}),
        build: BuildModel.fromJson(json["build"] ?? {}),
        preIpoBuyButton: Parse.toStrings(json["preipo_buy_button"]),
        landingBanner: LandingBanner.fromJson(json["landing_banner"] ?? {}),
        notes: json["notes"] != null
            ? List<String>.from(json["notes"].map((x) => Parse.toStrings(x)))
            : [],
        currentApiVersion: Parse.toStrings(json["current_api_version"]),
        appVersion: json["app_version"] != null
            ? List<AppVersionModel>.from(
                json["app_version"].map((x) => AppVersionModel.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "document": document.toJson(),
        "image": image.toJson(),
        "video": video.toJson(),
        "s3-baseurl": s3Baseurl,
        "app_pagination_page_limit": appPaginationPageLimit,
        "pre_ipo_min_sell_amount": preIpoMinSellAmount,
        "enum": enumValues.toJson(),
        "landing_banner": landingBanner.toJson(),
        "notes": List<dynamic>.from(notes.map((x) => x)),
        "app_version": List<dynamic>.from(appVersion.map((x) => x)),
        "current_api_version": currentApiVersion,
        "build": build.toJson(),
        "preipo_buy_button": preIpoBuyButton,
      };
}

class Document {
  int maxSize;
  String extensions;

  Document({
    this.maxSize = 0,
    this.extensions = '',
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
        maxSize: Parse.toInt(json["max_size"]),
        extensions: Parse.toStrings(json["extensions"]),
      );

  Map<String, dynamic> toJson() => {
        "max_size": maxSize,
        "extensions": extensions,
      };
}

class EnumValues {
  Gender gender;
  BankAccountType bankAccountType;
  DocumentType documentType;
  InstrumentType instrumentType;
  InvestorProfileVisibility investorProfileVisibility;
  InvestorType investorType;
  MessagesStatus messagesStatus;
  NotificationType notificationType;
  PartnerType partnerType;
  PaymentStatus paymentStatus;
  PrimaryTransactionPaymentMode primaryTransactionPaymentMode;
  PrimaryTransactionStatus primaryTransactionStatus;
  StartupPrimaryRoundStatus startupPrimaryRoundStatus;
  StartupRoundType startupRoundType;
  WpMessageType wpMessageType;
  CodeVerificationType codeVerificationType;
  CommunicationType communicationType;
  DeviceTypeModel deviceType;
  MinInvestmentType minInvestmentType;
  Status status;
  PreIpoCategoryModel preIpoCategory;

  EnumValues({
    required this.gender,
    required this.bankAccountType,
    required this.documentType,
    required this.instrumentType,
    required this.investorProfileVisibility,
    required this.investorType,
    required this.messagesStatus,
    required this.notificationType,
    required this.partnerType,
    required this.paymentStatus,
    required this.primaryTransactionPaymentMode,
    required this.primaryTransactionStatus,
    required this.startupPrimaryRoundStatus,
    required this.startupRoundType,
    required this.wpMessageType,
    required this.codeVerificationType,
    required this.communicationType,
    required this.deviceType,
    required this.status,
    required this.minInvestmentType,
    required this.preIpoCategory,
  });

  factory EnumValues.fromJson(Map<String, dynamic> json) => EnumValues(
        gender: Gender.fromJson(json["gender"] ?? {}),
        bankAccountType:
            BankAccountType.fromJson(json["bank_account_type"] ?? {}),
        documentType: DocumentType.fromJson(json["document_type"] ?? {}),
        instrumentType: InstrumentType.fromJson(json["instrument_type"] ?? {}),
        investorProfileVisibility: InvestorProfileVisibility.fromJson(
            json["investor_profile_visibility"] ?? {}),
        investorType: InvestorType.fromJson(json["investor_type"] ?? {}),
        messagesStatus: MessagesStatus.fromJson(json["messages_status"] ?? {}),
        notificationType:
            NotificationType.fromJson(json["notification_type"] ?? {}),
        partnerType: PartnerType.fromJson(json["partner_type"] ?? {}),
        paymentStatus: PaymentStatus.fromJson(json["payment_status"] ?? {}),
        primaryTransactionPaymentMode: PrimaryTransactionPaymentMode.fromJson(
            json["primary_transaction_payment_mode"] ?? {}),
        primaryTransactionStatus: PrimaryTransactionStatus.fromJson(
            json["primary_transaction_status"] ?? {}),
        startupPrimaryRoundStatus: StartupPrimaryRoundStatus.fromJson(
            json["startup_primary_round_status"] ?? {}),
        startupRoundType:
            StartupRoundType.fromJson(json["startup_round_type"] ?? {}),
        wpMessageType: WpMessageType.fromJson(json["wp_message_type"] ?? {}),
        codeVerificationType:
            CodeVerificationType.fromJson(json["code_verification_type"] ?? {}),
        communicationType:
            CommunicationType.fromJson(json["communication_type"] ?? {}),
        deviceType: DeviceTypeModel.fromJson(json["device_type"] ?? {}),
        status: Status.fromJson(json["status"] ?? {}),
        minInvestmentType:
            MinInvestmentType.fromJson(json["min_investment_type"] ?? {}),
        preIpoCategory:
            PreIpoCategoryModel.fromJson(json["preipo_category"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "gender": gender.toJson(),
        "bank_account_type": bankAccountType.toJson(),
        "document_type": documentType.toJson(),
        "instrument_type": instrumentType.toJson(),
        "investor_profile_visibility": investorProfileVisibility.toJson(),
        "investor_type": investorType.toJson(),
        "messages_status": messagesStatus.toJson(),
        "notification_type": notificationType.toJson(),
        "partner_type": partnerType.toJson(),
        "payment_status": paymentStatus.toJson(),
        "primary_transaction_payment_mode":
            primaryTransactionPaymentMode.toJson(),
        "primary_transaction_status": primaryTransactionStatus.toJson(),
        "startup_primary_round_status": startupPrimaryRoundStatus.toJson(),
        "startup_round_type": startupRoundType.toJson(),
        "wp_message_type": wpMessageType.toJson(),
        "code_verification_type": codeVerificationType.toJson(),
        "communication_type": communicationType.toJson(),
        "device_type": deviceType.toJson(),
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
        male: json["male"] ?? '',
        female: json["female"] ?? '',
        other: json["other"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "male": male,
        "female": female,
        "other": other,
      };
}

class BankAccountType {
  String current;
  String saving;

  BankAccountType({
    this.current = '',
    this.saving = '',
  });

  factory BankAccountType.fromJson(Map<String, dynamic> json) =>
      BankAccountType(
        current: json["current"] ?? '',
        saving: json["saving"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "current": current,
        "saving": saving,
      };
}

class DocumentType {
  String ssa;
  String loi;
  String offer;
  String mgtzip;
  String mgtchallan;
  String pas;
  String sha;
  String rtgsreceipt;
  String chequecounterslip;
  String secondarysh;
  String paymentreceipt;
  String sharereceipt;

  DocumentType({
    this.ssa = '',
    this.loi = '',
    this.offer = '',
    this.mgtzip = '',
    this.mgtchallan = '',
    this.pas = '',
    this.sha = '',
    this.rtgsreceipt = '',
    this.chequecounterslip = '',
    this.secondarysh = '',
    this.paymentreceipt = '',
    this.sharereceipt = '',
  });

  factory DocumentType.fromJson(Map<String, dynamic> json) => DocumentType(
        ssa: json["ssa"] ?? '',
        loi: json["loi"] ?? '',
        offer: json["offer"] ?? '',
        mgtzip: json["mgtzip"] ?? '',
        mgtchallan: json["mgtchallan"] ?? '',
        pas: json["pas"] ?? '',
        sha: json["sha"] ?? '',
        rtgsreceipt: json["rtgsreceipt"] ?? '',
        chequecounterslip: json["chequecounterslip"] ?? '',
        secondarysh: json["secondarysh"] ?? '',
        paymentreceipt: json["paymentreceipt"] ?? '',
        sharereceipt: json["sharereceipt"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "ssa": ssa,
        "loi": loi,
        "offer": offer,
        "mgtzip": mgtzip,
        "mgtchallan": mgtchallan,
        "pas": pas,
        "sha": sha,
        "rtgsreceipt": rtgsreceipt,
        "chequecounterslip": chequecounterslip,
        "secondarysh": secondarysh,
        "paymentreceipt": paymentreceipt,
        "sharereceipt": sharereceipt,
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
        equity: json["equity"] ?? '',
        ccps: json["ccps"] ?? '',
        ccd: json["ccd"] ?? '',
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
        public: json["public"] ?? '',
        nameonly: json["nameonly"] ?? '',
        private: json["Private"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "public": public,
        "nameonly": nameonly,
        "private": private,
      };
}

class InvestorType {
  String individual;
  String hinduundividedfamily;
  String privatelimited;
  String publiclimited;
  String partnership;
  String limitedliabilitypartnership;

  InvestorType({
    this.individual = '',
    this.hinduundividedfamily = '',
    this.privatelimited = '',
    this.publiclimited = '',
    this.partnership = '',
    this.limitedliabilitypartnership = '',
  });

  factory InvestorType.fromJson(Map<String, dynamic> json) => InvestorType(
        individual: json["individual"] ?? '',
        hinduundividedfamily: json["hinduundividedfamily"] ?? '',
        privatelimited: json["privatelimited"] ?? '',
        publiclimited: json["publiclimited"] ?? '',
        partnership: json["partnership"] ?? '',
        limitedliabilitypartnership: json["limitedliabilitypartnership"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "individual": individual,
        "hinduundividedfamily": hinduundividedfamily,
        "privatelimited": privatelimited,
        "publiclimited": publiclimited,
        "partnership": partnership,
        "limitedliabilitypartnership": limitedliabilitypartnership,
      };
}

class MessagesStatus {
  String pending;
  String sent;
  String failed;

  MessagesStatus({
    this.pending = '',
    this.sent = '',
    this.failed = '',
  });

  factory MessagesStatus.fromJson(Map<String, dynamic> json) => MessagesStatus(
        pending: json["pending"] ?? '',
        sent: json["sent"] ?? '',
        failed: json["failed"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "pending": pending,
        "sent": sent,
        "failed": failed,
      };
}

class NotificationType {
  String event;
  String regular;

  NotificationType({
    this.event = '',
    this.regular = '',
  });

  factory NotificationType.fromJson(Map<String, dynamic> json) =>
      NotificationType(
        event: json["event"] ?? '',
        regular: json["regular"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "event": event,
        "regular": regular,
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
        wealthmanager: json["wealthmanager"] ?? '',
        distributor: json["distributor"] ?? '',
        retailer: json["retailer"] ?? '',
        relationManager: json["relationmanager"] ?? '',
        institution: json["institution"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "wealthmanager": wealthmanager,
        "distributor": distributor,
        "retailer": retailer,
        "relationmanager": relationManager,
        "institution": institution,
      };
}

class PaymentStatus {
  String pending;
  String completed;
  String partialcompleted;

  PaymentStatus({
    this.pending = '',
    this.completed = '',
    this.partialcompleted = '',
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) => PaymentStatus(
        pending: json["pending"] ?? '',
        completed: json["completed"] ?? '',
        partialcompleted: json["partialcompleted"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "pending": pending,
        "completed": completed,
        "partialcompleted": partialcompleted,
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
        rtgs: json["rtgs"] ?? '',
        cheque: json["cheque"] ?? '',
        mandate: json["mandate"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "rtgs": rtgs,
        "cheque": cheque,
        "mandate": mandate,
      };
}

class PrimaryTransactionStatus {
  String commitmentpending;
  String committed;
  String ssasent;
  String ssasigned;
  String mgtcompleted;
  String offerlettersent;
  String offerlettersigned;
  String paymentreceived;
  String pasuploaded;
  String shasent;
  String completed;

  PrimaryTransactionStatus({
    this.commitmentpending = '',
    this.committed = '',
    this.ssasent = '',
    this.ssasigned = '',
    this.mgtcompleted = '',
    this.offerlettersent = '',
    this.offerlettersigned = '',
    this.paymentreceived = '',
    this.pasuploaded = '',
    this.shasent = '',
    this.completed = '',
  });

  factory PrimaryTransactionStatus.fromJson(Map<String, dynamic> json) =>
      PrimaryTransactionStatus(
        commitmentpending: json["commitmentpending"] ?? '',
        committed: json["committed"] ?? '',
        ssasent: json["ssasent"] ?? '',
        ssasigned: json["ssasigned"] ?? '',
        mgtcompleted: json["mgtcompleted"] ?? '',
        offerlettersent: json["offerlettersent"] ?? '',
        offerlettersigned: json["offerlettersigned"] ?? '',
        paymentreceived: json["paymentreceived"] ?? '',
        pasuploaded: json["pasuploaded"] ?? '',
        shasent: json["shasent"] ?? '',
        completed: json["completed"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "commitmentpending": commitmentpending,
        "committed": committed,
        "ssasent": ssasent,
        "ssasigned": ssasigned,
        "mgtcompleted": mgtcompleted,
        "offerlettersent": offerlettersent,
        "offerlettersigned": offerlettersigned,
        "paymentreceived": paymentreceived,
        "pasuploaded": pasuploaded,
        "shasent": shasent,
        "completed": completed,
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
        pending: json["pending"] ?? '',
        comingsoon: json["comingsoon"] ?? '',
        raisingnow: json["raisingnow"] ?? '',
        completed: json["completed"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "pending": pending,
        "comingsoon": comingsoon,
        "raisingnow": raisingnow,
        "completed": completed,
      };
}

class StartupRoundType {
  String primary;
  String aif;
  String secondary;

  StartupRoundType({
    this.primary = '',
    this.aif = '',
    this.secondary = '',
  });

  factory StartupRoundType.fromJson(Map<String, dynamic> json) =>
      StartupRoundType(
        primary: json["primary"] ?? '',
        aif: json["aif"] ?? '',
        secondary: json["secondary"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "primary": primary,
        "aif": aif,
        "secondary": secondary,
      };
}

class WpMessageType {
  String media;
  String text;
  String image;

  WpMessageType({
    this.media = '',
    this.text = '',
    this.image = '',
  });

  factory WpMessageType.fromJson(Map<String, dynamic> json) => WpMessageType(
        media: json["media"] ?? '',
        text: json["text"] ?? '',
        image: json["image"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "media": media,
        "text": text,
        "image": image,
      };
}

class CodeVerificationType {
  String register;
  String forgotPassword;

  CodeVerificationType({
    this.register = '',
    this.forgotPassword = '',
  });

  factory CodeVerificationType.fromJson(Map<String, dynamic> json) =>
      CodeVerificationType(
        register: json["register"] ?? '',
        forgotPassword: json["forgot_password"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "register": register,
        "forgot_password": forgotPassword,
      };
}

class CommunicationType {
  String sms;
  String email;
  String whatsapp;

  CommunicationType({
    this.sms = '',
    this.email = '',
    this.whatsapp = '',
  });

  factory CommunicationType.fromJson(Map<String, dynamic> json) =>
      CommunicationType(
        sms: json["sms"] ?? '',
        email: json["email"] ?? '',
        whatsapp: json["whatsapp"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "sms": sms,
        "email": email,
        "whatsapp": whatsapp,
      };
}

class DeviceTypeModel {
  String web;
  String android;
  String ios;
  String desktop;

  DeviceTypeModel({
    this.web = '',
    this.android = '',
    this.ios = '',
    this.desktop = '',
  });

  factory DeviceTypeModel.fromJson(Map<String, dynamic> json) =>
      DeviceTypeModel(
        web: json["web"] ?? '',
        android: json["android"] ?? '',
        ios: json["ios"] ?? '',
        desktop: json["desktop"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "web": web,
        "android": android,
        "ios": ios,
        "desktop": desktop,
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
        pending: json["pending"] ?? '',
        approved: json["approved"] ?? '',
        rejected: json["rejected"] ?? '',
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
        quantity: json["quantity"] ?? '',
        amount: json["amount"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "quantity": quantity,
        "amount": amount,
      };
}

class AppVersionModel {
  String type;
  List<InfoModel> data;

  AppVersionModel({
    this.type = '',
    this.data = const [],
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) =>
      AppVersionModel(
        type: json["type"] ?? "",
        data: json["data"] != null
            ? List<InfoModel>.from(
                json["data"].map((x) => InfoModel.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class InfoModel {
  String device;

  // int lastVersionCode;
  int currentVersionCode;

  // int lastVersion;
  // int currentVersion;
  bool forceUpdate;
  String title;
  String description;

  InfoModel({
    this.device = '',
    // this.lastVersionCode = 0,
    this.currentVersionCode = 1,
    // this.lastVersion = 0,
    // this.currentVersion = 0,
    this.forceUpdate = false,
    this.title = '',
    this.description = '',
  });

  factory InfoModel.fromJson(Map<String, dynamic> json) => InfoModel(
        device: json["device"] ?? "",
        // lastVersionCode: json["last_version_code"] ?? 0,
        currentVersionCode: json["current_version_code"] ?? 0,
        // lastVersion: json["last_version"] ?? 0,
        // currentVersion: json["current_version"] ?? 0,
        forceUpdate: json["force_update"] ?? false,
        title: json["title"]?.toString() ?? "",
        description: json["description"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "device": device,
        // "last_version_code": lastVersionCode,
        "current_version_code": currentVersionCode,
        // "last_version": lastVersion,
        // "current_version": currentVersion,
        "force_update": forceUpdate,
        "title": title,
        "description": description,
      };
}

class LandingBanner {
  List<String> preipo;
  List<String> secondary;
  List<String> primary;

  LandingBanner({
    this.preipo = const [],
    this.secondary = const [],
    this.primary = const [],
  });

  factory LandingBanner.fromJson(Map<String, dynamic> json) => LandingBanner(
        preipo: json["preipo"] != null
            ? List<String>.from(json["preipo"].map((x) => x))
            : [],
        secondary: json["secondary"] != null
            ? List<String>.from(json["secondary"].map((x) => x))
            : [],
        primary: json["primary"] != null
            ? List<String>.from(json["primary"].map((x) => x))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "preipo": List<dynamic>.from(preipo.map((x) => x)),
        "secondary": List<dynamic>.from(secondary.map((x) => x)),
        "primary": List<dynamic>.from(primary.map((x) => x)),
      };
}

class BuildModel {
  Windows windows;

  BuildModel({
    required this.windows,
  });

  factory BuildModel.fromJson(Map<String, dynamic> json) => BuildModel(
        windows: Windows.fromJson(json["windows"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "windows": windows.toJson(),
      };
}

class Windows {
  String investor;
  String distributer;

  Windows({
    required this.investor,
    required this.distributer,
  });

  factory Windows.fromJson(Map<String, dynamic> json) => Windows(
        investor: json["investor"] ?? "",
        distributer: json["distributer"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "investor": investor,
        "distributer": distributer,
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
