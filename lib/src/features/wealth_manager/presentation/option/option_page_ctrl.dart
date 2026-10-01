import 'package:private_deals/src/shared/app_exports.dart';

class OptionPageCtrl extends GetxController {
  @override
  void onReady() {
    notificationInit();
    super.onReady();
  }

  Future<void> notificationInit() async {
    await NotificationServices.initNotification();
  }
}
