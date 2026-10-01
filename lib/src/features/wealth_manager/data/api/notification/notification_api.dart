import 'package:private_deals/src/shared/app_exports.dart';

class NotificationApi {
  static Future<BaseModel<List<NotificationModel>>> iNotificationList() async {
    try {
      var res = await dioConfig.get(AppUrl.iNotification, {});
      BaseModel<List<NotificationModel>> baseModel = BaseModel.fromListJson(
          res.data,
          (p0) => p0.map((e) => NotificationModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Notification List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<NotificationModel>>> wNotificationList() async {
    try {
      var res = await dioConfig.get(AppUrl.wNotification, {});
      BaseModel<List<NotificationModel>> baseModel = BaseModel.fromListJson(
          res.data,
          (p0) => p0.map((e) => NotificationModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Notification List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
