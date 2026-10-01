import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/app/routing/session_navigation.dart';

class InitScreenCtrl extends GetxController {
  @override
  void onReady() {
    super.onReady();
    SessionNavigation.goHome();
  }
}
