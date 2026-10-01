import 'package:private_deals/src/shared/functions/parse.dart';

class IDetailModel {
  int id;
  int investor;
  String company;
  String position;
  String bio;
  String fb;
  String twitter;
  String insta;
  String linkedin;
  String web;
  DateTime dob;
  String address;
  String address2;
  String state;

  IDetailModel({
    this.id = 0,
    this.investor = 0,
    this.company = '',
    this.position = '',
    this.bio = '',
    this.fb = '',
    this.twitter = '',
    this.insta = '',
    this.linkedin = '',
    this.web = '',
    required this.dob,
    this.address = '',
    this.address2 = '',
    this.state = '',
  });

  factory IDetailModel.fromJson(Map<String, dynamic> json) => IDetailModel(
        id: Parse.toInt(json["id"]),
        investor: Parse.toInt(json["investor"]),
        company: Parse.toStrings(json["company"]),
        position: Parse.toStrings(json["position"]),
        bio: Parse.toStrings(json["bio"]),
        fb: Parse.toStrings(json["fb"]),
        twitter: Parse.toStrings(json["twitter"]),
        insta: Parse.toStrings(json["insta"]),
        linkedin: Parse.toStrings(json["linkedin"]),
        web: Parse.toStrings(json["web"]),
        dob: Parse.toDateTime(json["dob"]),
        address: Parse.toStrings(json["address"]),
        address2: Parse.toStrings(json["address2"]),
        state: Parse.toStrings(json["state"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "investor": investor,
        "company": company,
        "position": position,
        "bio": bio,
        "fb": fb,
        "twitter": twitter,
        "insta": insta,
        "linkedin": linkedin,
        "web": web,
        "dob": dob.toIso8601String(),
        "address": address,
        "address2": address2,
        "state": state,
      };
}
