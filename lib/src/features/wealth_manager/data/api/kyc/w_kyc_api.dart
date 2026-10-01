import 'package:private_deals/src/shared/app_exports.dart';

class WealthManagerKycApi {

  static Future<BaseModel> kycUpdate({
    required MediaModel aadharFront,
    required MediaModel aadharBack,
    required MediaModel panCard,
    required MediaModel cheque,
    required MediaModel cml,
    required int investorId,
  }) async {
    try {
      Map<String, dynamic> body = {"investor_id": investorId};
      body.addAll(await dioConfig.createMedia(aadharFront, "aadhar_front"));
      body.addAll(await dioConfig.createMedia(aadharBack, "aadhar_back"));
      body.addAll(await dioConfig.createMedia(panCard, "pan_card"));
      body.addAll(await dioConfig.createMedia(cheque, "cheque"));
      body.addAll(await dioConfig.createMedia(cml, "cml"));
      var res = await dioConfig.post("${AppUrl.wInvestorKyc}?investor_id=$investorId", body, false);
      BaseModel baseModel =  BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Kyc", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
