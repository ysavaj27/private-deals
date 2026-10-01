import 'package:private_deals/src/shared/functions/parse.dart';

class PinCodeModel {
  String message;
  String status;
  List<PostOffice> postOffice;

  PinCodeModel({
    this.message = '',
    this.status = '',
    this.postOffice = const [],
  });

  factory PinCodeModel.fromJson(Map<String, dynamic> json) => PinCodeModel(
        message: Parse.toStrings(json["Message"]),
        status: Parse.toStrings(json["status"]),
        postOffice: json["PostOffice"] != null
            ? List<PostOffice>.from(
                json["PostOffice"].map((x) => PostOffice.fromJson(x)))
            : [],
      );

  factory PinCodeModel.fromError(String error) =>
      PinCodeModel(message: error, status: '', postOffice: []);

  Map<String, dynamic> toJson() => {
        "Message": message,
        "Status": status,
        "PostOffice": List<dynamic>.from(postOffice.map((x) => x.toJson())),
      };
}

class PostOffice {
  String name;
  String description;
  String branchType;
  String deliveryStatus;
  String circle;
  String district;
  String division;
  String region;
  String block;
  String state;
  String country;
  String pincode;

  PostOffice({
    this.name = '',
    this.description = '',
    this.branchType = '',
    this.deliveryStatus = '',
    this.circle = '',
    this.district = '',
    this.division = '',
    this.region = '',
    this.block = '',
    this.state = '',
    this.country = '',
    this.pincode = '',
  });

  factory PostOffice.fromJson(Map<String, dynamic> json) => PostOffice(
        name: Parse.toStrings(json["Name"]),
        description: Parse.toStrings(json["Description"]),
        branchType: Parse.toStrings(json["BranchType"]),
        deliveryStatus: Parse.toStrings(json["DeliveryStatus"]),
        circle: Parse.toStrings(json["Circle"]),
        district: Parse.toStrings(json["District"]),
        division: Parse.toStrings(json["Division"]),
        region: Parse.toStrings(json["Region"]),
        block: Parse.toStrings(json["Block"]),
        state: Parse.toStrings(json["State"]),
        country: Parse.toStrings(json["Country"]),
        pincode: Parse.toStrings(json["Pincode"]),
      );

  Map<String, dynamic> toJson() => {
        "Name": name,
        "Description": description,
        "BranchType": branchType,
        "DeliveryStatus": deliveryStatus,
        "Circle": circle,
        "District": district,
        "Division": division,
        "Region": region,
        "Block": block,
        "State": state,
        "Country": country,
        "Pincode": pincode,
      };
}
