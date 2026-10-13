import 'package:private_deals/src/shared/app_exports.dart';

class LivePitchApi {
  static Future<BaseModel> applyPitch(
      {required int startupId, required int pitchId}) async {
    try {
      Map<String, dynamic> body = {
        'startup_id': startupId,
        'pitch_id': pitchId
      };
      var res = await dioConfig.post(AppUrl.iPitch, body);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on applyPitch", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
