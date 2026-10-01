import 'package:private_deals/src/shared/app_exports.dart';

class ProfilePageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController emailCTRL = TextEditingController();
  TextEditingController commissionCTRL = TextEditingController();
  TextEditingController mobileCTRL = TextEditingController();
  TextEditingController nameCTRL = TextEditingController();

  Future<void> updateProfile() async {
    isLoading(true);
    var res = await WAuthApi.profileDetailUpdate(email: emailCTRL.text);
    isLoading(false);
    if (res.isSuccess) {
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }

  @override
  void onInit() {
    emailCTRL.text = app.wUser.email.toLowerCase();
    nameCTRL.text = app.wUser.name;
    mobileCTRL.text = app.wUser.mobileNumber.toShowString;
    commissionCTRL.text = app.wUser.commission.toShowString;
    super.onInit();
  }

  @override
  void onClose() {
    emailCTRL.dispose();
    commissionCTRL.dispose();
    mobileCTRL.dispose();
    nameCTRL.dispose();
    super.onClose();
  }
}
