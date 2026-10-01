import 'package:private_deals/src/shared/models/master_type_model.dart';
import 'package:private_deals/src/shared/constant/app_assets.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

import 'package:private_deals/src/core/permissions/partner_role.dart';

class PartnerUser {
  PartnerRole get role => PartnerRole.parse(type);
  int? selfInvestorId;
  int id;
  String uuid;
  String type;
  String parentType;
  int parentId;
  String name;
  int mobileCountryCode;
  int mobileNumber;
  String email;
  String address;
  double commission;
  int cityId;
  int stateId;
  int countryId;
  int pincode;
  String gender;
  int isVerifiedMobile;
  int isVerifiedEmail;
  String profilePhoto;
  int askPasswordChange;
  bool isBlocked;
  bool isDeleted;
  bool isDemo;
  int createdBy;
  int updatedBy;
  int totalInvested;
  int noOfStartups;
  int commissionEarned;
  int investorCount;
  List<WStartupList> startupList;
  DateTime createdAt;
  DateTime updatedAt;
  String token;
  MasterTypeModel city;
  bool isPrimaryAccess;
  bool isSecondaryAccess;
  bool isPreIpoAccess;

  PartnerUser({
    this.selfInvestorId,
    this.id = 0,
    this.uuid = '',
    this.type = '',
    this.parentType = '',
    this.parentId = 0,
    this.name = '',
    this.mobileCountryCode = 0,
    this.mobileNumber = 0,
    this.email = '',
    this.address = '',
    this.commission = 0.0,
    this.cityId = 0,
    this.stateId = 0,
    this.countryId = 0,
    this.pincode = 0,
    this.gender = '',
    this.isVerifiedMobile = 0,
    this.isVerifiedEmail = 0,
    this.profilePhoto = '',
    this.askPasswordChange = 0,
    this.isBlocked = false,
    this.isDeleted = false,
    this.isDemo = false,
    this.createdBy = 0,
    this.updatedBy = 0,
    this.totalInvested = 0,
    this.noOfStartups = 0,
    this.commissionEarned = 0,
    this.investorCount = 0,
    this.startupList = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.city,
    this.token = '',
    this.isPrimaryAccess = false,
    this.isSecondaryAccess = false,
    this.isPreIpoAccess = false,
  });

  bool get changePassword => askPasswordChange == 1;

  String get profile => Parse.parseUrl(profilePhoto);

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

  bool get isPreIPOOnly {
    if (isPreIpoAccess && (!isPrimaryAccess && !isSecondaryAccess)) {
      return true;
    } else {
      return false;
    }
  }

  factory PartnerUser.fromJson(Map<String, dynamic> json) => PartnerUser(
    selfInvestorId: int.tryParse(json["self_investor_id"]?.toString() ?? ""),
    id: Parse.toInt(json["id"]),
    uuid: Parse.toStrings(json["uuid"]),
    type: Parse.toStrings(json["type"]),
    parentType: Parse.toStrings(json["parent_type"]),
    parentId: Parse.toInt(json["parent_id"]),
    name: Parse.toStrings(json["name"]),
    mobileCountryCode: Parse.toInt(json["mobile_country_code"]),
    mobileNumber: Parse.toInt(json["mobile_number"]),
    email: Parse.toStrings(json["email"]),
    address: Parse.toStrings(json["address"]),
    commission: Parse.toDouble(json["commission"]),
    cityId: Parse.toInt(json["city_id"]),
    stateId: Parse.toInt(json["state_id"]),
    countryId: Parse.toInt(json["country_id"]),
    pincode: Parse.toInt(json["pincode"]),
    gender: Parse.toStrings(json["gender"]),
    isVerifiedMobile: Parse.toInt(json["is_verified_mobile"]),
    isVerifiedEmail: Parse.toInt(json["is_verified_email"]),
    // Assuming `baseUrl` can be passed as a parameter or left empty
    profilePhoto: Parse.toStrings(json["profile_photo"]),
    askPasswordChange: Parse.toInt(json["ask_password_change"]),
    isBlocked: Parse.toBool(json["is_blocked"]),
    isDeleted: Parse.toBool(json["is_deleted"]),
    isDemo: Parse.toBool(json["is_demo"]),
    createdBy: Parse.toInt(json["created_by"]),
    updatedBy: Parse.toInt(json["updated_by"]),
    totalInvested: Parse.toInt(json["total_invested"]),
    noOfStartups: Parse.toInt(json["no_of_startups"]),
    commissionEarned: Parse.toInt(json["commission_earned"]),
    investorCount: Parse.toInt(json["investor_count"]),
    city: MasterTypeModel.fromJson(json["city"] ?? {}),
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
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "self_investor_id": selfInvestorId,
    "uuid": uuid,
    "type": type,
    "parent_type": parentType,
    "parent_id": parentId,
    "name": name,
    "mobile_country_code": mobileCountryCode,
    "mobile_number": mobileNumber,
    "email": email,
    "address": address,
    "commission": commission,
    "city_id": cityId,
    "state_id": stateId,
    "country_id": countryId,
    "pincode": pincode,
    "gender": gender,
    "is_verified_mobile": isVerifiedMobile,
    "is_verified_email": isVerifiedEmail,
    "profile_photo": profilePhoto,
    "ask_password_change": askPasswordChange,
    "is_blocked": isBlocked,
    "is_deleted": isDeleted,
    "is_demo": isDemo,
    "created_by": createdBy,
    "updated_by": updatedBy,
    "total_invested": totalInvested,
    "no_of_startups": noOfStartups,
    "investor_count": investorCount,
    "commission_earned": commissionEarned,
    "city": city.toJson(),
    "startup_list": List<dynamic>.from(startupList.map((x) => x.toJson())),
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "token": token,
    "is_primary_access": isPrimaryAccess ? 1 : 0,
    "is_secondary_access": isSecondaryAccess ? 1 : 0,
    "is_preipo_access": isPreIpoAccess ? 1 : 0,
  };
}

class WStartupList {
  String brandName;
  double amountInvested;
  double commissionEarned;

  WStartupList({
    this.brandName = "",
    this.amountInvested = 0.0,
    this.commissionEarned = 0.0,
  });

  factory WStartupList.fromJson(Map<String, dynamic> json) => WStartupList(
    brandName: Parse.toStrings(json["brand_name"]),
    amountInvested: Parse.toDouble(json["amount_invested"]),
    commissionEarned: Parse.toDouble(json["commission_earned"]),
  );

  Map<String, dynamic> toJson() => {
    "brand_name": brandName,
    "amount_invested": amountInvested,
    "commission_earned": commissionEarned,
  };
}
