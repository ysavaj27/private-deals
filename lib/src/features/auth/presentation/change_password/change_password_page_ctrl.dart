import 'package:private_deals/src/app/routing/session_navigation.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class ChangePasswordPageCtrl extends GetxController {
  final TextEditingController newPasswordCTRL = TextEditingController();
  final TextEditingController confirmPasswordCTRL = TextEditingController();
  RxBool isLoading = false.obs;
  RxBool newPassObscure = true.obs;
  RxBool confirmPassObscure = true.obs;

  Future<void> onPress() async {
    isLoading(true);
    var res = await WAuthApi.changePassword(
      newPasswordCTRL.text,
      confirmPasswordCTRL.text,
    );
    isLoading(false);
    if (res.isSuccess) {
      SessionNavigation.goHome();
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }

  @override
  void onClose() {
    super.onClose();
    newPasswordCTRL.dispose();
    confirmPasswordCTRL.dispose();
  }
}
