import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/auth/presentation/forgot_password/forgot_password_page_ctrl.dart';

class PhoneForgotPasswordView extends StatelessWidget {
  final ForgotPasswordPageCtrl c = Get.find<ForgotPasswordPageCtrl>();

  PhoneForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5E2F2),
      appBar: AppBar(
        title: const Text("Forgot password"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackground(),
          SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 10),
                  child: Image.asset(
                    AppAssets.newLogo,
                    height: 45,
                  ),
                ),
                Center(child: MainWidget()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MainWidget extends StatelessWidget {
  final ForgotPasswordPageCtrl c = Get.find<ForgotPasswordPageCtrl>();

  MainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (c.flag()) {
        case ForgotPassEnum.mobile:
          return MobileWidget();
        case ForgotPassEnum.otp:
          return OTPWidget();
        case ForgotPassEnum.password:
          return PasswordWidget();
      }
    });
  }
}

class MobileWidget extends StatelessWidget {
  final ForgotPasswordPageCtrl c = Get.find<ForgotPasswordPageCtrl>();

  MobileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: CustomCardWidget(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 29),
        color: context.theme.colorScheme.surface.withValues(alpha: 0.94),
        borderColor: context.theme.dividerColor.withValues(alpha: 0.4),
        child: Form(
          key: c.mMobileKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Forgot password',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter your mobile number to reset your \npassword.',
                style: TextStyle(
                    fontSize: 12,
                    color: context.theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 35),
              TitleTextField(
                isDense: true,
                isBorder: true,
                borderColor: context.theme.dividerColor,
                isAuthFocusBorder: true,
                fillColor: Colors.transparent,
                name: 'Mobile Number',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
                ],
                controller: c.phoneNoCTRL,
                validator: (p0) {
                  if (p0 == null || p0.isEmpty) {
                    return 'Please enter mobile no';
                  } else if (int.tryParse(p0.trim()) == null) {
                    return 'Please enter valid mobile no';
                  } else if (p0.trim().length != 10) {
                    return 'Please enter 10 digit mobile no';
                  }
                  return null;
                },
                prefixIcon: Icon(Icons.phone_outlined,
                    color: context.theme.disabledColor, size: 20),
                onFieldSubmitted: (p0) {
                  if (c.dMobileKey.currentState?.validate() ?? false) {
                    c.forgotPassword();
                  }
                },
              ),
              const SizedBox(height: 60),
              Obx(() {
                return CustomElevatedButton(
                  size: Size(context.width, 38),
                  backgroundColor: context.theme.iconTheme.color,
                  color: context.theme.scaffoldBackgroundColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  text: 'Send Verification Code',
                  isLoading: c.isLoading.value,
                  onPressed: () {
                    if (c.mMobileKey.currentState?.validate() ?? false) {
                      c.forgotPassword();
                    }
                  },
                );
              }),
              // const SizedBox(height: 5),
              Center(
                child: TextButton(
                  onPressed: Get.back,
                  child: Text(
                    "Back to Login",
                    style: TextStyle(
                        color: AppColors.lightBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              // const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class OTPWidget extends StatelessWidget {
  final ForgotPasswordPageCtrl c = Get.find<ForgotPasswordPageCtrl>();

  OTPWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: CustomCardWidget(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 29),
        color: context.theme.colorScheme.surface.withValues(alpha: 0.94),
        borderColor: context.theme.dividerColor.withValues(alpha: 0.4),
        child: Form(
          key: c.mOtpKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter OTP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                "A message with the verification code has been sent to \n${app.iUser.mobileNumber.toHidePhoneNo}. Please enter the code to continue.",
                style: TextStyle(
                    fontSize: 12,
                    color: context.theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 35),
              OtpTextField(
                controller: c.otpCTRL,
                validator: (p0) {
                  if (p0 == null || p0.isEmpty) {
                    return 'Please enter otp';
                  } else if (int.tryParse(p0.trim()) == null) {
                    return 'Please enter valid otp';
                  }
                  return null;
                },
                onCompleted: (p0) {
                  if (c.mOtpKey.currentState?.validate() ?? false) {
                    c.verifyOTP();
                  }
                },
              ),

              // TitleTextField(
              //   isBorder: true,
              //   isDense: true,
              //   borderColor: context.theme.dividerColor,
              //   isAuthFocusBorder: true,
              //   fillColor: Colors.transparent,
              //   name: "OTP",
              //   maxLength: 6,
              //   keyboardType: TextInputType.number,
              //   inputFormatters: [
              //     FilteringTextInputFormatter.allow(RegExp('[0-9``]')),
              //   ],
              //   controller: c.otpCTRL,
              //   validator: (p0) {
              //     if (p0 == null || p0.isEmpty) {
              //       return 'Please enter otp';
              //     } else if (int.tryParse(p0.trim()) == null) {
              //       return 'Please enter valid otp';
              //     } else if (p0.trim().length != 6) {
              //       return 'Please enter 6 digit otp code';
              //     }
              //     return null;
              //   },
              //   prefixIcon: Icon(Icons.phone_outlined,
              //       color: context.theme.disabledColor, size: 20),
              // ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.lightBlue,
                    // foregroundColor: context.theme.disabledColor,
                    padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                  ),
                  onPressed: () {
                    c.resendOTP();
                  },
                  child: const Text("Resend OTP"),
                ),
              ),
              const SizedBox(height: 30),
              Obx(() {
                return CustomElevatedButton(
                  size: Size(context.width, 38),
                  backgroundColor: context.theme.iconTheme.color,
                  color: context.theme.scaffoldBackgroundColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  text: 'Verify',
                  isLoading: c.isLoading.value,
                  onPressed: () {
                    if (c.mOtpKey.currentState?.validate() ?? false) {
                      c.verifyOTP();
                    }
                  },
                );
              }),
              // const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: Get.back,
                  child: Text(
                    "Back to Login",
                    style: TextStyle(
                        color: AppColors.lightBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordWidget extends StatelessWidget {
  final ForgotPasswordPageCtrl c = Get.find<ForgotPasswordPageCtrl>();

  PasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: CustomCardWidget(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 29),
        color: context.theme.colorScheme.surface.withValues(alpha: 0.94),
        borderColor: context.theme.dividerColor.withValues(alpha: 0.4),
        child: Form(
          key: c.mPassKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create Password',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                'Password should contain at least 1 upper case, 1 lower case, 1 numeric character, 1 special character and 8 characters long.',
                style: TextStyle(
                    fontSize: 12,
                    color: context.theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 35),
              Obx(() {
                return TitleTextField(
                  isBorder: true,
                  isDense: true,
                  controller: c.passwordCTRL,
                  borderColor: context.theme.dividerColor,
                  isAuthFocusBorder: true,
                  fillColor: Colors.transparent,
                  name: "New Password",
                  obscureText: c.passObscure.value,
                  maxLines: 1,
                  prefixIcon: Icon(Icons.vpn_key_outlined,
                      color: context.theme.disabledColor, size: 20),
                  suffixIcon: IconButton(
                    iconSize: 20,
                    splashRadius: 20,
                    onPressed: () => c.passObscure.toggle(),
                    icon: Icon(
                      c.passObscure.isTrue
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: context.theme.disabledColor,
                    ),
                  ),
                  onChanged: (p0) => c.password = p0,
                  validator: (p0) {
                    if (p0 == null || p0.isEmpty) {
                      return 'Please enter new password';
                    } else if (p0.trim().length < 6) {
                      return 'Password must be at least 6 characters in length';
                    }
                    return null;
                  },
                );
              }),
              const SizedBox(height: 20),
              Obx(() {
                return TitleTextField(
                  isBorder: true,
                  isDense: true,
                  borderColor: context.theme.dividerColor,
                  isAuthFocusBorder: true,
                  fillColor: Colors.transparent,
                  controller: c.confirmPasswordCTRL,
                  obscureText: c.confirmPassObscure.value,
                  name: "Confirm Password",
                  keyboardType: TextInputType.visiblePassword,
                  maxLines: 1,
                  prefixIcon: Icon(Icons.vpn_key_outlined,
                      color: context.theme.disabledColor, size: 20),
                  suffixIcon: IconButton(
                    iconSize: 20,
                    splashRadius: 20,
                    onPressed: () => c.confirmPassObscure.toggle(),
                    icon: Icon(
                      c.confirmPassObscure.isTrue
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: context.theme.disabledColor,
                    ),
                  ),
                  onFieldSubmitted: (p0) {
                    if (c.mPassKey.currentState?.validate() ?? false) {
                      c.createPassword();
                    }
                  },
                  validator: (p0) {
                    if (p0 == null || p0.isEmpty) {
                      return 'Please enter confirm password';
                    } else if (p0.trim().length < 6) {
                      return 'Password must be at least 6 characters';
                    } else if (p0.trim() != c.password.trim()) {
                      return 'Confirm password not matching';
                    }
                    return null;
                  },
                );
              }),
              const SizedBox(height: 50),
              Obx(() {
                return CustomElevatedButton(
                  size: Size(context.width, 38),
                  backgroundColor: context.theme.iconTheme.color,
                  color: context.theme.scaffoldBackgroundColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  text: 'Continue',
                  isLoading: c.isLoading.value,
                  onPressed: () {
                    if (c.mPassKey.currentState?.validate() ?? false) {
                      c.createPassword();
                    }
                  },
                );
              }),
              Center(
                child: TextButton(
                  onPressed: Get.back,
                  child: Text(
                    "Back to Login",
                    style: TextStyle(
                        color: AppColors.lightBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
