import 'dart:convert';

import 'package:private_deals/src/shared/functions/parse.dart';

import 'package:private_deals/src/shared/app_exports.dart';

class CompanyModel {
  int id;
  String logo;
  String uuid;
  String slug;
  String sector;
  bool isDrhp;
  bool priceUpdatedToday;
  String brandName;
  String category;
  String companyName;
  String about;
  List<ShareHolderYearModel> shareHolders;
  double sharePrice;
  double distributerPrice;
  double basePrice;
  String minInvestmentType;
  double minInvestment;
  List<CustomDataModel> customData;
  List<SharePriceModel> sharePrices;
  FundamentalsModel fundamentals;
  PreIPOTransactionModel transaction;
  List<PromoterModel> promoters;
  List<EventModel> events;
  List<PeerRatioModel> peerRatios;
  List<NewsModel> news;
  List<DealModel> deals;
  List<SellerSharePriceModel> sellerSharePrices;

  String get buttonText {
    if (transaction.id != 0 && transaction.status == 0) {
      return 'Processing';
    } else if (transaction.id != 0 && transaction.status != 0) {
      return 'Completed';
    } else {
      return "Buy";
    }
  }

  String get headingText {
    if (isDrhp) return "DRHP Filed";
    if (category == "Listed") return category;
    return "";
  }

  bool get canBuy =>
      category != app.config.enumValues.preIpoCategory.listed && id.isNotEmpty;

  bool get transactionEnable => transaction.id == 0 ? true : false;

  double get initialPrice => sharePrices.isNotEmpty && sharePrices.length >= 2
      ? sharePrices.last.price
      : 0;

  double get profitLossValue => sharePrice - initialPrice;

  double get percentageChange => (profitLossValue / initialPrice) * 100;

  Color get resultColor => profitLossValue > 0 ? Colors.green : Colors.red;

  String get profitLossString {
    if (initialPrice > 0) {
      if (profitLossValue > 0) {
        return "(+${profitLossValue.toStringAsFixed(2)}) (+${percentageChange.toStringAsFixed(2)}%)";
      } else if (profitLossValue < 0) {
        return "(${profitLossValue.toStringAsFixed(2)}) (${percentageChange.toStringAsFixed(2)}%)";
      }
    }
    return "";
  }

  CompanyModel({
    this.id = 0,
    this.logo = "",
    this.slug = "",
    this.uuid = "",
    this.sector = "",
    this.category = "",
    this.brandName = "",
    this.companyName = "",
    this.about = "",
    this.isDrhp = false,
    this.priceUpdatedToday = false,
    this.shareHolders = const [],
    this.sharePrice = 0,
    this.distributerPrice = 0,
    this.basePrice = 0,
    this.customData = const [],
    this.sharePrices = const [],
    required this.fundamentals,
    required this.transaction,
    this.promoters = const [],
    this.events = const [],
    this.peerRatios = const [],
    this.news = const [],
    this.deals = const [],
    this.sellerSharePrices = const [],
    this.minInvestmentType = "",
    this.minInvestment = 0.0,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: Parse.toInt(json["id"]),
      logo: Parse.parseUrl(json['logo']),
      sector: Parse.toStrings(json["sector"]),
      slug: Parse.toStrings(json["slug"]),
      uuid: Parse.toStrings(json["uuid"]),
      category: Parse.toStrings(json["category"]),
      isDrhp: Parse.toBool(json["is_drhp"]),
      brandName: Parse.toStrings(json["brand_name"]),
      companyName: Parse.toStrings(json["company_name"]),
      about: Parse.toStrings(json["about"]),
      shareHolders: json['share_holders'] != null
          ? (json['share_holders'] as List)
              .map((e) => ShareHolderYearModel.fromJson(e))
              .toList()
          : [],
      sharePrice: Parse.toDouble(json['share_price']),
      distributerPrice: Parse.toDouble(json['distributer_price']),
      basePrice: Parse.toDouble(json['base_price']),
      minInvestment: Parse.toDouble(json['min_investment_amount']),
      minInvestmentType: Parse.toStrings(json["min_investment_type"]),
      customData: json['custom_data'] != null
          ? (json['custom_data'] as List)
              .map((e) => CustomDataModel.fromJson(e))
              .toList()
          : [],
      sharePrices: json['share_prices'] != null
          ? (json['share_prices'] as List)
              .map((e) => SharePriceModel.fromJson(e))
              .toList()
          : [],
      fundamentals: FundamentalsModel.fromJson(json['fundamentals'] ?? {}),
      transaction: PreIPOTransactionModel.fromJson(json['transaction'] ?? {}),
      promoters: json['promoters'] != null
          ? (json['promoters'] as List)
              .map((e) => PromoterModel.fromJson(e))
              .toList()
          : [],
      events: json['events'] != null
          ? (json['events'] as List).map((e) => EventModel.fromJson(e)).toList()
          : [],
      peerRatios: json['peerratio'] != null
          ? (json['peerratio'] as List)
              .map((e) => PeerRatioModel.fromJson(e))
              .toList()
          : [],
      deals: json['deals'] != null
          ? (json['deals'] as List).map((e) => DealModel.fromJson(e)).toList()
          : [],
      sellerSharePrices: (json['seller_share_prices'] as List? ?? [])
          .map((e) => SellerSharePriceModel.fromJson(e))
          .toList(),
      news: json['news'] != null
          ? (json['news'] as List).map((e) => NewsModel.fromJson(e)).toList()
          : [],
      priceUpdatedToday: Parse.toBool(json["price_updated_today"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "logo": logo,
        "brand_name": brandName,
        "uuid": uuid,
        "slug": slug,
        "sector": sector,
        "category": category,
        "is_drhp": isDrhp,
        "company_name": companyName,
        "min_investment_type": minInvestmentType,
        "min_investment_amount": minInvestment,
        "about": about,
        "share_holders":
            List<dynamic>.from(shareHolders.map((x) => x.toJson())),
        "share_price": sharePrice,
        "distributer_price": distributerPrice,
        "base_price": basePrice,
        "transaction": transaction.toJson(),
        "custom_data": List<dynamic>.from(customData.map((x) => x.toJson())),
        "share_prices": List<dynamic>.from(sharePrices.map((x) => x.toJson())),
        "fundamentals": fundamentals.toJson(),
        "promoters": List<dynamic>.from(promoters.map((x) => x.toJson())),
        "events": List<dynamic>.from(events.map((x) => x.toJson())),
        "news": List<dynamic>.from(news.map((x) => x.toJson())),
        "deals": List<dynamic>.from(deals.map((x) => x.toJson())),
        "seller_share_prices":
            sellerSharePrices.map((e) => e.toJson()).toList(),
        "peerratio": List<dynamic>.from(peerRatios.map((x) => x.toJson())),
        "price_updated_today": priceUpdatedToday,
      };
}

class ShareHolderYearModel {
  int year;
  List<ShareHolderModel> shareholders;

  ShareHolderYearModel({
    required this.year,
    required this.shareholders,
  });

  factory ShareHolderYearModel.fromJson(Map<String, dynamic> json) {
    return ShareHolderYearModel(
      year: Parse.toInt(json['year']),
      shareholders: json['shareholders'] != null
          ? (json['shareholders'] as List)
              .map((e) => ShareHolderModel.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        "year": year,
        "shareholders": List<dynamic>.from(shareholders.map((x) => x.toJson())),
      };
}

class ShareHolderModel {
  String name;
  double percentage;

  ShareHolderModel({
    this.name = '',
    this.percentage = 0.0,
  });

  factory ShareHolderModel.fromJson(Map<String, dynamic> json) {
    return ShareHolderModel(
      name: Parse.toStrings(json['name']),
      percentage: Parse.toDouble(json['percentage']),
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "percentage": percentage,
      };
}

class CustomDataModel {
  String label;
  List<List<dynamic>> values;

  CustomDataModel({
    this.label = "",
    this.values = const [],
  });

  bool get isData => values.isNotEmpty && values.length >= 2;

  factory CustomDataModel.fromJson(Map<String, dynamic> json) {
    return CustomDataModel(
      label: Parse.toStrings(json['label']),
      values: json['values'] != null
          ? List<List<dynamic>>.from(jsonDecode(json['values']) ?? [])
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        "label": label,
        "values": values,
      };
}

class SharePriceModel {
  DateTime date;
  double price;
  double distributerPrice;

  SharePriceModel({
    required this.date,
    this.price = 0,
    this.distributerPrice = 0,
  });

  factory SharePriceModel.fromJson(Map<String, dynamic> json) {
    return SharePriceModel(
      date: Parse.toDateTime(json['date']),
      price: Parse.toDouble(json['price']),
      distributerPrice: Parse.toDouble(json['distributer_price']),
    );
  }

  Map<String, dynamic> toJson() => {
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "price": price,
        "distributer_price": distributerPrice,
      };
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

class EventModel {
  DateTime date;
  String title;
  String description;
  String file;

  EventModel({
    required this.date,
    this.title = '',
    this.description = '',
    this.file = '',
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      date: Parse.toDateTime(json['date']),
      title: Parse.toStrings(json['title']),
      description: Parse.toStrings(json['description']),
      file: Parse.parseUrl(json['file']),
    );
  }

  Map<String, dynamic> toJson() => {
        "date": date.toIso8601String(),
        "title": title,
        "description": description,
        "file": file,
      };
}

class PeerRatioModel {
  String perticular;
  double revenue;
  double eps;
  double marketCap;
  String pe;

  PeerRatioModel({
    this.perticular = '',
    this.revenue = 0,
    this.eps = 0,
    this.marketCap = 0,
    this.pe = '',
  });

  // Factory constructor to create a PeerRatioModel from JSON
  factory PeerRatioModel.fromJson(Map<String, dynamic> json) {
    return PeerRatioModel(
      perticular: Parse.toStrings(json['perticular']),
      revenue: Parse.toDouble(json['revenue']),
      eps: Parse.toDouble(json['eps']),
      marketCap: Parse.toDouble(json['market_cap']),
      pe: Parse.toStrings(json['pe']),
    );
  }

  // Method to convert PeerRatioModel to JSON
  Map<String, dynamic> toJson() => {
        "perticular": perticular,
        "revenue": revenue,
        "eps": eps,
        "market_cap": marketCap,
        "pe": pe,
      };
}

class NewsModel {
  String image;
  String title;
  String description;
  String platformName;
  String link;
  DateTime createdAt;

  NewsModel({
    this.image = "",
    this.title = "",
    this.description = "",
    this.platformName = "",
    this.link = "",
    required this.createdAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(
        image: Parse.parseUrl(json["image"]),
        title: Parse.toStrings(json["title"]),
        platformName: Parse.toStrings(json["platform_name"]),
        description: Parse.toStrings(json["description"]),
        link: Parse.toStrings(json["link"]),
        createdAt: Parse.toDateTime(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "title": title,
        "platform_namee": platformName,
        "description": description,
        "link": link,
        "created_at": createdAt.toIso8601String(),
      };
}

class FundamentalsModel {
  int lotSize;
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
    this.lotSize = 0,
    this.fiftyTwoWeekHigh = 0,
    this.fiftyTwoWeekLow = 0,
    this.depository = '',
    this.panNumber = '',
    this.isinNumber = '',
    this.cinNumber = '',
    this.rta = 'N/A',
    this.marketCap = 0,
    this.peRatio = 0.0,
    this.pbRatio = 0.0,
    this.debtToEquity = 0,
    this.roe = 0.0,
    this.bookValue = 0.0,
    this.faceValue = 0,
    this.totalShares = 0,
  });

  factory FundamentalsModel.fromJson(Map<String, dynamic> json) {
    return FundamentalsModel(
      lotSize: Parse.toInt(json['lot_size']),
      fiftyTwoWeekHigh: Parse.toDouble(json['fifty_two_week_high']),
      fiftyTwoWeekLow: Parse.toDouble(json['fifty_two_week_low']),
      depository: Parse.toStrings(json['depository']),
      panNumber: Parse.toStrings(json['pan_number']),
      isinNumber: Parse.toStrings(json['isin_number']),
      cinNumber: Parse.toStrings(json['cin_number']),
      rta: Parse.toStrings(json['rta'], "N/A"),
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
      'lot_size': lotSize,
      'fifty_two_week_high': fiftyTwoWeekHigh,
      'fifty_two_week_low': fiftyTwoWeekLow,
      'depository': depository,
      'pan_number': panNumber,
      'isin_number': isinNumber,
      'cin_number': cinNumber,
      'rta': rta,
      'market_cap': marketCap,
      'pe_ratio': peRatio,
      'pb_ratio': pbRatio,
      'debt_to_equity': debtToEquity,
      'roe': roe,
      'book_value': bookValue,
      'face_value': faceValue,
      'total_shares': totalShares,
    };
  }
}

class DealModel {
  final int id;
  final SharePriceSellerModel seller;
  final String dealType;
  final String expiredAt;
  final bool isHotDeal;
  final String uuid;
  final String companySlug;
  final int availableQuantity;
  final double sharePrice;
  final int minimumQty;
  final double processingFeePercentage;
  final String status;

  DealModel({
    this.id = 0,
    this.seller = const SharePriceSellerModel(),
    this.dealType = '',
    this.expiredAt = '',
    this.isHotDeal = false,
    this.uuid = '',
    this.companySlug = '',
    this.availableQuantity = 0,
    this.sharePrice = 0,
    this.minimumQty = 0,
    this.processingFeePercentage = 0,
    this.status = '',
  });

  DealModel copyWith({
    int? id,
    SharePriceSellerModel? seller,
    String? dealType,
    String? expiredAt,
    bool? isHotDeal,
    String? uuid,
    String? companySlug,
    int? availableQuantity,
    double? sharePrice,
    int? minimumQty,
    double? processingFeePercentage,
    String? status,
  }) {
    return DealModel(
      id: id ?? this.id,
      seller: seller ?? this.seller,
      dealType: dealType ?? this.dealType,
      expiredAt: expiredAt ?? this.expiredAt,
      isHotDeal: isHotDeal ?? this.isHotDeal,
      uuid: uuid ?? this.uuid,
      companySlug: companySlug ?? this.companySlug,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      sharePrice: sharePrice ?? this.sharePrice,
      minimumQty: minimumQty ?? this.minimumQty,
      processingFeePercentage:
          processingFeePercentage ?? this.processingFeePercentage,
      status: status ?? this.status,
    );
  }

  factory DealModel.fromJson(Map<String, dynamic> json) {
    return DealModel(
      id: Parse.toInt(json['id']),
      seller: SharePriceSellerModel.fromJson(json['seller'] ?? {}),
      dealType: Parse.toStrings(json['deal_type']),
      expiredAt: Parse.toStrings(json['expired_at']),
      isHotDeal: Parse.toBool(json['is_hot_deal']),
      uuid: Parse.toStrings(json['uuid']),
      companySlug: Parse.toStrings(json['company_slug']),
      availableQuantity: Parse.toInt(json['available_quantity']),
      sharePrice: Parse.toDouble(json['share_price']),
      minimumQty: Parse.toInt(json['minimum_qty']),
      processingFeePercentage:
          Parse.toDouble(json['processing_fee_percentage']),
      status: Parse.toStrings(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller': seller.toJson(),
      'deal_type': dealType,
      'expired_at': expiredAt,
      'is_hot_deal': isHotDeal,
      'uuid': uuid,
      'company_slug': companySlug,
      'available_quantity': availableQuantity,
      'share_price': sharePrice,
      'minimum_qty': minimumQty,
      'processing_fee_percentage': processingFeePercentage,
      'status': status,
    };
  }
}

class SellerSharePriceModel {
  final String date;
  final double sellPrice;
  final double buyPrice;
  final int minQty;
  final int totalQty;
  final SharePriceSellerModel seller;

  SellerSharePriceModel(
      {required this.date,
      required this.sellPrice,
      this.buyPrice = 0.0,
      required this.minQty,
      this.totalQty = 0,
      required this.seller});

  factory SellerSharePriceModel.fromJson(Map<String, dynamic> json) =>
      SellerSharePriceModel(
        date: Parse.toStrings(json['date']),
        sellPrice: Parse.toDouble(json['sell_price']),
        buyPrice: Parse.toDouble(json['buy_price']),
        minQty: Parse.toInt(json['min_qty']),
        totalQty: Parse.toInt(json['total_qty']),
        seller: SharePriceSellerModel.fromJson(json['seller'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'sell_price': sellPrice,
        'buy_price': buyPrice,
        'min_qty': minQty,
        'total_qty': totalQty,
        'seller': seller.toJson(),
      };
}

class SharePriceSellerModel {
  final int id;
  final String uuid;
  final String companyName;
  final String logo;

  const SharePriceSellerModel(
      {this.id = 0, this.uuid = '', this.companyName = '', this.logo = ''});

  factory SharePriceSellerModel.fromJson(Map<String, dynamic> json) =>
      SharePriceSellerModel(
          id: Parse.toInt(json['id']),
          uuid: Parse.toStrings(json['uuid']),
          companyName: Parse.toStrings(json['company_name']),
          logo: Parse.toStrings(json['logo']));

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'company_name': companyName,
        'logo': logo,
      };
}
