import 'package:flutter/foundation.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class InquiryPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  final TextEditingController nameCTRL = TextEditingController();
  final TextEditingController emailCTRL = TextEditingController();
  final TextEditingController mobileNoCTRL = TextEditingController();
  final TextEditingController otpCTRL = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int otp = 0;
  RxBool isOtp = false.obs;
  RxBool isVerified = false.obs;

  Future<void> send() async {
    if (formKey.currentState?.validate() ?? false) {
      if (isVerified.isFalse) {
        toast("Please verify mobile number");
        return;
      }
      isLoading(true);
      var res = await IAuthApi.registerInquiry(
          nameCTRL.text, emailCTRL.text, mobileNoCTRL.text);
      isLoading(false);
      if (res.isSuccess) {
        Get.back();
        toast(res.m, MessageEnum.success);
      } else {
        toast(res.m, MessageEnum.alert);
      }
    }
  }

  Future<void> verifyPhoneNumber() async {
    otp = 0;
    if (formKey.currentState?.validate() ?? false) {
      isLoading(true);
      var res = await IAuthApi.verifyMobileNumber(mobileNoCTRL.text);
      isLoading(false);
      if (res.isSuccess) {
        otp = res.r;
        isOtp(true);
        toast(res.m, MessageEnum.success);
      } else {
        toast(res.m, MessageEnum.alert);
      }
    }
    otpCTRL.clear();
  }

  @override
  void onInit() {
    if (kDebugMode) {
      nameCTRL.text = 'Yash';
      emailCTRL.text = 'savajyash8866@gmail.com';
    }
    super.onInit();
  }

  @override
  void onClose() {
    nameCTRL.clear();
    emailCTRL.clear();
    mobileNoCTRL.clear();
    super.onClose();
  }
}
