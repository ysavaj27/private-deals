import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/shared/models/master_type_model.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/sector/sector_model.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/startup/faq_model.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/startup/legal_info_model.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/startup/pitch_model.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/startup/raising_round_model.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/startup/social_media_model.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/startup/team_member_model.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/startup/update_model.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/transaction/sell_request_model.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

import 'package:private_deals/src/features/wealth_manager/data/models/startup/startup_investor_model.dart';

class StartupModel {
  int id;
  String uuid;
  int roundId;
  String urlSlug;
  String brandName;
  int sectorId;
  int cityId;
  String companyName;
  int mobileCountryCode;
  int mobileNumber;
  String email;
  String briefInformation;
  String address;
  int pincode;
  String password;
  double indicativeValuation;
  int isVerifiedMobile;
  int isVerifiedEmail;
  int askPasswordChange;
  int isActive;
  int isBlocked;
  int isDeleted;
  int createdBy;
  int updatedBy;
  DateTime createdAt;
  DateTime updatedAt;
  List<StartupInvestorModel> portfolio;
  bool isFavorite;
  int investorCount;
  double availableShares;
  double minimumShares;
  List<FaqModel> faqs;
  List<SocialMediaModel> socialMediaLinks;
  List<TeamMemberModel> teamMembers;
  MasterTypeModel city;
  MasterTypeModel country;
  MasterTypeModel state;
  List<PitchModel> pitches;
  List<SellRequestModel> market;

  // change
  LegalInfoModel legalInfo;

  /// new
  CmsModel cms;
  SectorModel sector;
  RaisingRoundModel raisingRound;
  List<UpdateModel> updates;

  bool get isEquity =>
      raisingRound.instrument == app.config.enumValues.instrumentType.equity;

  bool get isActiveRound =>
      raisingRound.roundStatus ==
      app.config.enumValues.startupPrimaryRoundStatus.raisingnow;

  StartupModel({
    this.id = 0,
    this.uuid = '',
    this.roundId = 0,
    this.urlSlug = '',
    this.brandName = '',
    this.sectorId = 0,
    this.cityId = 0,
    this.companyName = '',
    this.mobileCountryCode = 0,
    this.mobileNumber = 0,
    this.indicativeValuation = 0.0,
    this.email = '',
    this.briefInformation = '',
    this.address = '',
    this.pincode = 0,
    this.password = '',
    this.isVerifiedMobile = 0,
    this.isVerifiedEmail = 0,
    this.askPasswordChange = 0,
    this.isActive = 0,
    this.isBlocked = 0,
    this.isDeleted = 0,
    this.createdBy = 0,
    this.updatedBy = 0,
    required this.createdAt,
    required this.updatedAt,
    this.portfolio = const [],
    this.isFavorite = false,
    this.investorCount = 0,
    this.availableShares = 0,
    this.minimumShares = 0,
    this.faqs = const [],
    this.socialMediaLinks = const [],
    this.teamMembers = const [],
    required this.city,
    required this.country,
    required this.state,
    this.pitches = const [],
    this.market = const [],
    required this.legalInfo,
    required this.cms,
    required this.sector,
    required this.raisingRound,
    this.updates = const [],
  });

  factory StartupModel.fromJson(Map<String, dynamic> json) {
    return StartupModel(
      id: Parse.toInt(json["id"]),
      uuid: Parse.toStrings(json["uuid"]),
      roundId: Parse.toInt(json["round_id"]),
      urlSlug: Parse.toStrings(json["url_slug"]),
      brandName: Parse.toStrings(json["brand_name"]),
      sectorId: Parse.toInt(json["sector_id"]),
      cityId: Parse.toInt(json["city_id"]),
      companyName: Parse.toStrings(json["company_name"]),
      mobileCountryCode: Parse.toInt(json["mobile_country_code"]),
      mobileNumber: Parse.toInt(json["mobile_number"]),
      indicativeValuation: Parse.toDouble(json["indicative_valuation"]),
      email: Parse.toStrings(json["email"]),
      briefInformation: Parse.toStrings(json["brief_information"]),
      address: Parse.toStrings(json["address"]),
      pincode: Parse.toInt(json["pincode"]),
      password: Parse.toStrings(json["password"]),
      isVerifiedMobile: Parse.toInt(json["is_verified_mobile"]),
      isVerifiedEmail: Parse.toInt(json["is_verified_email"]),
      askPasswordChange: Parse.toInt(json["ask_password_change"]),
      isActive: Parse.toInt(json["is_active"]),
      isBlocked: Parse.toInt(json["is_blocked"]),
      isDeleted: Parse.toInt(json["is_deleted"]),
      createdBy: Parse.toInt(json["created_by"]),
      updatedBy: Parse.toInt(json["updated_by"]),
      createdAt: Parse.toDateTime(json["created_at"]),
      updatedAt: Parse.toDateTime(json["updated_at"]),
      portfolio: (json["portfolio"] as List<dynamic>? ?? [])
          .map((x) => StartupInvestorModel.fromJson(x))
          .toList(),
      isFavorite: Parse.toBool(json["is_favorite"]),
      investorCount: Parse.toInt(json["investor_count"]),
      availableShares: Parse.toDouble(json["available_shares"]),
      minimumShares: Parse.toDouble(json["minimum_shares"]),
      faqs: (json["faqs"] as List<dynamic>? ?? [])
          .map((x) => FaqModel.fromJson(x))
          .toList(),
      socialMediaLinks: (json["social_media_links"] as List<dynamic>? ?? [])
          .map((x) => SocialMediaModel.fromJson(x))
          .toList(),
      teamMembers: (json["team_members"] as List<dynamic>? ?? [])
          .map((x) => TeamMemberModel.fromJson(x))
          .toList(),
      city: MasterTypeModel.fromJson(json["city"] ?? {}),
      country: MasterTypeModel.fromJson(json["country"] ?? {}),
      state: MasterTypeModel.fromJson(json["state"] ?? {}),
      pitches: (json["pitches"] as List<dynamic>? ?? [])
          .map((x) => PitchModel.fromJson(x))
          .toList(),
      market: (json["market"] as List<dynamic>? ?? [])
          .map((x) => SellRequestModel.fromJson(x))
          .toList(),
      legalInfo: LegalInfoModel.fromJson(json["legal_info"] ?? {}),
      cms: CmsModel.fromJson(json["cms"] ?? {}),
      sector: SectorModel.fromJson(json["sector"] ?? {}),
      raisingRound: RaisingRoundModel.fromJson(json["raising_round"] ?? {}),
      updates: (json["updates"] as List<dynamic>? ?? [])
          .map((x) => UpdateModel.fromJson(x))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "uuid": uuid,
        "round_id": roundId,
        "url_slug": urlSlug,
        "brand_name": brandName,
        "sector_id": sectorId,
        "city_id": cityId,
        "company_name": companyName,
        "mobile_country_code": mobileCountryCode,
        "mobile_number": mobileNumber,
        "email": email,
        "brief_information": briefInformation,
        "address": address,
        "pincode": pincode,
        "password": password,
        "is_verified_mobile": isVerifiedMobile,
        "is_verified_email": isVerifiedEmail,
        "ask_password_change": askPasswordChange,
        "indicative_valuation": indicativeValuation,
        "is_active": isActive,
        "is_blocked": isBlocked,
        "is_deleted": isDeleted,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "portfolio": List<dynamic>.from(portfolio.map((x) => x.toJson())),
        "is_favorite": isFavorite,
        "investor_count": investorCount,
        "available_shares": availableShares,
        "minimum_shares": minimumShares,
        "faqs": List<dynamic>.from(faqs.map((x) => x.toJson())),
        "social_media_links":
            List<dynamic>.from(socialMediaLinks.map((x) => x.toJson())),
        "team_members": List<dynamic>.from(teamMembers.map((x) => x.toJson())),
        "city": city.toJson(),
        "country": country.toJson(),
        "state": state.toJson(),
        "pitches": List<dynamic>.from(pitches.map((x) => x.toJson())),
        "market": List<dynamic>.from(market.map((x) => x)),
        "legal_info": legalInfo.toJson(),
        "cms": cms.toJson(),
        "sector": sector.toJson(),
        "raising_round": raisingRound.toJson(),
        "updates": List<dynamic>.from(updates.map((x) => x.toJson())),
      };
}

class CmsModel {
  String logo;
  String banner;
  String longBanner;
  String pitchVideo;
  String pitchDeck;
  String financialProjection;
  String ddReport;
  String dpiitReport;
  String shuruupResearchReport;
  String valuationReport;
  String oneLiner;
  String highlights;
  String website;
  String idea;
  String keyInformation;

  CmsModel({
    this.logo = "",
    this.banner = "",
    this.longBanner = "",
    this.pitchVideo = "",
    this.pitchDeck = "",
    this.financialProjection = "",
    this.ddReport = "",
    this.dpiitReport = "",
    this.shuruupResearchReport = "",
    this.valuationReport = "",
    this.oneLiner = "",
    this.highlights = "",
    this.website = "",
    this.idea = "",
    this.keyInformation = "",
  });

  factory CmsModel.fromJson(Map<String, dynamic> json) => CmsModel(
        logo: Parse.parseUrl(json["logo"]),
        banner: Parse.parseUrl(json["banner"]),
        longBanner: Parse.parseUrl(json["long_banner"]),
        pitchVideo: Parse.parseUrl(json["pitch_video"]),
        pitchDeck: Parse.parseUrl(json["pitch_deck"]),
        financialProjection: Parse.parseUrl(json["financial_projection"]),
        ddReport: Parse.parseUrl(json["dd_report"]),
        dpiitReport: Parse.parseUrl(json["dpiit_report"]),
        shuruupResearchReport: Parse.parseUrl(json["shuruup_research_report"]),
        valuationReport: Parse.parseUrl(json["valuation_report"]),
        oneLiner: Parse.toStrings(json["one_liner"]),
        highlights: Parse.toStrings(json["highlights"]),
        website: Parse.toStrings(json["website"]),
        idea: Parse.toStrings(json["idea"]),
        keyInformation: Parse.toStrings(json["key_information"]),
      );

  Map<String, dynamic> toJson() => {
        "logo": logo,
        "banner": banner,
        "long_banner": longBanner,
        "pitch_video": pitchVideo,
        "pitch_deck": pitchDeck,
        "financial_projection": financialProjection,
        "dd_report": ddReport,
        "dpiit_report": dpiitReport,
        "shuruup_research_report": shuruupResearchReport,
        "valuation_report": valuationReport,
        "one_liner": oneLiner,
        "highlights": highlights,
        "website": website,
        "idea": idea,
        "key_information": keyInformation,
      };
}

class StartupLiteModel {
  int id;
  String brandName;

  StartupLiteModel({
    this.id = 0,
    this.brandName = '',
  });

  factory StartupLiteModel.fromJson(Map<String, dynamic> json) =>
      StartupLiteModel(
        id: Parse.toInt(json["id"]),
        brandName: Parse.toStrings(json["brand_name"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "brand_name": brandName,
      };
}
