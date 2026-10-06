import 'package:private_deals/src/features/institution/support/functions/parse.dart';

class CompanyModel {
  int id;
  String uuid;
  String slug;
  String brandName;
  String companyName;
  String logo;
  String category;
  String type;
  String cin;
  bool isDrhp;
  String bgColorCode;
  double sharePrice;
  double distributerPrice;
  double basePrice;
  double myBasePrice;
  bool priceUpdatedToday;
  double lastYearSharePrice;
  bool isTrending;
  bool isGrabOpportunityEnabled;
  String minInvestmentType;
  double minInvestmentAmount;
  bool isFavorite;
  bool isEditable;
  SectorModel sector;
  FundamentalsModel fundamentals;
  List<PromoterModel> promoters;
  List<ShareholderYearModel> shareHolders;

  CompanyModel({
    this.id = 0,
    this.uuid = "",
    this.slug = "",
    this.brandName = "",
    this.companyName = "",
    this.logo = "",
    this.category = "",
    this.type = "",
    this.cin = "",
    this.isDrhp = false,
    this.bgColorCode = "",
    this.sharePrice = 0.0,
    this.distributerPrice = 0.0,
    this.basePrice = 0.0,
    this.myBasePrice = 0.0,
    this.priceUpdatedToday = false,
    this.lastYearSharePrice = 0.0,
    this.isTrending = false,
    this.isGrabOpportunityEnabled = false,
    this.minInvestmentType = "",
    this.minInvestmentAmount = 0.0,
    this.isFavorite = false,
    this.isEditable = false,
    this.promoters = const [],
    this.shareHolders = const [],
    SectorModel? sector,
    FundamentalsModel? fundamentals,
  }) : sector = sector ?? SectorModel(),
       fundamentals = fundamentals ?? FundamentalsModel();

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: Parse.toInt(json['id']),
      uuid: Parse.toStrings(json['uuid']),
      slug: Parse.toStrings(json['slug']),
      brandName: Parse.toStrings(json['brand_name']),
      companyName: Parse.toStrings(json['company_name']),
      logo: Parse.parseUrl(json['logo']),
      category: Parse.toStrings(json['category']),
      type: Parse.toStrings(json['type']),
      cin: Parse.toStrings(json['cin']),
      isDrhp: Parse.toBool(json['is_drhp']),
      bgColorCode: Parse.toStrings(json['bg_color_code']),
      sharePrice: Parse.toDouble(json['share_price']),
      distributerPrice: Parse.toDouble(json['distributer_price']),
      basePrice: Parse.toDouble(json['base_price']),
      myBasePrice: Parse.toDouble(json['my_base_price']),
      priceUpdatedToday: Parse.toBool(json['price_updated_today']),
      lastYearSharePrice: Parse.toDouble(json['last_year_share_price']),
      isTrending: Parse.toBool(json['is_trending']),
      isGrabOpportunityEnabled: Parse.toBool(
        json['is_grab_opportunity_enabled'],
      ),
      minInvestmentType: Parse.toStrings(json['min_investment_type']),
      minInvestmentAmount: Parse.toDouble(json['min_investment_amount']),
      isFavorite: Parse.toBool(json['is_favorite']),
      isEditable: Parse.toBool(json['is_editable']),
      shareHolders: (json['share_holders'] as List? ?? [])
          .map((e) => ShareholderYearModel.fromJson(e))
          .toList(),
      sector: SectorModel.fromJson(json['sector']),
      fundamentals: FundamentalsModel.fromJson(json['fundamentals']),
      promoters: json['promoters'] != null
          ? (json['promoters'] as List)
                .map((e) => PromoterModel.fromJson(e))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "uuid": uuid,
      "slug": slug,
      "brand_name": brandName,
      "company_name": companyName,
      "logo": logo,
      "category": category,
      "type": type,
      "cin": cin,
      "is_drhp": isDrhp,
      "bg_color_code": bgColorCode,
      "share_price": sharePrice,
      "distributer_price": distributerPrice,
      "base_price": basePrice,
      "my_base_price": myBasePrice,
      "price_updated_today": priceUpdatedToday,
      "last_year_share_price": lastYearSharePrice,
      "is_trending": isTrending,
      "is_grab_opportunity_enabled": isGrabOpportunityEnabled,
      "min_investment_type": minInvestmentType,
      "min_investment_amount": minInvestmentAmount,
      "is_favorite": isFavorite,
      "is_editable": isEditable,
      "share_holders": shareHolders.map((e) => e.toJson()).toList(),
      "sector": sector.toJson(),
      "fundamentals": fundamentals.toJson(),
      "promoters": List<dynamic>.from(promoters.map((x) => x.toJson())),
    };
  }

  /// Institution unlisted list only: today's uploaded base price, not catalog
  /// [sharePrice]. Zero means no upload today.
  String get myBasePriceLabel => myBasePrice > 0
      ? '₹${myBasePrice.toStringAsFixed(2)}'
      : 'Price Upload Pending';
}

class SectorModel {
  int id;
  String name;
  String urlSlug;
  String slug;

  SectorModel({this.id = 0, this.name = "", this.urlSlug = "", this.slug = ""});

  factory SectorModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SectorModel();

    return SectorModel(
      id: Parse.toInt(json['id']),
      name: Parse.toStrings(json['name']),
      urlSlug: Parse.toStrings(json['url_slug']),
      slug: Parse.toStrings(json['slug']),
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "url_slug": urlSlug, "slug": slug};
  }
}

class FundamentalsModel {
  double lotSize;
  double fiftyTwoWeekHigh;
  double fiftyTwoWeekLow;
  String depository;

  FundamentalsModel({
    this.lotSize = 0.0,
    this.fiftyTwoWeekHigh = 0.0,
    this.fiftyTwoWeekLow = 0.0,
    this.depository = "",
  });

  factory FundamentalsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return FundamentalsModel();

    return FundamentalsModel(
      lotSize: Parse.toDouble(json['lot_size']),
      fiftyTwoWeekHigh: Parse.toDouble(json['fifty_two_week_high']),
      fiftyTwoWeekLow: Parse.toDouble(json['fifty_two_week_low']),
      depository: Parse.toStrings(json['depository']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "lot_size": lotSize,
      "fifty_two_week_high": fiftyTwoWeekHigh,
      "fifty_two_week_low": fiftyTwoWeekLow,
      "depository": depository,
    };
  }
}

class CompanyDuplicateModel {
  bool isDuplicate;
  List<String> matches;

  CompanyDuplicateModel({this.isDuplicate = false, this.matches = const []});

  factory CompanyDuplicateModel.fromJson(Map<String, dynamic> json) {
    return CompanyDuplicateModel(
      isDuplicate: Parse.toBool(json['is_duplicate']),
      matches: (json['matches'] as List? ?? []).map((item) {
        final match = Map<String, dynamic>.from(item as Map);
        final company = Map<String, dynamic>.from(match['company'] as Map);

        return '${company['company_name']}'
            ' — matching ${match['match_on']}';
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "is_duplicate": isDuplicate,
      "matches": matches.map((e) => e.toString()).toList(),
    };
  }
}

class PromoterModel {
  String name;
  String designation;
  String experience;
  String url;

  PromoterModel({
    this.name = '',
    this.designation = '',
    this.experience = '',
    this.url = '',
  });

  factory PromoterModel.fromJson(Map<String, dynamic> json) {
    return PromoterModel(
      name: Parse.toStrings(json['name']), // Added parsing for name
      designation: Parse.toStrings(json['designation']),
      experience: Parse.toStrings(json['experience']),
      url: Parse.toStrings(json['url']),
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "designation": designation,
    "experience": experience,
    "url": url,
  };
}

class ShareholderYearModel {
  final String year;
  final List<ShareholderModel> shareholders;

  ShareholderYearModel({this.year = '', this.shareholders = const []});

  factory ShareholderYearModel.fromJson(Map<String, dynamic> json) =>
      ShareholderYearModel(
        year: Parse.toStrings(json['year']),
        shareholders: (json['shareholders'] as List? ?? [])
            .map((e) => ShareholderModel.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'year': year,
    'shareholders': shareholders.map((e) => e.toJson()).toList(),
  };
}

class ShareholderModel {
  final String name;
  final double percentage;

  ShareholderModel({this.name = '', this.percentage = 0});

  factory ShareholderModel.fromJson(Map<String, dynamic> json) =>
      ShareholderModel(
        name: Parse.toStrings(json['name']),
        percentage: Parse.toDouble(json['percentage']),
      );

  Map<String, dynamic> toJson() => {'name': name, 'percentage': percentage};
}
