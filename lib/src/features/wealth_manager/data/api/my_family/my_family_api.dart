import 'package:private_deals/src/shared/app_exports.dart';

class MyFamilyApi {
  static Future<BaseModel<List<InvestorModel>>> myFamilyList(
      int parentId) async {
    try {
      var res = await dioConfig.get(AppUrl.iFamily, {'parent_investor_id': parentId});
      BaseModel<List<InvestorModel>> baseModel = BaseModel.fromListJson(
          res.data, (p0) => p0.map((e) => InvestorModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on My Family List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> addFamilyMember({
    required String investorType,
    required String name,
    required String mobilNumber,
    required String email,
    required String address,
    required int cityId,
    required String pinCode,
    required String gender,
    required String password,
    required int relationId,
    required MediaModel profile,
  }) async {
    try {
      Map<String, dynamic> body = {
        'investor_type': investorType,
        'name': name,
        'mobile_number': mobilNumber,
        'email': email,
        'address': address,
        'city_id': cityId,
        'pincode': pinCode,
        'gender': gender,
        'password': password,
        'relation_id': relationId,
      };
      body.addAll(await dioConfig.createMedia(profile, "profile_photo"));
      var res = await dioConfig.post(AppUrl.iFamily, body, false);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Profile Detail Update", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
