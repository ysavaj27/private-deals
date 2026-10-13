import 'package:private_deals/src/shared/app_exports.dart';

class DashboardApi {
  static Future<BaseModel<WDashboardModel>> wealthManagerDashboard() async {
    try {
      var res = await dioConfig.get(AppUrl.wDashboard, {});
      BaseModel<WDashboardModel> baseModel =
          BaseModel.fromJson(res.data, (p0) => WDashboardModel.fromJson(p0));
      return baseModel;
    } catch (e, t) {
      logger.e("Error on UpComingPitch List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<WDashboardModel>>
      wealthManagerPreIPODashboard() async {
    try {
      var res = await dioConfig.get(AppUrl.wPreIPODashboard, {});
      BaseModel<WDashboardModel> baseModel =
          BaseModel.fromJson(res.data, (p0) => WDashboardModel.fromJson(p0));
      return baseModel;
    } catch (e, t) {
      logger.e("Error on UpComingPitch List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
