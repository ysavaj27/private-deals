import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

class StartupInvestorModel {
  final String name;
  final String profileVisibility;
  final String profilePhoto;
  final double totalInvested;

  String get showName {
    if (profileVisibility ==
        app.config.enumValues.investorProfileVisibility.private) {
      return "Anonymous";
    } else {
      return name;
    }
  }

  String get profile {
    if (profileVisibility ==
        app.config.enumValues.investorProfileVisibility.public) {
      return profilePhoto;
    } else {
      return "";
    }
  }

  StartupInvestorModel({
    this.name = '',
    this.profileVisibility = '',
    this.profilePhoto = '',
    this.totalInvested = 0,
  });

  factory StartupInvestorModel.fromJson(Map<String, dynamic> json) {
    return StartupInvestorModel(
      name: Parse.toStrings(json["name"]),
      profileVisibility: Parse.toStrings(json["profile_visibility"]),
      profilePhoto: Parse.parseUrl(json["profile_photo"]),
      totalInvested: Parse.toDouble(json["total_invested"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "profile_visibility": profileVisibility,
      "profile_photo": profilePhoto.isNotEmpty ? profilePhoto : null,
      "total_invested": totalInvested,
    };
  }
}
