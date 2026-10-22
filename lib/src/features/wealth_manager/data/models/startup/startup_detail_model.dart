import 'package:private_deals/src/shared/functions/parse.dart';

class StartUpDetailModel {
  String shortDescription;
  String keyInformation;
  String logo;
  String banner;
  String longBanner;
  String productVideo;
  String financialProjection;
  String ddReport;
  String valuationReport;
  String shuruupResearchReport;
  String pitchVideo;

  StartUpDetailModel({
    this.shortDescription = '',
    this.keyInformation = '',
    this.logo = '',
    this.banner = '',
    this.longBanner = '',
    this.productVideo = '',
    this.financialProjection = '',
    this.ddReport = '',
    this.valuationReport = '',
    this.shuruupResearchReport = '',
    this.pitchVideo = '',
  });

  factory StartUpDetailModel.fromJson(Map<String, dynamic> json) =>
      StartUpDetailModel(
        shortDescription: Parse.toStrings(json["short_description"]),
        keyInformation: Parse.toStrings(json["key_information"]),
        logo: Parse.parseUrl(json["logo"]),
        banner: Parse.parseUrl(json["banner"]),
        longBanner: Parse.parseUrl(json["long_banner"]),
        productVideo: Parse.parseUrl(json["product_video"]),
        financialProjection: Parse.parseUrl(json["financial_projection"]),
        ddReport: Parse.parseUrl(json["dd_report"]),
        valuationReport: Parse.parseUrl(json["valuation_report"]),
        shuruupResearchReport: Parse.parseUrl(json["shuruup_research_report"]),
        pitchVideo: Parse.parseUrl(json["pitch_video"]),
      );

  Map<String, dynamic> toJson() => {
        "short_description": shortDescription,
        "key_information": keyInformation,
        "logo": logo,
        "banner": banner,
        "long_banner": longBanner,
        "product_video": productVideo,
        "financial_projection": financialProjection,
        "dd_report": ddReport,
        "valuation_report": valuationReport,
        "shuruup_research_report": shuruupResearchReport,
        "pitch_video": pitchVideo,
      };
}
