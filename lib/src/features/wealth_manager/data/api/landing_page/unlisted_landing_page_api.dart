import 'package:private_deals/src/shared/app_exports.dart';

const types = {
  'All',
  'Trending',
  'Coming Soon',
  'Exclusive Deals',
  'Listed',
  'Liquid Stocks',
  'DRHP'
};

class PreIpoLandingPageApi {
  static Future<BaseModel<List<CompanyModel>>> iCompanyList(
      {required int count, String search = ''}) async {
    try {
      Map<String, dynamic> body = {
        'skip': count,
        'take': 15,
      };
      body.addIf(search.isNotEmpty, 'search', search);
      var res = await dioConfig.get(AppUrl.iCompanyList, body);
      BaseModel<List<CompanyModel>> baseModel = BaseModel.fromListJson(
          res.data, (p0) => p0.map((e) => CompanyModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on homePage", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<CompanyModel>>> wCompanyList({
    required int count,
    String search = '',
    String data = '',
    bool isSecondary = false,
  }) async {
    try {
      Map<String, dynamic> body = {
        'skip': count,
        'take': 25,
        'type': isSecondary ? 'secondary' : 'unlisted',
      };

      if (data.isNotEmpty) {
        final tab = UnListedShareTabEnumX.fromRoute(data);
        if (tab != null) {
          body.addIf(data.isNotEmpty, 'category', tab.apiCategory);
        } else if (data.isNotEmpty) {
          body.addIf(data.isNotEmpty, 'sector', data);
        }
      }

      body.addIf(search.isNotEmpty, 'search', search);
      var res = await dioConfig.get(AppUrl.wPreIPOCompanyList, body);
      BaseModel<List<CompanyModel>> baseModel = BaseModel.fromListJson(
          res.data, (p0) => p0.map((e) => CompanyModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on homePage", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<PreIPOLandingPageModel>> wPreIPOHome(
      {String search = ''}) async {
    try {
      var res = await dioConfig.get(AppUrl.wPreIPOHome, {});
      return BaseModel.fromJson(
          res.data, (data) => PreIPOLandingPageModel.fromJson(data));
    } catch (e, t) {
      logger.e("Error on homePage", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<SecondaryLandingPageModel>> wSecondaryHome() async {
    try {
      var res = await dioConfig.get(AppUrl.wSecondaryLandingPage, {});
      return BaseModel.fromJson(
          res.data, (data) => SecondaryLandingPageModel.fromJson(data));
    } catch (e, t) {
      logger.e("Error on wSecondaryHome", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<PreIPONewsSectorModel>> newsSectors() async {
    try {
      var res = await dioConfig.get(AppUrl.wPreIPOHomeNewsSector, {});
      return BaseModel.fromJson(
          res.data, (data) => PreIPONewsSectorModel.fromJson(data));
    } catch (e, t) {
      logger.e("Error on homePage", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<CompanyModel>> iCompanyDetail(int companyId) async {
    try {
      var res =
          await dioConfig.get(AppUrl.iCompanyDetail, {"company_id": companyId});
      BaseModel<CompanyModel> baseModel =
          BaseModel.fromJson(res.data, (p0) => CompanyModel.fromJson(p0));
      return baseModel;
    } catch (e, t) {
      logger.e("Error on UpComingPitch List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<CompanyModel>> wCompanyDetail(String slug) async {
    try {
      var res = await dioConfig.get(AppUrl.wCompanyDetail, {"slug": slug});
      BaseModel<CompanyModel> baseModel =
          BaseModel.fromJson(res.data, (p0) => CompanyModel.fromJson(p0));
      return baseModel;
    } catch (e, t) {
      logger.e("Error on UpComingPitch List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<NewsModel>>> wNewsList(
      {required int count, String search = ''}) async {
    try {
      Map<String, dynamic> body = {
        'skip': count,
        'take': 15,
      };
      var res = await dioConfig.get(AppUrl.wPreIPONewsList, body);
      return BaseModel.fromListJson(
          res.data, (p0) => p0.map((e) => NewsModel.fromJson(e)).toList());
    } catch (e, t) {
      logger.e("Error on homePage", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
