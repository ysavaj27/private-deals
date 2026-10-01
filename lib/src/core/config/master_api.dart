import 'package:private_deals/src/shared/app_exports.dart';

class MasterApi {
  static Future<BaseModel<List<MasterTypeModel>>> countryList() async {
    try {
      var res = await dioConfig.get(AppUrl.country, {});
      return BaseModel<List<MasterTypeModel>>.fromListJson(res.data,
          (p0) => p0.map((e) => MasterTypeModel.fromJson(e)).toList());
    } catch (e, t) {
      logger.e("Error on Country List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<MasterTypeModel>>> familyRelation() async {
    try {
      var res = await dioConfig.get(AppUrl.iFamilyRelation, {});
      return BaseModel<List<MasterTypeModel>>.fromListJson(res.data,
          (p0) => p0.map((e) => MasterTypeModel.fromJson(e)).toList());
    } catch (e, t) {
      logger.e("Error on Country List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<MasterTypeModel>>> stateList(
      int countryId) async {
    try {
      var res = await dioConfig.get(AppUrl.state, {"country_id": countryId});
      return BaseModel<List<MasterTypeModel>>.fromListJson(res.data,
          (p0) => p0.map((e) => MasterTypeModel.fromJson(e)).toList());
    } catch (e, t) {
      logger.e("Error on State List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<MasterTypeModel>>> cityList(int stateId) async {
    try {
      var res = await dioConfig.get(AppUrl.city, {"state_id": stateId});
      return BaseModel<List<MasterTypeModel>>.fromListJson(res.data,
          (p0) => p0.map((e) => MasterTypeModel.fromJson(e)).toList());
    } catch (e, t) {
      logger.e("Error on City List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<SectorModel>>> sectorList() async {
    try {
      var res = await dioConfig.get(AppUrl.sector, {});
      return BaseModel<List<SectorModel>>.fromListJson(
          res.data, (p0) => p0.map((e) => SectorModel.fromJson(e)).toList());
    } catch (e, t) {
      logger.e("Error on City List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<CityStateCountryModel>> cityStateCountry() async {
    try {
      var res = await dioConfig.get(AppUrl.cityData, {});
      return BaseModel<CityStateCountryModel>.fromJson(
          res.data, (p0) => CityStateCountryModel.fromJson(p0));
    } catch (e, t) {
      logger.e("Error city State Country", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
