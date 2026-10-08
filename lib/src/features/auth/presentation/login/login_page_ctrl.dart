import 'package:flutter/foundation.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/app/routing/session_navigation.dart';

class LoginPageCtrl extends GetxController {
  final mobileNoCTRL = TextEditingController();
  final passwordCTRL = TextEditingController();
  final isLoading = false.obs;
  final isObscure = true.obs;
  final phoneKey = GlobalKey<FormState>();
  final desktopKey = GlobalKey<FormState>();
  Future<void> onPress() async {
    if (isLoading()) return;
    isLoading(true);
    final res = await WAuthApi.login(
      mobileNo: mobileNoCTRL.text.trim(),
      password: passwordCTRL.text,
    );
    isLoading(false);
    if (res.isSuccess && app.isUserLogin) {
      passwordCTRL.clear();
      await app.loginCounts();
      SessionNavigation.goHome();
    } else {
      toast(res.m, MessageEnum.error);
    }
  }

  @override
  void onClose() {
    mobileNoCTRL.dispose();
    passwordCTRL.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    if (kDebugMode) {
      // mobileNoCTRL.text = '7984718397';
      mobileNoCTRL.text = '9898375981';
      passwordCTRL.text = 'Shuru@123';
    }
    // TODO: implement onInit
    super.onInit();
  }
}
