import 'package:private_deals/src/shared/app_exports.dart';

class LandingPageApi {
  static Future<BaseModel<LandingPageModel>> iHomePage() async {
    try {
      var res = await dioConfig.get(AppUrl.home, {});
      BaseModel<LandingPageModel> baseModel =
          BaseModel.fromJson(res.data, (p0) => LandingPageModel.fromJson(p0));
      return baseModel;
    } catch (e, t) {
      logger.e("Error on homePage", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<StartupModel>> iStartupDetail(int startupId) async {
    try {
      var res =
          await dioConfig.get(AppUrl.startupDetail, {"startup_id": startupId});
      BaseModel<StartupModel> baseModel =
          BaseModel.fromJson(res.data, (p0) => StartupModel.fromJson(p0));
      return baseModel;
    } catch (e, t) {
      logger.e("Error on UpComingPitch List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<StartupRoundModel>>> iStartupList(
      {int sectorId = 0, StartupStatusEnum? type}) async {
    try {
      Map<String, dynamic> body = {};
      if (sectorId != 0) {
        body.addAll({"sector_id": sectorId});
      }
      if (type != null) {
        body.addAll({"status": type.name});
      }
      var res = await dioConfig.get(AppUrl.startupList, body);
      BaseModel<List<StartupRoundModel>> baseModel = BaseModel.fromListJson(
          res.data,
          (p0) => p0.map((e) => StartupRoundModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on sectorInvestment List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<StartupRoundModel>>> wGetSector(
      {required String slug}) async {
    try {
      Map<String, dynamic> body = {"slug": slug};
      var res = await dioConfig.get(AppUrl.startupList, body);
      BaseModel<List<StartupRoundModel>> baseModel = BaseModel.fromListJson(
          res.data,
          (p0) => p0.map((e) => StartupRoundModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on sectorInvestment List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<StartupLiteModel>>> wLiteStartupList(
      {int sectorId = 0, StartupStatusEnum? type}) async {
    try {
      Map<String, dynamic> body = {};
      var res = await dioConfig.get(AppUrl.wStartupLite, body);
      BaseModel<List<StartupLiteModel>> baseModel = BaseModel.fromListJson(
          res.data,
          (p0) => p0.map((e) => StartupLiteModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Lite Startup List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  // static Future<BaseModel<List<StartupLiteModel>>> wStartupList(
  //     {required String slug}) async {
  //   try {
  //     Map<String, dynamic> body = {'slug'};
  //     var res = await dioConfig.get(AppUrl.wStartupList, body);
  //     BaseModel<List<StartupLiteModel>> baseModel = BaseModel.fromListJson(
  //         res.data,
  //         (p0) => p0.map((e) => StartupLiteModel.fromJson(e)).toList());
  //     return baseModel;
  //   } catch (e, t) {
  //     logger.e("Error on Lite Startup List", error: e, stackTrace: t);
  //     return BaseModel.fromError(e.toString());
  //   }
  // }

  static Future<BaseModel<List<StartupLiteModel>>> iLiteStartupList(
      {int sectorId = 0, StartupStatusEnum? type}) async {
    try {
      Map<String, dynamic> body = {};
      var res = await dioConfig.get(AppUrl.iStartupLite, body);
      BaseModel<List<StartupLiteModel>> baseModel = BaseModel.fromListJson(
          res.data,
          (p0) => p0.map((e) => StartupLiteModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Lite Startup List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<BlogModel>>> blogList() async {
    try {
      var res = await dioConfig.get(AppUrl.blog, {});
      BaseModel<List<BlogModel>> baseModel = BaseModel.fromListJson(
          res.data, (p0) => p0.map((e) => BlogModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Config", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<BlogModel>> blogDetail(
      {required String slug}) async {
    try {
      Map<String, dynamic> body = {'url_slug': slug};
      var res = await dioConfig.get(AppUrl.blog, body);
      BaseModel<BlogModel> baseModel =
          BaseModel.fromJson(res.data, (p0) => BlogModel.fromJson(p0));
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Config", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<LandingPageModel>> wHomePage() async {
    try {
      var res = await dioConfig.get(AppUrl.home, {});
      BaseModel<LandingPageModel> baseModel =
          BaseModel.fromJson(res.data, (p0) => LandingPageModel.fromJson(p0));
      return baseModel;
    } catch (e, t) {
      logger.e("Error on homePage", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<StartupModel>> wStartupDetail(String id) async {
    try {
      var res = await dioConfig.get(AppUrl.wStartupDetail, {"slug": id});
      BaseModel<StartupModel> baseModel =
          BaseModel.fromJson(res.data, (p0) => StartupModel.fromJson(p0));
      return baseModel;
    } catch (e, t) {
      logger.e("Error on UpComingPitch List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<StartupRoundModel>>> wStartupList(
      {int sectorId = 0, StartupStatusEnum? type}) async {
    try {
      Map<String, dynamic> body = {};
      if (sectorId != 0) {
        body.addAll({"sector_id": sectorId});
      }
      if (type != null) {
        body.addAll({"status": type.name});
      }
      var res = await dioConfig.get(AppUrl.startupList, body);
      BaseModel<List<StartupRoundModel>> baseModel = BaseModel.fromListJson(
          res.data,
          (p0) => p0.map((e) => StartupRoundModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on sectorInvestment List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<StartupRoundModel>>> wNewStartupList(
      {required String slug}) async {
    try {
      Map<String, dynamic> body = {};
      const statuses = ['raisingnow', 'completed', 'comingsoon'];
      if (statuses.contains(slug)) {
        body.addAll({'status': slug});
      } else {
        body.addAll({'sector': slug});
      } // Map<String, dynamic> body = {'status': slug};
      // if (sectorId != 0) {
      //   body.addAll({"sector_id": sectorId});
      // }
      // if (type != null) {
      //   body.addAll({"status": type.name});
      // }
      var res = await dioConfig.get(AppUrl.wStartupList, body);
      BaseModel<List<StartupRoundModel>> baseModel = BaseModel.fromListJson(
          res.data,
          (p0) => p0.map((e) => StartupRoundModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on sectorInvestment List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
