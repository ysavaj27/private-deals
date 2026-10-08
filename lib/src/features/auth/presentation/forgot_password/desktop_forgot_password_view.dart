import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/auth/presentation/forgot_password/forgot_password_page_ctrl.dart';

class DesktopForgotPasswordView extends StatelessWidget {
  final ForgotPasswordPageCtrl c = Get.find<ForgotPasswordPageCtrl>();

  DesktopForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5E2F2),
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Stack(
        alignment: Alignment.center,
        children: [
          const AuthBackground(),
          Positioned(
            left: 65,
            top: 43,
            child: Image.asset(AppAssets.newLogo, height: 72),
          ),
          DesktopMainWidget(),
        ],
      ),
    );
  }
}

class DesktopMainWidget extends StatelessWidget {
  final ForgotPasswordPageCtrl c = Get.find<ForgotPasswordPageCtrl>();

  DesktopMainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (c.flag()) {
        case ForgotPassEnum.mobile:
          return DMobileWidget();
        case ForgotPassEnum.otp:
          return DOtpWidget();
        case ForgotPassEnum.password:
          return DPasswordWidget();
      }
    });
  }
}

class DPasswordWidget extends StatelessWidget {
  final ForgotPasswordPageCtrl c = Get.find<ForgotPasswordPageCtrl>();

  DPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      width: 564.66,
      radius: 16,
      color: context.theme.colorScheme.surface.withValues(alpha: 0.94),
      padding: EdgeInsets.symmetric(horizontal: 65, vertical: 50),
      borderColor: context.theme.dividerColor.withValues(alpha: 0.4),
      child: Form(
        key: c.dPassKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Create Password",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 17),
            Text(
              "Password should contain at least 1 upper case, 1 lower case, 1 numeric character, 1 special character and 8 characters long.",
              style: TextStyle(
                fontSize: 16,
                color: context.theme.disabledColor,
              ),
            ),
            const SizedBox(height: 45),
            Obx(() {
              return TitleTextField(
                isDense: false,
                isBorder: true,
                borderColor: context.theme.dividerColor,
                isAuthFocusBorder: true,
                fillColor: Colors.transparent,
                autofocus: true,
                controller: c.passwordCTRL,
                obscureText: c.passObscure.value,
                keyboardType: TextInputType.visiblePassword,
                name: "New Password",
                textInputAction: TextInputAction.next,
                maxLines: 1,
                prefixIcon: Icon(
                  Icons.vpn_key_outlined,
                  color: context.theme.disabledColor,
                  size: 20,
                ),
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
                // onChanged: (p0) => c.password = p0,
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
            const SizedBox(height: 40),
            Obx(() {
              return TitleTextField(
                isDense: false,
                isBorder: true,
                borderColor: context.theme.dividerColor,
                isAuthFocusBorder: true,
                fillColor: Colors.transparent,
                controller: c.confirmPasswordCTRL,
                obscureText: c.confirmPassObscure.value,
                keyboardType: TextInputType.visiblePassword,
                name: "Confirm Password",
                textInputAction: TextInputAction.done,
                maxLines: 1,
                prefixIcon: Icon(
                  Icons.vpn_key_outlined,
                  color: context.theme.disabledColor,
                  size: 20,
                ),
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
                validator: (p0) {
                  if (p0 == null || p0.isEmpty) {
                    return 'Please enter confirm password';
                  } else if (p0.trim().length < 6) {
                    return 'Password must be at least 6 characters';
                  } else if (p0.trim() != c.passwordCTRL.text.trim()) {
                    return 'Confirm password not matching';
                  }
                  return null;
                },
                onFieldSubmitted: (p0) {
                  if (c.dPassKey.currentState?.validate() ?? false) {
                    c.createPassword();
                  }
                },
              );
            }),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  return CustomElevatedButton(
                    radius: 22,
                    width: 222.25,
                    backgroundColor: context.theme.iconTheme.color,
                    color: context.theme.scaffoldBackgroundColor,
                    fontWeight: FontWeight.bold,
                    size: const Size(222.25, 50),
                    text: 'Continue',
                    isLoading: c.isLoading.value,
                    onPressed: () {
                      if (c.dPassKey.currentState?.validate() ?? false) {
                        c.createPassword();
                      }
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 15),
            Center(
              child: TextButton(
                onPressed: Get.back,
                child: Text(
                  "Back to login",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.lightBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DOtpWidget extends StatelessWidget {
  final ForgotPasswordPageCtrl c = Get.find<ForgotPasswordPageCtrl>();

  DOtpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      width: 564.66,
      radius: 16,
      color: context.theme.colorScheme.surface.withValues(alpha: 0.94),
      padding: EdgeInsets.symmetric(horizontal: 65, vertical: 50),
      borderColor: context.theme.dividerColor.withValues(alpha: 0.4),
      child: Form(
        key: c.dOtpKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter OTP",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 17),
            Text(
              "A message with the verification code has been sent to \n${c.maskedEnteredPhone}. Please enter the code to continue.",
              style: TextStyle(
                fontSize: 16,
                color: context.theme.disabledColor,
              ),
            ),
            const SizedBox(height: 45),
            TitleTextField(
              isDense: false,
              isBorder: true,
              borderColor: context.theme.dividerColor,
              isAuthFocusBorder: true,
              fillColor: Colors.transparent,
              name: 'OTP',
              autofocus: true,
              keyboardType: TextInputType.number,
              // maxLength: 6,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9``]')),
              ],
              controller: c.otpCTRL,
              validator: (p0) {
                if (p0 == null || p0.isEmpty) {
                  return 'Please enter otp';
                } else if (int.tryParse(p0.trim()) == null) {
                  return 'Please enter valid otp';
                } else if (p0.trim().length != 6) {
                  return 'Please enter 6 digit otp code';
                }
                return null;
              },
              prefixIcon: Icon(
                Icons.phone_outlined,
                size: 20,
                color: context.theme.disabledColor,
              ),
              onFieldSubmitted: (p0) {
                if (c.dOtpKey.currentState?.validate() ?? false) {
                  c.verifyOTP();
                }
              },
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: context.theme.disabledColor,
                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                ),
                onPressed: () {
                  c.resendOTP();
                },
                child: const Text("Resend OTP"),
              ),
            ),
            const SizedBox(height: 47),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  return CustomElevatedButton(
                    radius: 22,
                    width: 222.25,
                    backgroundColor: context.theme.iconTheme.color,
                    color: context.theme.scaffoldBackgroundColor,
                    fontWeight: FontWeight.bold,
                    size: const Size(222.25, 50),
                    text: 'Verify Code',
                    isLoading: c.isLoading.value,
                    onPressed: () {
                      if (c.dOtpKey.currentState?.validate() ?? false) {
                        c.verifyOTP();
                      }
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 15),
            Center(
              child: TextButton(
                onPressed: Get.back,
                child: Text(
                  "Back to login",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.lightBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DMobileWidget extends StatelessWidget {
  final ForgotPasswordPageCtrl c = Get.find<ForgotPasswordPageCtrl>();

  DMobileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      width: 564.66,
      radius: 16,
      color: context.theme.colorScheme.surface.withValues(alpha: 0.94),
      padding: EdgeInsets.symmetric(horizontal: 65, vertical: 50),
      borderColor: context.theme.dividerColor.withValues(alpha: 0.4),
      child: Form(
        key: c.dMobileKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Forgot password",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 17),
            Text(
              "Enter your mobile number to reset your \npassword.",
              style: TextStyle(
                fontSize: 16,
                color: context.theme.disabledColor,
              ),
            ),
            const SizedBox(height: 44),
            TitleTextField(
              isDense: false,
              isBorder: true,
              borderColor: context.theme.dividerColor,
              isAuthFocusBorder: true,
              fillColor: Colors.transparent,
              name: "Mobile No",
              autofocus: true,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
              ],
              textInputAction: TextInputAction.done,
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
              prefixIcon: Icon(
                Icons.phone_outlined,
                color: context.theme.disabledColor,
                size: 20,
              ),
              onFieldSubmitted: (p0) {
                if (c.dMobileKey.currentState?.validate() ?? false) {
                  c.forgotPassword();
                }
              },
            ),
            const SizedBox(height: 57),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  return CustomElevatedButton(
                    radius: 22,
                    width: 222,
                    backgroundColor: context.theme.iconTheme.color,
                    color: context.theme.scaffoldBackgroundColor,
                    size: const Size(222.25, 50),
                    fontWeight: FontWeight.bold,
                    text: 'Verify',
                    isLoading: c.isLoading.value,
                    onPressed: () {
                      if (c.dMobileKey.currentState?.validate() ?? false) {
                        c.forgotPassword();
                      }
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 15),
            Center(
              child: TextButton(
                onPressed: Get.back,
                child: Text(
                  "Back to login",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.lightBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
