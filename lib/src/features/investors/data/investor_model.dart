import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

import 'package:private_deals/src/features/wealth_manager/data/models/user/kyc_model.dart';

class InvestorModel {
  bool isSelf = false;
  int preipoKycStatus = 0;
  int id;
  String uuid;
  int partnerId;
  String investorType;
  String name;
  int mobileNumber;
  String email;
  String gender;
  String profilePhoto;
  int kycStatus;
  bool aifStatus;
  int askPasswordChange;
  int isActive;
  DateTime createdAt;
  DateTime updatedAt;
  String token;
  KycModel kyc;
  bool isPrimaryAccess;
  bool isSecondaryAccess;
  bool isPreIpoAccess;
  PartnerDetails partnerDetails;
  InvestorModel? activeInvestor;

  String get placeholderImage {
    switch (gender) {
      case "Male":
        return AppAssets.maleUserPlaceholder;
      default:
        return AppAssets.maleUserPlaceholder;
    }
  }

  bool get changePassword => askPasswordChange == 1;

  /// Name shown in UI; prefixes `[Self]` when this is the logged-in investor.
  String get displayName => isSelf ? '[Self] $name' : name;

  bool get isPreIpoKycComplete => preipoKycStatus == 1;

  String get mobileDisplay =>
      mobileNumber == 0 ? '' : mobileNumber.toString();

  String get contactLine {
    final parts = <String>[
      if (mobileDisplay.isNotEmpty) mobileDisplay,
      if (email.trim().isNotEmpty) email.trim(),
    ];
    return parts.join(' · ');
  }

  InvestorModel({
    this.id = 0,
    this.uuid = '',
    this.partnerId = 0,
    this.investorType = '',
    this.name = '',
    this.mobileNumber = 0,
    this.email = '',
    this.gender = '',
    this.profilePhoto = '',
    this.aifStatus = false,
    this.kycStatus = 0,
    this.askPasswordChange = 0,
    this.isActive = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.token = '',
    KycModel? kyc,
    this.isPrimaryAccess = false,
    this.isSecondaryAccess = false,
    this.isPreIpoAccess = false,
    PartnerDetails? partnerDetails,
    this.activeInvestor,
  })  : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt = updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        kyc = kyc ?? KycModel.fromJson({}),
        partnerDetails = partnerDetails ?? PartnerDetails();

  String get kycStatusString {
    switch (kycStatus) {
      case 0:
        return 'Pending';
      case 1:
        return 'Approved';
      case 2:
        return 'Rejected';
      default:
        return '';
    }
  }

  bool get isKycSuccess => Parse.toBool(kycStatus);

  String get profile => Parse.parseUrl(profilePhoto);

  bool get showKycButton =>
      status == KycStatusEnum.pending || status == KycStatusEnum.rejected;

  KycStatusEnum get status {
    if (isKycSuccess) return KycStatusEnum.approve;
    if (kyc.isNotEmpty) {
      if (kyc.status == app.config.enumValues.status.pending) {
        return KycStatusEnum.approvalPending;
      } else if (kyc.status == app.config.enumValues.status.rejected) {
        return KycStatusEnum.rejected;
      } else {
        return KycStatusEnum.approve;
      }
    } else {
      return KycStatusEnum.pending;
    }
  }

  factory InvestorModel.fromJson(Map<String, dynamic> json) =>
      InvestorModel(
          id: Parse.toInt(json["id"]),
          uuid: Parse.toStrings(json["uuid"]),
          partnerId: Parse.toInt(json["partner_id"]),
          investorType: Parse.toStrings(json["investor_type"]),
          name: Parse.toStrings(json["name"]),
          mobileNumber: Parse.toInt(json["mobile_number"]),
          email: Parse.toStrings(json["email"]),
          gender: Parse.toStrings(json["gender"]),
          profilePhoto: Parse.toStrings(json["profile_photo"]),
          kycStatus: Parse.toInt(json["kyc_status"]),
          aifStatus: Parse.toBool(json["aif_status"]),
          askPasswordChange: Parse.toInt(json["ask_password_change"]),
          isActive: Parse.toInt(json["is_active"]),
          createdAt: Parse.toDateTime(json["created_at"]),
          updatedAt: Parse.toDateTime(json["updated_at"]),
          token: Parse.toStrings(json["token"]),
          isPrimaryAccess: Parse.toBool(json["is_primary_access"]),
          isSecondaryAccess: Parse.toBool(json["is_secondary_access"]),
          isPreIpoAccess: Parse.toBool(json["is_preipo_access"]),
          kyc: KycModel.fromJson(json["kyc"] ?? {}),
          partnerDetails: PartnerDetails.fromJson(
            json["partner_details"] ?? {},
          ),
          activeInvestor: json["active_investor"] != null
              ? InvestorModel.fromJson(json["active_investor"])
              : null,
        )
        ..isSelf = Parse.toBool(json['is_self'])
        ..preipoKycStatus = Parse.toInt(json['preipo_kyc_status']);

  Map<String, dynamic> toJson() => {
    "id": id,
    "is_self": isSelf ? 1 : 0,
    "preipo_kyc_status": preipoKycStatus,
    "uuid": uuid,
    "partner_id": partnerId,
    "investor_type": investorType,
    "name": name,
    "mobile_number": mobileNumber,
    "email": email,
    "gender": gender,
    "profile_photo": profilePhoto,
    "kyc_status": kycStatus,
    "aif_status": aifStatus == true ? 1 : 0,
    "ask_password_change": askPasswordChange,
    "is_active": isActive,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "token": token,
    "kyc": kyc.toJson(),
    "is_primary_access": isPrimaryAccess ? 1 : 0,
    "is_secondary_access": isSecondaryAccess ? 1 : 0,
    "is_preipo_access": isPreIpoAccess ? 1 : 0,
    "partner_details": partnerDetails.toJson(),
    "active_investor": activeInvestor?.toJson(),
  };
}

class SelectInvestorModel {
  String investorName;
  int investorId;
  final bool isSelf;
  RxInt quantity;
  RxDouble price;
  RxDouble totalPrice;
  RxBool isMarket;
  TextEditingController? quantityCTRL;
  TextEditingController? priceCTRL;

  SelectInvestorModel({
    this.investorName = '',
    this.investorId = 0,
    this.isSelf = false,
    int quantity = 0,
    double price = 0.0,
    double totalPrice = 0.0,
    bool isMarket = false,
    this.quantityCTRL,
    this.priceCTRL,
  }) : quantity = quantity.obs,
       price = price.obs,
       totalPrice = totalPrice.obs,
       isMarket = isMarket.obs;

  factory SelectInvestorModel.fromJson(Map<String, dynamic> json) {
    return SelectInvestorModel(
      investorName: Parse.toStrings(json["investorName"]),
      investorId: Parse.toInt(json["investorId"]),
      quantity: Parse.toInt(json["quantity"]),
      price: Parse.toDouble(json["price"]),
      totalPrice: Parse.toDouble(json["total_price"]),
      isMarket: json["isMarket"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "investorName": investorName,
      "investorId": investorId,
      "quantity": quantity.value,
      "price": price.value,
      "total_price": totalPrice.value,
      "isMarket": isMarket.value,
    };
  }
}

class PartnerDetails {
  int partnerId;
  String partnerName;

  PartnerDetails({this.partnerId = 0, this.partnerName = ''});

  factory PartnerDetails.fromJson(Map<String, dynamic> json) => PartnerDetails(
    partnerId: Parse.toInt(json["partner_id"]),
    partnerName: Parse.toStrings(json["partner_name"]),
  );

  Map<String, dynamic> toJson() => {
    "partner_id": partnerId,
    "partner_name": partnerName,
  };
}
