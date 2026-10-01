import 'package:private_deals/src/shared/functions/parse.dart';

class CompanyStartupModel {
  List<CompanyStartup> startup;
  List<CompanyStartup> company;

  CompanyStartupModel({
    this.startup = const [],
    this.company = const [],
  });

  factory CompanyStartupModel.fromJson(Map<String, dynamic> json) =>
      CompanyStartupModel(
        startup: json["startup"] != null
            ? List<CompanyStartup>.from(
                json["startup"].map((x) => CompanyStartup.fromJson(x)))
            : [],
        company: json["company"] != null
            ? List<CompanyStartup>.from(
                json["company"].map((x) => CompanyStartup.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "startup": List<dynamic>.from(startup.map((x) => x.toJson())),
        "company": List<dynamic>.from(company.map((x) => x.toJson())),
      };
}

class CompanyStartup {
  int id;
  String brandName;

  CompanyStartup({
    required this.id,
    required this.brandName,
  });

  factory CompanyStartup.fromJson(Map<String, dynamic> json) => CompanyStartup(
        id: Parse.toInt(json["id"]),
        brandName: Parse.toStrings(json["brand_name"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "brand_name": brandName,
      };
}
