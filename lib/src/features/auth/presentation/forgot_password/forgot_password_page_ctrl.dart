import 'package:private_deals/src/shared/app_exports.dart';

class ForgotPasswordPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxBool passObscure = true.obs;
  RxBool confirmPassObscure = true.obs;
  Rx<ForgotPassEnum> flag = ForgotPassEnum.mobile.obs;
  int otp = 0;
  String password = '';
  final TextEditingController phoneNoCTRL = TextEditingController();
  final TextEditingController otpCTRL = TextEditingController();
  final TextEditingController passwordCTRL = TextEditingController();
  final TextEditingController confirmPasswordCTRL = TextEditingController();

  ///MOBILE FORM KEY
  final mMobileKey = GlobalKey<FormState>();
  final mOtpKey = GlobalKey<FormState>();
  final mPassKey = GlobalKey<FormState>();

  final dMobileKey = GlobalKey<FormState>();
  final dOtpKey = GlobalKey<FormState>();
  final dPassKey = GlobalKey<FormState>();

  String get image {
    switch (flag()) {
      case ForgotPassEnum.mobile:
        return AppAssets.mobileNumberBg;
      case ForgotPassEnum.otp:
        return AppAssets.otpPageBg;
      case ForgotPassEnum.password:
        return AppAssets.createPasswordBgPage;
    }
  }

  /// Masked mobile entered on the forgot-password form (not session iUser).
  String get maskedEnteredPhone {
    final parsed = int.tryParse(phoneNoCTRL.text.trim());
    if (parsed == null || parsed == 0) return phoneNoCTRL.text.trim();
    return parsed.toHidePhoneNo;
  }

  Future<void> verifyOTP() async {
    isLoading(true);
    var res = await WAuthApi.verifyOtp(otpCTRL.text);
    isLoading(false);
    if (res.isSuccess) {
      toast(res.m, MessageEnum.success);
      flag(ForgotPassEnum.password);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }

  Future<void> createPassword() async {
    isLoading(true);
    var res = await WAuthApi.forgotChangePassword(
      password: confirmPasswordCTRL.text.trim(),
    );
    isLoading(false);
    if (res.isSuccess) {
      app.recoveryPartnerId = null;
      Get.offAllNamed(Routes.signIn);
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }

  Future<void> resendOTP() async {
    var res = await WAuthApi.resendOtp();
    if (res.isSuccess) {
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }

  Future<void> forgotPassword() async {
    isLoading(true);
    var res = await WAuthApi.forgotPassword(phoneNo: phoneNoCTRL.text);
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      // #region agent log
      debugNdjson('A,B,C,D,E', 'forgot_password_page_ctrl.dart:forgotPassword',
          'forgotPassword success — phone sources', {
        'phoneNoCTRL': phoneNoCTRL.text,
        'iUserMobile': app.iUser.mobileNumber,
        'iUserHide': app.iUser.mobileNumber.toHidePhoneNo,
        'wUserMobile': app.wUser.mobileNumber,
        'apiPartnerMobile': res.r?.mobileNumber,
        'apiPartnerId': res.r?.id,
        'recoveryPartnerId': app.recoveryPartnerId,
      });
      // #endregion
      flag(ForgotPassEnum.otp);
      // toast(res.m, MessageEnum.success);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }

  @override
  void onClose() {
    app.recoveryPartnerId = null;
    phoneNoCTRL.dispose();
    otpCTRL.dispose();
    passwordCTRL.dispose();
    confirmPasswordCTRL.dispose();
    super.onClose();
  }
}
