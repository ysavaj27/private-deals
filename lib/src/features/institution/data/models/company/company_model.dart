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
  String about;
  double minInvestmentAmount;
  String alternativeNames;
  String listOrder;
  bool isDrhp;
  String bgColorCode;
  double sharePrice;
  double basePrice;
  double myBasePrice;
  bool priceUpdatedToday;
  double lastYearSharePrice;
  String minInvestmentType;
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
    this.about = "",
    this.minInvestmentAmount = 0.0,
    this.alternativeNames = "",
    this.listOrder = "",
    this.isDrhp = false,
    this.bgColorCode = "",
    this.sharePrice = 0.0,
    this.basePrice = 0.0,
    this.myBasePrice = 0.0,
    this.priceUpdatedToday = false,
    this.lastYearSharePrice = 0.0,
    this.minInvestmentType = "",
    this.isFavorite = false,
    this.isEditable = false,
    this.promoters = const [],
    this.shareHolders = const [],
    SectorModel? sector,
    FundamentalsModel? fundamentals,
  }) : sector = sector ?? SectorModel(),
       fundamentals = fundamentals ?? FundamentalsModel();

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    final fundamentalsMap = <String, dynamic>{
      if (json['fundamentals'] is Map)
        ...Map<String, dynamic>.from(json['fundamentals'] as Map),
    };
    // Detail payloads sometimes put create-form fields at the root.
    const fallbackKeys = [
      'lot_size',
      'market_cap',
      'pe_ratio',
      'pb_ratio',
      'debt_to_equity',
      'roe',
      'book_value',
      'face_value',
      'depository',
      'pan_number',
      'isin_number',
      'rta',
      'total_shares',
      'cin',
      'cin_number',
    ];
    for (final key in fallbackKeys) {
      if (!fundamentalsMap.containsKey(key) && json[key] != null) {
        fundamentalsMap[key] = json[key];
      }
    }
    final fundamentals = FundamentalsModel.fromJson(fundamentalsMap);
    return CompanyModel(
      id: Parse.toInt(json['id']),
      uuid: Parse.toStrings(json['uuid']),
      slug: Parse.toStrings(json['slug']),
      brandName: Parse.toStrings(json['brand_name']),
      companyName: Parse.toStrings(json['company_name']),
      logo: Parse.parseUrl(json['logo']),
      category: Parse.toStrings(json['category']),
      type: Parse.toStrings(json['type']),
      cin: Parse.toStrings(json['cin']).isNotEmpty
          ? Parse.toStrings(json['cin'])
          : fundamentals.cinNumber,
      about: Parse.toStrings(json['about']),
      minInvestmentAmount: Parse.toDouble(
        json['min_investment_amount'] ?? json['min_investment'],
      ),
      alternativeNames: Parse.toStrings(json['alternative_names']),
      listOrder: Parse.toStrings(json['list_order']),
      isDrhp: Parse.toBool(json['is_drhp']),
      bgColorCode: Parse.toStrings(json['bg_color_code']),
      sharePrice: Parse.toDouble(json['share_price']),
      basePrice: Parse.toDouble(json['base_price']),
      myBasePrice: Parse.toDouble(json['my_base_price']),
      priceUpdatedToday: Parse.toBool(json['price_updated_today']),
      lastYearSharePrice: Parse.toDouble(json['last_year_share_price']),
      minInvestmentType: Parse.toStrings(json['min_investment_type']),
      isFavorite: Parse.toBool(json['is_favorite']),
      isEditable: _parseEditableFlag(json['is_editable']),
      shareHolders: (json['share_holders'] as List? ?? [])
          .map((e) => ShareholderYearModel.fromJson(e))
          .toList(),
      sector: SectorModel.fromJson(json['sector']),
      fundamentals: fundamentals,
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
      "about": about,
      "min_investment_amount": minInvestmentAmount,
      "alternative_names": alternativeNames,
      "list_order": listOrder,
      "is_drhp": isDrhp,
      "bg_color_code": bgColorCode,
      "share_price": sharePrice,
      "base_price": basePrice,
      "my_base_price": myBasePrice,
      "price_updated_today": priceUpdatedToday,
      "last_year_share_price": lastYearSharePrice,
      "min_investment_type": minInvestmentType,
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

  /// Accepts bool, 0/1, and common string forms from list/detail payloads.
  static bool _parseEditableFlag(dynamic value) {
    if (value == true || value == 1) return true;
    if (value == false || value == 0 || value == null) return false;
    final text = value.toString().trim().toLowerCase();
    return text == '1' || text == 'true' || text == 'yes';
  }
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
  String panNumber;
  String isinNumber;
  String cinNumber;
  String rta;
  double marketCap;
  double peRatio;
  double pbRatio;
  double debtToEquity;
  double roe;
  double bookValue;
  double faceValue;
  int totalShares;

  FundamentalsModel({
    this.lotSize = 0.0,
    this.fiftyTwoWeekHigh = 0.0,
    this.fiftyTwoWeekLow = 0.0,
    this.depository = "",
    this.panNumber = "",
    this.isinNumber = "",
    this.cinNumber = "",
    this.rta = "",
    this.marketCap = 0.0,
    this.peRatio = 0.0,
    this.pbRatio = 0.0,
    this.debtToEquity = 0.0,
    this.roe = 0.0,
    this.bookValue = 0.0,
    this.faceValue = 0.0,
    this.totalShares = 0,
  });

  factory FundamentalsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return FundamentalsModel();

    return FundamentalsModel(
      lotSize: Parse.toDouble(json['lot_size']),
      fiftyTwoWeekHigh: Parse.toDouble(json['fifty_two_week_high']),
      fiftyTwoWeekLow: Parse.toDouble(json['fifty_two_week_low']),
      depository: Parse.toStrings(json['depository']),
      panNumber: Parse.toStrings(json['pan_number']),
      isinNumber: Parse.toStrings(json['isin_number']),
      cinNumber: Parse.toStrings(json['cin_number'] ?? json['cin']),
      rta: Parse.toStrings(json['rta']),
      marketCap: Parse.toDouble(json['market_cap']),
      peRatio: Parse.toDouble(json['pe_ratio']),
      pbRatio: Parse.toDouble(json['pb_ratio']),
      debtToEquity: Parse.toDouble(json['debt_to_equity']),
      roe: Parse.toDouble(json['roe']),
      bookValue: Parse.toDouble(json['book_value']),
      faceValue: Parse.toDouble(json['face_value']),
      totalShares: Parse.toInt(json['total_shares']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "lot_size": lotSize,
      "fifty_two_week_high": fiftyTwoWeekHigh,
      "fifty_two_week_low": fiftyTwoWeekLow,
      "depository": depository,
      "pan_number": panNumber,
      "isin_number": isinNumber,
      "cin_number": cinNumber,
      "rta": rta,
      "market_cap": marketCap,
      "pe_ratio": peRatio,
      "pb_ratio": pbRatio,
      "debt_to_equity": debtToEquity,
      "roe": roe,
      "book_value": bookValue,
      "face_value": faceValue,
      "total_shares": totalShares,
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

class CompanyEventModel {
  int id;
  DateTime date;
  String title;
  String description;
  String file;
  String fileUrl;

  CompanyEventModel({
    this.id = 0,
    DateTime? date,
    this.title = '',
    this.description = '',
    this.file = '',
    this.fileUrl = '',
  }) : date = date ?? DateTime.now();

  factory CompanyEventModel.fromJson(Map<String, dynamic> json) {
    final fileUrl = Parse.parseUrl(json['file_url'] ?? json['file']);
    return CompanyEventModel(
      id: Parse.toInt(json['id']),
      date: _parseEventDate(json['date']),
      title: Parse.toStrings(json['title']),
      description: Parse.toStrings(json['description']),
      file: Parse.toStrings(json['file']),
      fileUrl: fileUrl,
    );
  }

  /// Institution events use PHP `d-m-Y`; ISO strings are also accepted.
  static DateTime _parseEventDate(dynamic raw) {
    final text = Parse.toStrings(raw).trim();
    if (text.isEmpty) return DateTime(0);

    final parts = text.split(RegExp(r'[/-]'));
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null &&
          month != null &&
          year != null &&
          day >= 1 &&
          day <= 31 &&
          month >= 1 &&
          month <= 12) {
        return DateTime(year, month, day);
      }
    }

    return Parse.toDateTime(raw);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'title': title,
    'description': description,
    'file': file,
    'file_url': fileUrl,
  };

  String get downloadUrl => fileUrl.isNotEmpty ? fileUrl : file;
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
