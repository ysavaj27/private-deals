import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

class SocialMediaModel {
  int masterSocialmediaLinkId;
  String link;
  SocialMediaTypeModel socialMediaType;

  SocialMediaModel({
    this.masterSocialmediaLinkId = 0,
    this.link = '',
    required this.socialMediaType,
  });

  FaIconData? get icon {
    switch (socialMediaType.name.toLowerCase()) {
      case "x":
        return FontAwesomeIcons.squareXTwitter;
      case "linked in":
        return FontAwesomeIcons.linkedin;
      case "youtube":
        return FontAwesomeIcons.squareYoutube;
      case "instagram":
        return FontAwesomeIcons.squareInstagram;
      case "facebook":
        return FontAwesomeIcons.squareFacebook;
      // default:
      //   return FontAwesomeIcons.youtube;
    }
    return null;
  }

  factory SocialMediaModel.fromJson(Map<String, dynamic> json) =>
      SocialMediaModel(
        masterSocialmediaLinkId:
            Parse.toInt(json["master_socialmedia_link_id"]),
        link: Parse.toStrings(json["link"]),
        socialMediaType:
            SocialMediaTypeModel.fromJson(json["social_media_type"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "master_socialmedia_link_id": masterSocialmediaLinkId,
        "link": link,
        "social_media_type": socialMediaType.toJson(),
      };
}

class SocialMediaTypeModel {
  String name;

  SocialMediaTypeModel({
    this.name = '',
  });

  factory SocialMediaTypeModel.fromJson(Map<String, dynamic> json) =>
      SocialMediaTypeModel(
        name: Parse.toStrings(json["name"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}
