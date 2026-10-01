import 'package:private_deals/src/shared/app_exports.dart';

class MandateApi {
  static Future<BaseModel<List<MandateModel>>> mandateList() async {
    try {
      var res = await dioConfig.get(AppUrl.iBankMandate, {});
      BaseModel<List<MandateModel>> baseModel = BaseModel.fromListJson(
          res.data, (p0) => p0.map((e) => MandateModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on mandate List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
