import 'package:private_deals/src/shared/app_exports.dart';

class MyEarningApi {
  static Future<BaseModel<InvestorEarningModel>> wInvestorEarningList() async {
    try {
      Map<String, dynamic> body = {};
      var res = await dioConfig.get(AppUrl.wInvestorEarning, body);
      BaseModel<InvestorEarningModel> baseModel = BaseModel.fromJson(
          res.data, (data) => InvestorEarningModel.fromJson(data));
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Config", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<PartnerEarningModel>> wPartnerEarningList() async {
    try {
      Map<String, dynamic> body = {};
      var res = await dioConfig.get(AppUrl.wPartnerEarning, body);
      BaseModel<PartnerEarningModel> baseModel = BaseModel.fromJson(
          res.data, (data) => PartnerEarningModel.fromJson(data));
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Config", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
