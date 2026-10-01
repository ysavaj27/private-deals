import 'package:private_deals/src/shared/functions/parse.dart';

class TeamMemberModel {
  String name;
  String designation;
  String briefInformation;
  String profilePhoto;
  String linkedinUrl;

  TeamMemberModel({
    this.name = '',
    this.designation = '',
    this.briefInformation = '',
    this.profilePhoto = '',
    this.linkedinUrl = '',
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) =>
      TeamMemberModel(
        name: Parse.toStrings(json["name"]),
        designation: Parse.toStrings(json["designation"]),
        briefInformation: Parse.toStrings(json["brief_information"]),
        profilePhoto: Parse.parseUrl(json["profile_photo"]),
        linkedinUrl: Parse.toStrings(json["linkedin_url"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "designation": designation,
        "brief_information": briefInformation,
        "profile_photo": profilePhoto,
        "linkedin_url": linkedinUrl,
      };
}
