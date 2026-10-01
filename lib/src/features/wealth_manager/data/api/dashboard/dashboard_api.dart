import 'package:private_deals/src/shared/app_exports.dart';

class DashboardApi {
  static Future<BaseModel<IDashboardModel>> investorDashboard() async {
    try {
      var res = await dioConfig.get(AppUrl.iDashboard, {});
      BaseModel<IDashboardModel> baseModel =
          BaseModel.fromJson(res.data, (p0) => IDashboardModel.fromJson(p0));
      return baseModel;
    } catch (e, t) {
      logger.e("Error on UpComingPitch List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<IDashboardModel>> investorPreIpoDashboard() async {
    try {
      var res = await dioConfig.get(AppUrl.iPreIpoDashboard, {});
      BaseModel<IDashboardModel> baseModel =
          BaseModel.fromJson(res.data, (p0) => IDashboardModel.fromJson(p0));
      return baseModel;
    } catch (e, t) {
      logger.e("Error on investor PreIpo Dashboard List",
          error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  // static Future<BaseModel<List<DocumentModel>>> sectorInvestment(
  //     int sectorId) async {
  //   try {
  //     var res =
  //         await dioConfig.get(AppUrl.iStartupList, {"sector_id": sectorId});
  //     BaseModel<List<DocumentModel>> baseModel = BaseModel.fromListJson(
  //         res.data, (p0) => p0.map((e) => DocumentModel.fromJson(e)).toList());
  //     return baseModel;
  //   } catch (e, t) {
  //     logger.e("Error on sectorInvestment List", error: e, stackTrace: t);
  //     return BaseModel.fromError(e.toString());
  //   }
  // }

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
