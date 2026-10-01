import 'package:private_deals/src/shared/app_exports.dart';

class InvestorKycApi {
  // static Future<EKycModel> eKycToken() async {
  //   try {
  //     var res = await dioConfig.get(AppUrl.iEKycToken, {});
  //     return EKycModel.fromJson(res.data);
  //   } catch (e, t) {
  //     logger.e("Error on UpComingPitch List", error: e, stackTrace: t);
  //     return EKycModel(status: 0);
  //   }
  // }

  // static Future<BaseModel> updateEKyc(String entityId) async {
  //   try {
  //     var res = await dioConfig.post(AppUrl.iEKycData, {"entity_id": entityId});
  //     return BaseModel.fromMessage(res.data);
  //   } catch (e, t) {
  //     logger.e("Error on UpComingPitch List", error: e, stackTrace: t);
  //     return BaseModel.fromError(e.toString());
  //   }
  // }

  static Future<BaseModel> kyc({
    required MediaModel aadharFront,
    required MediaModel aadharBack,
    required MediaModel panCard,
    required MediaModel cheque,
    required MediaModel cml,
  }) async {
    try {
      Map<String, dynamic> body = {"investor_id": app.iUser.id};
      body.addAll(await dioConfig.createMedia(aadharFront, "aadhar_front"));
      body.addAll(await dioConfig.createMedia(aadharBack, "aadhar_back"));
      body.addAll(await dioConfig.createMedia(panCard, "pan_card"));
      body.addAll(await dioConfig.createMedia(cheque, "cheque"));
      body.addAll(await dioConfig.createMedia(cml, "cml"));
      var res = await dioConfig.post("${AppUrl.iKyc}?investor_id=${app.iUser.id}", body, false);
      BaseModel baseModel =  BaseModel.fromMessage(res.data);
      if (baseModel.isSuccess) {
        await IAuthApi.profileGet();
      }
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Kyc", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
