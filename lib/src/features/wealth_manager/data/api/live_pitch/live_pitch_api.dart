import 'package:private_deals/src/shared/app_exports.dart';

class LivePitchApi {
  static Future<BaseModel<List<LivePitchModel>>> pitchList(String type) async {
    try {
      var res = await dioConfig.get(AppUrl.iPitch, {"type": type});
      BaseModel<List<LivePitchModel>> baseModel = BaseModel.fromListJson(
          res.data, (p0) => p0.map((e) => LivePitchModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on UpComingPitch List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

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
      logger.e("Error on transaction", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
