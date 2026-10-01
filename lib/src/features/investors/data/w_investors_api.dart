import 'package:private_deals/src/shared/app_exports.dart';

class WInvestorsApi {
  static Future<BaseModel<List<InvestorModel>>> investorsList({
    required String isKyc,
    required String isActive,
    required String isAif,
    List<PartnerUser> relationManagerList = const [],
  }) async {
    try {
      Map<String, dynamic> body = {
        "is_kyc": isKyc,
        "is_active": isActive,
        "is_aif": isAif,
      };
      if (relationManagerList.isNotEmpty) {
        body.addAll({
          'relation_manager_ids': relationManagerList
              .map((manager) => manager.id.toString())
              .join(','),
        });
      }
      var res = await dioConfig.get(AppUrl.wInvestorList, body);
      BaseModel<List<InvestorModel>> baseModel = BaseModel.fromListJson(
        res.data,
        (p0) => p0.map((e) => InvestorModel.fromJson(e)).toList(),
      );
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Investors List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<InvestorModel>> addInvestor({
    required int id,
    required String investorType,
    required String name,
    required String mobileNumber,
    String email = '',
    String address = '',
    int cityId = 0,
    String pincode = '',
    String gender = '',
    String password = '',
    // required bool isPrimaryAccess,
    // required bool isSecondaryAccess,
    // required bool isPreIPOAccess,
  }) async {
    try {
      Map<String, dynamic> body = {
        "investor_type": investorType,
        "name": name,
        "mobile_number": mobileNumber,
        // "email": email,
        // "address": address,
        // "city_id": cityId,
        // "pincode": pincode,
        // "gender": gender,
        // "is_primary_access": isPrimaryAccess,
        // "is_secondary_access": isSecondaryAccess,
        // "is_preipo_access": isPreIPOAccess
      };
      body.addIf(email.isNotEmpty, 'email', email);
      body.addIf(address.isNotEmpty, 'address', address);
      body.addIf(gender.isNotEmpty, 'gender', gender);
      body.addIf(pincode.isNotEmpty, 'pincode', pincode);
      body.addIf(cityId.isNotEmpty, 'city_id', cityId);
      if (id == 0) {
        body.removeWhere(
          (key, _) => ![
            'investor_type',
            'name',
            'mobile_number',
            'email',
            'gender',
          ].contains(key),
        );
      }
      if (id != 0) {
        body.addAll({"investor_id": id});
      }
      var response = await dioConfig.post(
        id != 0 ? AppUrl.wUpdateInvestor : AppUrl.wAddInvestor,
        body,
      );
      BaseModel<InvestorModel> baseModel = BaseModel.fromJson(
        response.data,
        (p0) => InvestorModel.fromJson(p0),
      );
      return baseModel;
    } catch (e, t) {
      logger.e(e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<InvestorModel>> getInvestor({
    required String uuid,
  }) async {
    try {
      Map<String, dynamic> body = {"uuid": uuid};
      var response = await dioConfig.get(AppUrl.wInvestorDetail, body);
      BaseModel<InvestorModel> baseModel = BaseModel.fromJson(
        response.data,
        (p0) => InvestorModel.fromJson(p0),
      );
      return baseModel;
    } catch (e, t) {
      logger.e(e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
