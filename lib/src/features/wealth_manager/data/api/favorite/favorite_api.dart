import 'package:private_deals/src/shared/app_exports.dart';

class FavoriteApi {
  static Future<BaseModel<List<FavoriteModel>>> favoriteList() async {
    try {
      var res = await dioConfig.get(AppUrl.iFavorites, {});
      BaseModel<List<FavoriteModel>> baseModel = BaseModel.fromListJson(
          res.data, (p0) => p0.map((e) => FavoriteModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on favorite List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> addRemove(int startupId) async {
    try {
      var res =
          await dioConfig.post(AppUrl.iFavorites, {"startup_id": startupId});
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on UpComingPitch List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
