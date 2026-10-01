import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

import 'package:private_deals/src/features/wealth_manager/data/models/demat_account/demat_account_model.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/user/investor_detail_model.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/user/kyc_model.dart';

class InvestorModel {
  bool isSelf = false;
  int preipoKycStatus = 0;
  int id;
  String uuid;
  int partnerId;
  int parentInvestorId;
  int familyRelationId;
  String investorType;
  String name;
  int mobileCountryCode;
  int mobileNumber;
  String email;
  String address;
  int cityId;
  int stateId;
  int countryId;
  int pincode;
  String gender;
  String profilePhoto;
  String profileVisibility;
  int registrationStep;
  int kycStatus;
  bool aifStatus;
  String aadharVerifiedType;
  int isFakeInvestor;
  int isVerifiedMobile;
  int isVerifiedEmail;
  int askPasswordChange;
  int isActive;
  bool isBlocked;
  bool isDeleted;
  bool isDemo;
  int createdBy;
  int updatedBy;
  DateTime createdAt;
  DateTime updatedAt;
  String token;
  MasterTypeModel city;
  MasterTypeModel state;
  MasterTypeModel country;
  MasterTypeModel relation;
  DematAccountModel dematAccount;
  KycModel kyc;
  IDetailModel investorDetail;
  double totalInvested;
  int noOfStartups;
  double commissionEarned;
  int investorCount;
  bool isPrimaryAccess;
  bool isSecondaryAccess;
  bool isPreIpoAccess;
  List<WStartupList> startupList;
  PartnerDetails partnerDetails;
  Partner partner;
  InvestorModel? activeInvestor;

  // List<PortfolioModel> portfolio;

  String get placeholderImage {
    switch (gender) {
      case "Male":
        return AppAssets.maleUserPlaceholder;
      // case "Female":
      //   return AppAssets.femaleUserPlaceholder;
      default:
        return AppAssets.maleUserPlaceholder;
    }
  }

  bool get changePassword => askPasswordChange == 1;

  InvestorModel({
    this.id = 0,
    this.uuid = '',
    this.partnerId = 0,
    this.parentInvestorId = 0,
    this.familyRelationId = 0,
    this.investorType = '',
    this.name = '',
    this.mobileCountryCode = 0,
    this.mobileNumber = 0,
    this.email = '',
    this.address = '',
    this.cityId = 0,
    this.stateId = 0,
    this.countryId = 0,
    this.pincode = 0,
    this.gender = '',
    this.profilePhoto = '',
    this.profileVisibility = '',
    this.registrationStep = 0,
    this.aifStatus = false,
    this.kycStatus = 0,
    this.aadharVerifiedType = '',
    this.isFakeInvestor = 0,
    this.isVerifiedMobile = 0,
    this.isVerifiedEmail = 0,
    this.askPasswordChange = 0,
    this.isActive = 0,
    this.isBlocked = false,
    this.isDeleted = false,
    this.isDemo = false,
    this.createdBy = 0,
    this.updatedBy = 0,
    required this.createdAt,
    required this.updatedAt,
    this.token = '',
    required this.city,
    required this.state,
    required this.country,
    required this.relation,
    required this.dematAccount,
    required this.kyc,
    required this.investorDetail,
    this.totalInvested = 0.0,
    this.noOfStartups = 0,
    this.commissionEarned = 0.0,
    this.investorCount = 0,
    this.startupList = const [],
    this.isPrimaryAccess = false,
    this.isSecondaryAccess = false,
    this.isPreIpoAccess = false,
    // this.portfolio = const [],
    required this.partnerDetails,
    required this.partner,
    this.activeInvestor,
  });

  String get kycStatusString {
    switch (kycStatus) {
      case 0:
        return 'Pending';
      case 1:
        return 'Approve';
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
    if (isKycSuccess) KycStatusEnum.approve;
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
          parentInvestorId: Parse.toInt(json["parent_investor_id"]),
          familyRelationId: Parse.toInt(json["family_relation_id"]),
          investorType: Parse.toStrings(json["investor_type"]),
          name: Parse.toStrings(json["name"]),
          mobileCountryCode: Parse.toInt(json["mobile_country_code"]),
          mobileNumber: Parse.toInt(json["mobile_number"]),
          email: Parse.toStrings(json["email"]),
          address: Parse.toStrings(json["address"]),
          cityId: Parse.toInt(json["city_id"]),
          stateId: Parse.toInt(json["state_id"]),
          countryId: Parse.toInt(json["country_id"]),
          pincode: Parse.toInt(json["pincode"]),
          gender: Parse.toStrings(json["gender"]),
          profilePhoto: Parse.toStrings(json["profile_photo"]),
          profileVisibility: Parse.toStrings(json["profile_visibility"]),
          registrationStep: Parse.toInt(json["registration_step"]),
          kycStatus: Parse.toInt(json["kyc_status"]),
          aifStatus: Parse.toBool(json["aif_status"]),
          aadharVerifiedType: Parse.toStrings(json["aadhar_verified_type"]),
          isFakeInvestor: Parse.toInt(json["is_fake_investor"]),
          isVerifiedMobile: Parse.toInt(json["is_verified_mobile"]),
          isVerifiedEmail: Parse.toInt(json["is_verified_email"]),
          askPasswordChange: Parse.toInt(json["ask_password_change"]),
          isActive: Parse.toInt(json["is_active"]),
          isBlocked: Parse.toBool(json["is_blocked"]),
          isDeleted: Parse.toBool(json["is_deleted"]),
          isDemo: Parse.toBool(json["is_demo"]),
          createdBy: Parse.toInt(json["created_by"]),
          updatedBy: Parse.toInt(json["updated_by"]),
          totalInvested: Parse.toDouble(json["total_invested"]),
          noOfStartups: Parse.toInt(json["no_of_startups"]),
          commissionEarned: Parse.toDouble(json["commission_earned"]),
          investorCount: Parse.toInt(json["investor_count"]),
          startupList: json["startup_list"] != null
              ? List<WStartupList>.from(
                  json["startup_list"].map((x) => WStartupList.fromJson(x)),
                )
              : [],
          createdAt: Parse.toDateTime(json["created_at"]),
          updatedAt: Parse.toDateTime(json["updated_at"]),
          token: Parse.toStrings(json["token"]),
          isPrimaryAccess: Parse.toBool(json["is_primary_access"]),
          isSecondaryAccess: Parse.toBool(json["is_secondary_access"]),
          isPreIpoAccess: Parse.toBool(json["is_preipo_access"]),
          city: MasterTypeModel.fromJson(json["city"] ?? {}),
          state: MasterTypeModel.fromJson(json["state"] ?? {}),
          country: MasterTypeModel.fromJson(json["country"] ?? {}),
          relation: MasterTypeModel.fromJson(json["relation"] ?? {}),
          dematAccount: DematAccountModel.fromJson(json["demat_account"] ?? {}),
          kyc: KycModel.fromJson(json["kyc"] ?? {}),
          investorDetail: IDetailModel.fromJson(json["investor_detail"] ?? {}),
          partnerDetails: PartnerDetails.fromJson(
            json["partner_details"] ?? {},
          ),
          partner: Partner.fromJson(json["partner"] ?? {}),
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
    "parent_investor_id": parentInvestorId,
    "family_relation_id": familyRelationId,
    "investor_type": investorType,
    "name": name,
    "mobile_country_code": mobileCountryCode,
    "mobile_number": mobileNumber,
    "email": email,
    "address": address,
    "city_id": cityId,
    "state_id": stateId,
    "country_id": countryId,
    "pincode": pincode,
    "gender": gender,
    "profile_photo": profilePhoto,
    "profile_visibility": profileVisibility,
    "registration_step": registrationStep,
    "kyc_status": kycStatus,
    "aif_status": aifStatus == true ? 1 : 0,
    "aadhar_verified_type": aadharVerifiedType,
    "is_fake_investor": isFakeInvestor,
    "is_verified_mobile": isVerifiedMobile,
    "is_verified_email": isVerifiedEmail,
    "ask_password_change": askPasswordChange,
    "is_active": isActive,
    "is_blocked": isBlocked,
    "is_deleted": isDeleted,
    "is_demo": isDemo,
    "created_by": createdBy,
    "updated_by": updatedBy,
    "total_invested": totalInvested,
    "no_of_startups": noOfStartups,
    "investor_count": investorCount,
    "commission_earned": commissionEarned,
    "startup_list": List<dynamic>.from(startupList.map((x) => x.toJson())),
    // "portfolio": List<dynamic>.from(portfolio.map((x) => x.toJson())),
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "token": token,
    "city": city.toJson(),
    "state": state.toJson(),
    "country": country.toJson(),
    "relation": relation.toJson(),
    "demat_account": dematAccount.toJson(),
    "kyc": kyc.toJson(),
    "investor_detail": investorDetail.toJson(),
    "is_primary_access": isPrimaryAccess ? 1 : 0,
    "is_secondary_access": isSecondaryAccess ? 1 : 0,
    "is_preipo_access": isPreIpoAccess ? 1 : 0,
    "partner_details": partnerDetails.toJson(),
    "partner": partner.toJson(),
    "active_investor": activeInvestor?.toJson(),
  };
}

class SelectInvestorModel {
  String investorName;
  int investorId;
  RxInt quantity;
  RxDouble price;
  RxDouble totalPrice;
  RxBool isMarket;
  TextEditingController? quantityCTRL;
  TextEditingController? priceCTRL;

  SelectInvestorModel({
    this.investorName = '',
    this.investorId = 0,
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

class Partner {
  int id;
  String name;

  Partner({this.id = 0, this.name = ''});

  factory Partner.fromJson(Map<String, dynamic> json) =>
      Partner(id: Parse.toInt(json["id"]), name: Parse.toStrings(json["name"]));

  Map<String, dynamic> toJson() => {"id": id, "name": name};
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
