import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/app/routing/session_navigation.dart';

class InitScreenCtrl extends GetxController {
  @override
  void onReady() {
    super.onReady();
    // #region agent log
    agentLog('I', 'init_screen_ctrl.dart:onReady', 'startup navigation', {
      'isUserLogin': app.isUserLogin,
      'role': app.role.apiValue,
      'validated': app.validated(),
    });
    // #endregion
    SessionNavigation.goHome();
  }
}
