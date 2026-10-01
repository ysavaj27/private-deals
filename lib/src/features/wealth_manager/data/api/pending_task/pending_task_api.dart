import 'package:private_deals/src/shared/app_exports.dart';

class PendingTaskApi {
  static Future<BaseModel<PendingTaskModel>> pendingTasks() async {
    try {
      var res = await dioConfig.get(AppUrl.wPendingTasks, {});
      BaseModel<PendingTaskModel> baseModel =
          BaseModel.fromJson(res.data, (p0) => PendingTaskModel.fromJson(p0));
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Pending Tasks List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
