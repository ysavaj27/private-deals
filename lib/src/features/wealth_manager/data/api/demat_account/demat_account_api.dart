import 'package:private_deals/src/shared/app_exports.dart';

class DematAccountApi {
  static Future<BaseModel> dematDetails({
    required String dpId,
    String clientId = '',
    String dematAccount = '',
  }) async {
    try {
      Map<String, dynamic> body = {"dp_id": dpId};
      body.addIf(clientId.isNotEmpty, "client_id", clientId);
      body.addIf(dematAccount.isNotEmpty, "demat_account", dematAccount);

      var response = await dioConfig.post(AppUrl.iDemat, body);
      BaseModel baseModel = BaseModel.fromMessage(response.data);
      if (baseModel.isSuccess) {
        IAuthApi.profileGet();
      }
      return baseModel;
    } catch (e) {
      logger.e(e);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> iAddDemat({
    required String dpId,
    String clientId = '',
    String dematAccount = '',
  }) async {
    try {
      Map<String, dynamic> body = {"dp_id": dpId};
      body.addIf(clientId.isNotEmpty, "client_id", clientId);
      body.addIf(dematAccount.isNotEmpty, "demat_account", dematAccount);

      var response = await dioConfig.post(AppUrl.iDemat, body);
      BaseModel baseModel = BaseModel.fromMessage(response.data);
      // if (baseModel.isSuccess) {
      //   AuthApi.investorGetProfile();
      // }
      return baseModel;
    } catch (e) {
      logger.e(e);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<InvestorModel>> iDemat() async {
    try {
      var res = await dioConfig.get(AppUrl.iDemat, {});
      BaseModel<InvestorModel> baseModel =
          BaseModel.fromJson(res.data, (p0) => InvestorModel.fromJson(p0));
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Demat", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
