import 'package:private_deals/src/shared/functions/parse.dart';

class SectorModel {
  int id;
  String slug;
  String name;
  String iconImage;
  int companyCount;
  List<SectorCompanyModel> companies;

  SectorModel({
    this.id = 0,
    this.slug = "",
    this.name = "",
    this.iconImage = "",
    this.companyCount = 0,
    this.companies = const [],
  });

  factory SectorModel.fromJson(Map<String, dynamic> json) => SectorModel(
        id: Parse.toInt(json["id"]),
        slug: Parse.toStrings(json["url_slug"]),
        name: Parse.toStrings(json["name"]),
        iconImage: Parse.parseUrl(json["icon_image"]),
        companyCount: Parse.toInt(json["company_count"]),
        companies: json['companies'] != null
            ? (json['companies'] as List)
                .map((e) => SectorCompanyModel.fromJson(e))
                .toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "url_slug": slug,
        "name": name,
        "icon_image": iconImage,
        "company_count": companyCount,
        "companies": companies.map((e) => e.toJson()).toList(),
      };
}

class SectorCompanyModel {
  String brandName;
  String logo;

  SectorCompanyModel({
    this.brandName = "",
    this.logo = "",
  });

  factory SectorCompanyModel.fromJson(Map<String, dynamic> json) =>
      SectorCompanyModel(
        brandName: Parse.toStrings(json["brand_name"]),
        logo: Parse.parseUrl(json["logo"]),
      );

  Map<String, dynamic> toJson() => {
        "brand_name": brandName,
        "logo": logo,
      };
}
