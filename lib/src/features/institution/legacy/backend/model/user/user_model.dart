import 'package:private_deals/src/features/institution/support/functions/parse.dart';

class UserModel {
  int id;
  String uuid;
  String cin;
  String pan;
  String companyName;
  String profile;
  String logo;
  String address;
  String dpId;
  String clientId;
  String bankName;
  String accountNumber;
  String ifsc;
  String branch;
  String mobileCountryCode;
  String mobileNumber;
  String email;
  bool isBlocked;
  bool askPasswordChange;
  bool isDeleted;

  bool isPrimaryAccess;
  bool isSecondaryAccess;
  bool isPreipoAccess;

  DateTime createdAt;
  DateTime updatedAt;
  double createdBy;
  double updatedBy;
  String token;

  String get accountStatus {
    if (isDeleted) return 'Deleted';
    if (isBlocked) return 'Blocked';
    return 'Active';
  }

  UserModel({
    this.id = 0,
    this.uuid = "",
    this.cin = "",
    this.pan = "",
    this.companyName = "",
    this.address = "",
    this.dpId = "",
    this.profile = "",
    this.logo = "",
    this.clientId = "",
    this.bankName = "",
    this.accountNumber = "",
    this.ifsc = "",
    this.branch = "",
    this.mobileCountryCode = "",
    this.mobileNumber = "",
    this.email = "",
    this.isBlocked = false,
    this.askPasswordChange = false,
    this.isDeleted = false,
    this.isPrimaryAccess = false,
    this.isSecondaryAccess = false,
    this.isPreipoAccess = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.createdBy = 0.0,
    this.updatedBy = 0.0,
    this.token = "",
  }) : createdAt = createdAt ?? DateTime(0),
       updatedAt = updatedAt ?? DateTime(0);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: Parse.toInt(json['id']),
      uuid: Parse.toStrings(json['uuid']),
      cin: Parse.toStrings(json['cin']),
      pan: Parse.toStrings(json['pan']),
      companyName: Parse.toStrings(json['company_name']),
      profile: Parse.parseUrl(json['profile']),
      logo: _parseLogo(json['logo']),
      address: Parse.toStrings(json['address']),
      dpId: Parse.toStrings(json['dp_id']),
      clientId: Parse.toStrings(json['client_id']),
      bankName: Parse.toStrings(json['bank_name']),
      accountNumber: Parse.toStrings(json['account_number']),
      ifsc: Parse.toStrings(json['ifsc']),
      branch: Parse.toStrings(json['branch']),
      mobileCountryCode: Parse.toStrings(json['mobile_country_code']),
      mobileNumber: Parse.toStrings(json['mobile_number']),
      email: Parse.toStrings(json['email']),
      isBlocked: Parse.toBool(json['is_blocked']),
      askPasswordChange: Parse.toBool(json['ask_password_change']),
      isDeleted: Parse.toBool(json['is_deleted']),
      isPrimaryAccess: Parse.toBool(json['is_primary_access']),
      isSecondaryAccess: Parse.toBool(json['is_secondary_access']),
      isPreipoAccess: Parse.toBool(json['is_preipo_access']),
      createdAt: Parse.toDateTime(json['created_at']),
      updatedAt: Parse.toDateTime(json['updated_at']),
      createdBy: Parse.toDouble(json['created_by']),
      updatedBy: Parse.toDouble(json['updated_by']),
      token: Parse.toStrings(json['token']),
    );
  }

  static String _parseLogo(dynamic value) {
    final path = Parse.toStrings(value);
    final uri = Uri.tryParse(path);
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      return path;
    }
    return Parse.parseUrl(path);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "uuid": uuid,
      "cin": cin,
      "pan": pan,
      "company_name": companyName,
      "profile": profile,
      "logo": logo,
      "address": address,
      "dp_id": dpId,
      "client_id": clientId,
      "bank_name": bankName,
      "account_number": accountNumber,
      "ifsc": ifsc,
      "branch": branch,
      "mobile_country_code": mobileCountryCode,
      "mobile_number": mobileNumber,
      "email": email,
      "is_blocked": isBlocked,
      "ask_password_change": askPasswordChange,
      "is_deleted": isDeleted,
      "is_primary_access": isPrimaryAccess,
      "is_secondary_access": isSecondaryAccess,
      "is_preipo_access": isPreipoAccess,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "created_by": createdBy,
      "updated_by": updatedBy,
      "token": token,
    };
  }
}
