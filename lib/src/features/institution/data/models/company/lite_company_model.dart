import 'package:private_deals/src/features/institution/support/functions/parse.dart';

class LiteCompanyModel {
  int id;
  String uuid;
  String slug;
  String brandName;
  String companyName;
  String logo;
  bool isFavorite;
  String type;

  LiteCompanyModel({
    this.id = 0,
    this.uuid = "",
    this.slug = "",
    this.brandName = "",
    this.companyName = "",
    this.logo = "",
    this.type = "",
    this.isFavorite = false,
  });

  factory LiteCompanyModel.fromJson(Map<String, dynamic> json) {
    return LiteCompanyModel(
      id: Parse.toInt(json['id']),
      uuid: Parse.toStrings(json['uuid']),
      slug: Parse.toStrings(json['slug']),
      brandName: Parse.toStrings(json['brand_name']),
      companyName: Parse.toStrings(json['company_name']),
      logo: Parse.parseUrl(json['logo']),
      type: Parse.toStrings(json['type']),
      isFavorite: Parse.toBool(json['is_favorite']),
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
      "is_favorite": isFavorite,
      "type": type,
    };
  }
}
