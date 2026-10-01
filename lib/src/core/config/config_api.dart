import 'package:private_deals/src/shared/app_exports.dart';

class ConfigApi {
  static Future<BaseModel<ConfigModel>> config() async {
    try {
      var res = await dioConfig.get(AppUrl.iConfig, {});
      BaseModel<ConfigModel> baseModel =
          BaseModel.fromJson(res.data, (p0) => ConfigModel.fromJson(p0));
      if (baseModel.isSuccess) {
        app.configModel(baseModel.r);
        app.configModel.refresh();
      }

      return baseModel;
    } catch (e, t) {
      logger.e("Error on Config", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
