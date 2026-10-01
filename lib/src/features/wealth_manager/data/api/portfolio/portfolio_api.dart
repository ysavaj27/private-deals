import 'package:private_deals/src/shared/app_exports.dart';

class PortfolioApi {
  static Future<BaseModel<List<PortfolioModel>>> portfolioAPi(
      String sellType) async {
    try {
      Map<String, dynamic> body = {"type": sellType};
      var res = await dioConfig.get(AppUrl.iPortfolio, body);
      BaseModel<List<PortfolioModel>> baseModel = BaseModel.fromListJson(
          res.data, (p0) => p0.map((e) => PortfolioModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Config", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<StartupPortfolioListModel>>> wPortfolioAPi(
      String type, List<int> investors, List<int> startups) async {
    try {
      Map<String, dynamic> body = {"type": type};
      body.addIf(investors.isNotEmpty, 'investor_ids', investors.join(","));
      body.addIf(startups.isNotEmpty, 'startup_ids', startups.join(","));
      var res = await dioConfig.get(AppUrl.wPortfolio, body);
      logger.d(res.data);
      BaseModel<List<StartupPortfolioListModel>> baseModel =
          BaseModel.fromListJson(
              res.data,
              (p0) => p0
                  .map((e) => StartupPortfolioListModel.fromJson(e))
                  .toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Config", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<PreIPOPortfolioModel>>>
      preIpoPortfolioAPi() async {
    try {
      var res = await dioConfig.get(AppUrl.iPreIpoPortfolio, {});
      BaseModel<List<PreIPOPortfolioModel>> baseModel = BaseModel.fromListJson(
          res.data,
          (p0) => p0.map((e) => PreIPOPortfolioModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Config", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<PreIPOPortfolioListModel>>> wPreIpoPortfolioAPi(
      List<int> investors) async {
    try {
      Map<String, dynamic> body = {};

      body.addIf(investors.isNotEmpty, 'investor_ids', investors.join(','));
      var res = await dioConfig.get(AppUrl.wPreIpoPortfolio, {});
      BaseModel<List<PreIPOPortfolioListModel>> baseModel =
          BaseModel.fromListJson(
              res.data,
              (p0) =>
                  p0.map((e) => PreIPOPortfolioListModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Unlisted Shares list", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<CompanyStartupModel>> getCompanyStartupApi() async {
    try {
      var res = await dioConfig.get(
          app.userType == UserType.investor
              ? AppUrl.iCompanyStartupList
              : AppUrl.wCompanyStartupList,
          {});
      BaseModel<CompanyStartupModel> baseModel = BaseModel.fromJson(
          res.data, (p0) => CompanyStartupModel.fromJson(p0));
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Company StartUp", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<CompanyStartupModel>> iAddPortfolioApi({
    required DashboardTypeEnum type,
    required int companyId,
    required String otherName,
    required int shares,
    required double sharePrice,
    required String date,
  }) async {
    try {
      Map<String, dynamic> body = {
        "investor_id": app.iUser.id,
        "other_name": otherName,
        "shares": shares,
        "share_price": sharePrice,
        "date": date,
      };
      body.addAll(
          {"type": type == DashboardTypeEnum.primary ? "startup" : "company"});
      body.addIf(companyId.isNotEmpty, "company_id", companyId);
      var res = await dioConfig.post(AppUrl.iAddPortfolio, body);
      BaseModel<CompanyStartupModel> baseModel =
          BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Add portfolio", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<CompanyStartupModel>> wAddPortfolioApi({
    required DashboardTypeEnum type,
    required int companyId,
    required int investorId,
    required String otherName,
    required int shares,
    required double sharePrice,
    required String date,
  }) async {
    try {
      Map<String, dynamic> body = {
        "investor_id": investorId,
        "other_name": otherName,
        "shares": shares,
        "share_price": sharePrice,
        "date": date,
      };
      body.addAll(
          {"type": type == DashboardTypeEnum.primary ? "startup" : "company"});
      body.addIf(companyId.isNotEmpty, "company_id", companyId);

      var res = await dioConfig.post(AppUrl.wAddPortfolio, body);
      BaseModel<CompanyStartupModel> baseModel =
          BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Add portfolio", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
