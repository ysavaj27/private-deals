import 'package:private_deals/src/features/wealth_manager/data/models/sector/sector_model.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

import 'package:private_deals/src/features/wealth_manager/data/models/pre_ipo/company_model.dart';

class PreIPOLandingPageModel {
  PreIPOLandingPageModel({
    required this.all,
    required this.exclusiveDeals,
    this.hotDeals = const [],
    required this.liquidStocks,
    required this.drhp,
    required this.trending,
    required this.topGainers,
    required this.topLosers,
  });

  final List<CompanyModel> all;
  final List<CompanyModel> exclusiveDeals;
  final List<CompanyModel> hotDeals;
  final List<CompanyModel> liquidStocks;
  final List<CompanyModel> drhp;
  final List<CompanyModel> trending;
  final List<Top> topGainers;
  final List<Top> topLosers;

  PreIPOLandingPageModel copyWith({
    List<CompanyModel> all = const [],
    List<CompanyModel> exclusiveDeals = const [],
    List<CompanyModel>? hotDeals,
    List<CompanyModel> liquidStocks = const [],
    List<CompanyModel> drhp = const [],
    List<CompanyModel> trending = const [],
    List<Top> topGainers = const [],
    List<Top> topLosers = const [],
  }) {
    return PreIPOLandingPageModel(
      all: all,
      exclusiveDeals: exclusiveDeals,
      hotDeals: hotDeals ?? this.hotDeals,
      liquidStocks: liquidStocks,
      drhp: drhp,
      trending: trending,
      topGainers: topGainers,
      topLosers: topLosers,
    );
  }

  factory PreIPOLandingPageModel.fromJson(Map<String, dynamic> json) {
    return PreIPOLandingPageModel(
      all: json["all"] == null
          ? []
          : List<CompanyModel>.from(
              json["all"].map((x) => CompanyModel.fromJson(x))),
      hotDeals: (json['hot_deals'] as List? ?? [])
          .map((e) => CompanyModel.fromJson(e))
          .toList(),
      exclusiveDeals: json['exclusive_deals'] != null
          ? (json['exclusive_deals'] as List)
              .map((e) => CompanyModel.fromJson(e))
              .toList()
          : [],
      liquidStocks: json["liquid_stocks"] == null
          ? []
          : List<CompanyModel>.from(
              json["liquid_stocks"].map((x) => CompanyModel.fromJson(x)),
            ),
      drhp: json["drhp"] == null
          ? []
          : List<CompanyModel>.from(
              json["drhp"].map((x) => CompanyModel.fromJson(x)),
            ),
      trending: json["trending"] == null
          ? []
          : List<CompanyModel>.from(
              json["trending"].map((x) => CompanyModel.fromJson(x)),
            ),
      topGainers: json["top_gainers"] == null
          ? []
          : List<Top>.from(json["top_gainers"].map((x) => Top.fromJson(x))),
      topLosers: json["top_losers"] == null
          ? []
          : List<Top>.from(json["top_losers"].map((x) => Top.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "all": all.map((x) => x.toJson()).toList(),
        "exclusive_deals": exclusiveDeals.map((x) => x.toJson()).toList(),
        "hot_deals": hotDeals.map((x) => x.toJson()).toList(),
        "liquid_stocks": liquidStocks.map((x) => x.toJson()).toList(),
        "drhp": drhp.map((x) => x).toList(),
        "trending": trending.map((x) => x.toJson()).toList(),
        "top_gainers": topGainers.map((x) => x.toJson()).toList(),
        "top_losers": topLosers.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$all, $exclusiveDeals, $liquidStocks, $drhp, $trending,  $topGainers, $topLosers, ";
  }
}

class ExclusiveDeal {
  ExclusiveDeal({
    required this.id,
    required this.brandName,
    required this.logo,
    required this.category,
    required this.bgColorCode,
    required this.sharePrice,
    required this.distributerPrice,
    required this.basePrice,
    required this.priceUpdatedToday,
    required this.lastYearSharePrice,
    required this.sharePrices,
    required this.fundamentals,
  });

  final int id;
  final String brandName;
  final String logo;
  final String category;
  final dynamic bgColorCode;
  final double sharePrice;
  final double distributerPrice;
  final double basePrice;
  final int priceUpdatedToday;
  final double lastYearSharePrice;
  final List<SharePrice> sharePrices;
  final Fundamentals? fundamentals;

  ExclusiveDeal copyWith({
    int? id,
    String? brandName,
    String? logo,
    String? category,
    CompanyModel? bgColorCode,
    double? sharePrice,
    double? distributerPrice,
    double? basePrice,
    int? priceUpdatedToday,
    double? lastYearSharePrice,
    List<SharePrice>? sharePrices,
    Fundamentals? fundamentals,
  }) {
    return ExclusiveDeal(
      id: id ?? this.id,
      brandName: brandName ?? this.brandName,
      logo: logo ?? this.logo,
      category: category ?? this.category,
      bgColorCode: bgColorCode ?? this.bgColorCode,
      sharePrice: sharePrice ?? this.sharePrice,
      distributerPrice: distributerPrice ?? this.distributerPrice,
      basePrice: basePrice ?? this.basePrice,
      priceUpdatedToday: priceUpdatedToday ?? this.priceUpdatedToday,
      lastYearSharePrice: lastYearSharePrice ?? this.lastYearSharePrice,
      sharePrices: sharePrices ?? this.sharePrices,
      fundamentals: fundamentals ?? this.fundamentals,
    );
  }

  factory ExclusiveDeal.fromJson(Map<String, dynamic> json) {
    return ExclusiveDeal(
      id: json["id"] ?? 0,
      brandName: json["brand_name"] ?? "",
      logo: json["logo"] ?? "",
      category: json["category"] ?? "",
      bgColorCode: json["bg_color_code"],
      sharePrice: json["share_price"] ?? 0.0,
      distributerPrice: json["distributer_price"] ?? 0.0,
      basePrice: json["base_price"] ?? 0.0,
      priceUpdatedToday: json["price_updated_today"] ?? 0,
      lastYearSharePrice: json["last_year_share_price"] ?? 0.0,
      sharePrices: json["share_prices"] == null
          ? []
          : List<SharePrice>.from(
              json["share_prices"]!.map((x) => SharePrice.fromJson(x)),
            ),
      fundamentals: json["fundamentals"] == null
          ? null
          : Fundamentals.fromJson(json["fundamentals"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "brand_name": brandName,
        "logo": logo,
        "category": category,
        "bg_color_code": bgColorCode,
        "share_price": sharePrice,
        "distributer_price": distributerPrice,
        "base_price": basePrice,
        "price_updated_today": priceUpdatedToday,
        "last_year_share_price": lastYearSharePrice,
        "share_prices": sharePrices.map((x) => x.toJson()).toList(),
        "fundamentals": fundamentals?.toJson(),
      };

  @override
  String toString() {
    return "$id, $brandName, $logo, $category, $bgColorCode, $sharePrice, $distributerPrice, $basePrice, $priceUpdatedToday, $lastYearSharePrice, $sharePrices, $fundamentals, ";
  }
}

class Fundamentals {
  Fundamentals({
    required this.lotSize,
    required this.fiftyTwoWeekHigh,
    required this.fiftyTwoWeekLow,
  });

  final int lotSize;
  final double fiftyTwoWeekHigh;
  final double fiftyTwoWeekLow;

  Fundamentals copyWith({
    int? lotSize,
    double? fiftyTwoWeekHigh,
    double? fiftyTwoWeekLow,
  }) {
    return Fundamentals(
      lotSize: lotSize ?? this.lotSize,
      fiftyTwoWeekHigh: fiftyTwoWeekHigh ?? this.fiftyTwoWeekHigh,
      fiftyTwoWeekLow: fiftyTwoWeekLow ?? this.fiftyTwoWeekLow,
    );
  }

  factory Fundamentals.fromJson(Map<String, dynamic> json) {
    return Fundamentals(
      lotSize: json["lot_size"] ?? 0,
      fiftyTwoWeekHigh: json["fifty_two_week_high"] ?? 0.0,
      fiftyTwoWeekLow: json["fifty_two_week_low"] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        "lot_size": lotSize,
        "fifty_two_week_high": fiftyTwoWeekHigh,
        "fifty_two_week_low": fiftyTwoWeekLow,
      };

  @override
  String toString() {
    return "$lotSize, $fiftyTwoWeekHigh, $fiftyTwoWeekLow, ";
  }
}

class SharePrice {
  SharePrice({required this.price, required this.date});

  final double price;
  final DateTime? date;

  SharePrice copyWith({double? price, DateTime? date}) {
    return SharePrice(price: price ?? this.price, date: date ?? this.date);
  }

  factory SharePrice.fromJson(Map<String, dynamic> json) {
    return SharePrice(
      price: json["price"] ?? 0.0,
      date: DateTime.tryParse(json["date"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
        "price": price,
        "date": date?.toIso8601String(),
      };

  @override
  String toString() {
    return "$price, $date, ";
  }
}

class RecentlyViewedStock {
  RecentlyViewedStock({
    required this.companyId,
    required this.logo,
    required this.viewedAt,
  });

  final int companyId;
  final String logo;
  final DateTime? viewedAt;

  RecentlyViewedStock copyWith({
    int? companyId,
    String? logo,
    DateTime? viewedAt,
  }) {
    return RecentlyViewedStock(
      companyId: companyId ?? this.companyId,
      logo: logo ?? this.logo,
      viewedAt: viewedAt ?? this.viewedAt,
    );
  }

  factory RecentlyViewedStock.fromJson(Map<String, dynamic> json) {
    return RecentlyViewedStock(
      companyId: json["company_id"] ?? 0,
      logo: json["logo"] ?? "",
      viewedAt: DateTime.tryParse(json["viewed_at"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
        "company_id": companyId,
        "logo": logo,
        "viewed_at": viewedAt?.toIso8601String(),
      };

  @override
  String toString() {
    return "$companyId, $logo, $viewedAt, ";
  }
}

class Top {
  Top({
    required this.id,
    required this.name,
    required this.logo,
    required this.percentage,
  });

  final int id;
  final String name;
  final String logo;
  final String percentage;

  Top copyWith({int? id, String? name, String? logo, String? percentage}) {
    return Top(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      percentage: percentage ?? this.percentage,
    );
  }

  factory Top.fromJson(Map<String, dynamic> json) {
    return Top(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      percentage: Parse.toStrings(json["percentage"]),
      logo: Parse.parseUrl(json["logo"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "logo": logo,
        "percentage": percentage,
      };

  @override
  String toString() {
    return "$id, $name, $logo, $percentage";
  }
}

class PreIPONewsSectorModel {
  PreIPONewsSectorModel({
    required this.news,
    required this.sectors,
  });

  final List<NewsModel> news;
  final List<SectorModel> sectors;

  PreIPONewsSectorModel copyWith({
    List<NewsModel> news = const [],
    List<SectorModel> sectors = const [],
  }) {
    return PreIPONewsSectorModel(news: news, sectors: sectors);
  }

  factory PreIPONewsSectorModel.fromJson(Map<String, dynamic> json) {
    return PreIPONewsSectorModel(
      news: json["news"] == null
          ? []
          : List<NewsModel>.from(
              json["news"].map((x) => NewsModel.fromJson(x)),
            ),
      sectors: json["sectors"] == null
          ? []
          : List<SectorModel>.from(
              json["sectors"].map((x) => SectorModel.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
        "news": news,
        "sectors": sectors,
      };

  @override
  String toString() {
    return "$news, $sectors,";
  }
}

class SecondaryLandingPageModel {
  final List<CompanyModel> all;
  final List<NewsModel> news;
  final List<SectorModel> sectors;

  SecondaryLandingPageModel(
      {required this.all, required this.news, required this.sectors});

  SecondaryLandingPageModel copyWith({
    List<CompanyModel> all = const [],
  }) {
    return SecondaryLandingPageModel(all: all, news: news, sectors: sectors);
  }

  factory SecondaryLandingPageModel.fromJson(Map<String, dynamic> json) {
    return SecondaryLandingPageModel(
      all: json["all"] == null
          ? []
          : List<CompanyModel>.from(
              json["all"].map((x) => CompanyModel.fromJson(x))),
      sectors: json["sectors"] == null
          ? []
          : List<SectorModel>.from(
              json["sectors"].map((x) => SectorModel.fromJson(x)),
            ),
      news: json["news"] == null
          ? []
          : List<NewsModel>.from(
              json["news"].map((x) => NewsModel.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
        "all": all.map((x) => x.toJson()).toList(),
        "news": news.map((x) => x.toJson()).toList(),
        "sectors": sectors.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$all, $news, $sectors";
  }
}
