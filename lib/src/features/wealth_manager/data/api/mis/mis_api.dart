import 'package:private_deals/src/shared/app_exports.dart';

class MisApi {
  static Future<BaseModel<List<MisModel>>> iMisList() async {
    try {
      var res = await dioConfig.get(AppUrl.iMis, {});
      BaseModel<List<MisModel>> baseModel = BaseModel.fromListJson(
          res.data, (p0) => p0.map((e) => MisModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Notification List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
  static Future<BaseModel<List<WMisModel>>> wMisList() async {
    try {
      var res = await dioConfig.get(AppUrl.wMis, {});
      BaseModel<List<WMisModel>> baseModel = BaseModel.fromListJson(
          res.data, (p0) => p0.map((e) => WMisModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on MIS List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
