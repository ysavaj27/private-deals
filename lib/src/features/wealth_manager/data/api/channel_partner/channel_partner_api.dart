import 'package:private_deals/src/shared/app_exports.dart';

class ChannelPartnerApi {
  static Future<BaseModel> addChannelPartner({
    required String name,
    required String email,
    required String mobile,
    required String password,
    required String commission,
    required String partner,
    required String gender,
  }) async {
    try {
      Map<String, dynamic> body = {
        'name': name,
        'mobile_number': mobile,
        'email': email,
        // 'commission': commission,
        'gender': gender,
        'partner_type': partner,
        'is_primary_access': password,
        'is_secondary_access': password,
        'is_preipo_access': password,
        'parent_partner_id': app.wUser.id,
        'partner_id': app.wUser.id,
      };

      body.addIf(commission.isNotEmpty, "commission" , commission);
      body.addIf(password.isNotEmpty, "password" , password);

      var res = await dioConfig.post(AppUrl.wAddChannelPartner, body);
      return BaseModel.fromMessage(res.data);
    } catch (e) {
      logger.e(e);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<PartnerUser>>>
      channelPartnerList() async {
    try {
      var res = await dioConfig.get(AppUrl.wChannelPartnerList, {});
      BaseModel<List<PartnerUser>> baseModel = BaseModel.fromListJson(
          res.data,
          (p0) => p0.map((e) => PartnerUser.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Channel Partner List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<PartnerUser>>>
      relationManagerGet() async {
    try {
      var res = await dioConfig.get(AppUrl.wRelationManager, {});
      BaseModel<List<PartnerUser>> baseModel = BaseModel.fromListJson(
          res.data,
          (p0) => p0.map((e) => PartnerUser.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Relation Manager List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
