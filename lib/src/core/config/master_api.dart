import 'package:private_deals/src/shared/app_exports.dart';

class MasterApi {
  static Future<BaseModel<List<SectorModel>>> sectorList() async {
    try {
      var res = await dioConfig.get(AppUrl.sector, {});
      return BaseModel<List<SectorModel>>.fromListJson(
          res.data, (p0) => p0.map((e) => SectorModel.fromJson(e)).toList());
    } catch (e, t) {
      logger.e("Error on Sector List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
