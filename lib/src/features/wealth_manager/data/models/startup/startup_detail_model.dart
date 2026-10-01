import 'package:private_deals/src/shared/functions/parse.dart';

class StartUpDetailModel {
  String shortDescription;
  String infoDescription;
  String keyInformation;
  String logo;
  String banner;
  String longBanner;
  String productVideo;
  String pitchDeckFile;
  String websiteUrl;
  String financialProjection;
  String ddReport;
  String valuationReport;
  String dpiitCertificate;
  String shuruupResearchReport;
  String pitchVideo;

  StartUpDetailModel({
    this.shortDescription = '',
    this.infoDescription = '',
    this.keyInformation = '',
    this.logo = '',
    this.banner = '',
    this.longBanner = '',
    this.productVideo = '',
    this.pitchDeckFile = '',
    this.websiteUrl = '',
    this.financialProjection = '',
    this.ddReport = '',
    this.valuationReport = '',
    this.dpiitCertificate = '',
    this.shuruupResearchReport = '',
    this.pitchVideo = '',
  });

  factory StartUpDetailModel.fromJson(Map<String, dynamic> json) =>
      StartUpDetailModel(
        shortDescription: Parse.toStrings(json["short_description"]),
        infoDescription: Parse.toStrings(json["info_description"]),
        keyInformation: Parse.toStrings(json["key_information"]),
        logo: Parse.parseUrl(json["logo"]),
        banner: Parse.parseUrl(json["banner"]),
        longBanner: Parse.parseUrl(json["long_banner"]),
        productVideo: Parse.parseUrl(json["product_video"]),
        pitchDeckFile: Parse.parseUrl(json["pitch_deck_file"]),
        websiteUrl: Parse.toStrings(json["website_url"]),
        financialProjection: Parse.parseUrl(json["financial_projection"]),
        ddReport: Parse.parseUrl(json["dd_report"]),
        valuationReport: Parse.parseUrl(json["valuation_report"]),
        dpiitCertificate: Parse.parseUrl(json["dpiit_certificate"]),
        shuruupResearchReport: Parse.parseUrl(json["shuruup_research_report"]),
        pitchVideo: Parse.parseUrl(json["pitch_video"]),
      );

  Map<String, dynamic> toJson() => {
        "short_description": shortDescription,
        "info_description": infoDescription,
        "key_information": keyInformation,
        "logo": logo,
        "banner": banner,
        "long_banner": longBanner,
        "product_video": productVideo,
        "pitch_deck_file": pitchDeckFile,
        "website_url": websiteUrl,
        "financial_projection": financialProjection,
        "dd_report": ddReport,
        "valuation_report": valuationReport,
        "dpiit_certificate": dpiitCertificate,
        "shuruup_research_report": shuruupResearchReport,
        "pitch_video": pitchVideo,
      };
}
