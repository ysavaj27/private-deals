import 'package:private_deals/src/shared/functions/parse.dart';

class KycModel {
  int id;
  int investorId;
  String aadharNo;
  String panNo;
  String nameAsAadhar;
  String nameAsPan;
  DateTime dobAsAadhar;
  String addressAsAadhar;
  String aadhaarFrontImage;
  String aadhaarBackImage;
  String notes;
  String panImage;
  String status;
  DateTime createdAt;
  DateTime updatedAt;

  KycModel({
    this.id = 0,
    this.investorId = 0,
    this.aadharNo = "",
    this.notes = "",
    this.panNo = '',
    this.nameAsAadhar = '',
    this.nameAsPan = '',
    required this.dobAsAadhar,
    this.addressAsAadhar = '',
    this.aadhaarFrontImage = '',
    this.aadhaarBackImage = '',
    this.panImage = '',
    this.status = '',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isNotEmpty => id == 0 ? false : true;

  factory KycModel.fromJson(Map<String, dynamic> json) => KycModel(
        id: Parse.toInt(json["id"]),
        investorId: Parse.toInt(json["investor_id"]),
        aadharNo: Parse.toStrings(json["aadhar_no"]),
        panNo: Parse.toStrings(json["pan_no"]),
        notes: Parse.toStrings(json["notes"]),
        nameAsAadhar: Parse.toStrings(json["name_as_aadhar"]),
        nameAsPan: Parse.toStrings(json["name_as_pan"]),
        dobAsAadhar: Parse.toDateTime(json["dob_as_aadhar"]),
        addressAsAadhar: Parse.toStrings(json["address_as_aadhar"]),
        aadhaarFrontImage: Parse.parseUrl(json["aadhaar_front_image"]),
        aadhaarBackImage: Parse.parseUrl(json["aadhaar_back_image"]),
        panImage: Parse.parseUrl(json["pan_image"]),
        status: Parse.toStrings(json["status"]),
        createdAt: Parse.toDateTime(json["created_at"]),
        updatedAt: Parse.toDateTime(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "investor_id": investorId,
        "aadhar_no": aadharNo,
        "pan_no": panNo,
        "notes": notes,
        "name_as_aadhar": nameAsAadhar,
        "name_as_pan": nameAsPan,
        "dob_as_aadhar": dobAsAadhar.toIso8601String(),
        "address_as_aadhar": addressAsAadhar,
        "aadhaar_front_image": aadhaarFrontImage,
        "aadhaar_back_image": aadhaarBackImage,
        "pan_image": panImage,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
