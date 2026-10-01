import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/auth/presentation/login/login_page_ctrl.dart';

class DesktopLoginView extends StatelessWidget {
  final LoginPageCtrl c = Get.find<LoginPageCtrl>();

  DesktopLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5E2F2),
      body: Stack(
        alignment: Alignment.center,
        children: [
          const AuthBackground(),
          Positioned(
            left: 65,
            top: 43,
            child: Image.asset(
              AppAssets.newLogo,
              height: 72,
            ),
          ),
          CustomCardWidget(
            borderColor: context.theme.dividerColor.withValues(alpha: 0.4),
            width: 564.66,
            radius: 16,
            color: context.theme.colorScheme.surface.withValues(alpha: 0.94),
            padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 50),
            child: Form(
              key: c.desktopKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Welcome back! Please login to \nyour account.",
                    style: TextStyle(
                      fontSize: 16,
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 45),
                  TitleTextField(
                    isDense: false,
                    isBorder: true,
                    borderColor: context.theme.dividerColor,
                    isAuthFocusBorder: true,
                    fillColor: Colors.transparent,
                    name: 'Mobile Number',
                    autofocus: true,
                    controller: c.mobileNoCTRL,
                    textInputAction: TextInputAction.next,
                    prefixIcon:
                        Icon(Icons.phone, color: context.theme.disabledColor),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
                    ],
                    autofillHints: const [AutofillHints.username],
                    validator: (p0) {
                      if (p0 == null || p0.isEmpty) {
                        return 'Please enter your registered mobile number';
                      } else if (int.tryParse(p0) == null) {
                        return 'Enter valid mobile number';
                      } else if (p0.length != 10) {
                        return 'Enter valid 10 digit mobile number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  Obx(() {
                    return TitleTextField(
                      isBorder: true,
                      isAuthFocusBorder: true,
                      fillColor: Colors.transparent,
                      borderColor: context.theme.dividerColor,
                      name: 'Password',
                      isDense: false,
                      controller: c.passwordCTRL,
                      obscureText: c.isObscure.value,
                      textInputAction: TextInputAction.done,
                      maxLines: 1,
                      prefixIcon: Icon(Icons.vpn_key,
                          color: context.theme.disabledColor),
                      autofillHints: const [AutofillHints.password],
                      suffixIcon: IconButton(
                        iconSize: 20,
                        splashRadius: 20,
                        onPressed: () => c.isObscure.toggle(),
                        icon: Icon(
                          c.isObscure.isTrue
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: context.theme.disabledColor,
                        ),
                      ),
                      validator: (p0) {
                        if (p0 == null || p0.isEmpty) {
                          return 'Please enter password';
                        } else if (p0.trim().length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      onFieldSubmitted: (p0) {
                        if (c.desktopKey.currentState?.validate() ?? false) {
                          c.onPress();
                        }
                      },
                    );
                  }),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.blue,
                        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                      ),
                      onPressed: () {
                        Get.toNamed(Routes.forgotPasswordPage);
                      },
                      child: const Text("Forgot Password?"),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Get.toNamed(Routes.inquiryPage);
                        },
                        child: const Text(
                          "Request for new account",
                          style: TextStyle(
                              color: AppColors.lightBlue,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      const Spacer(),
                      Obx(() {
                        return CustomElevatedButton(
                          radius: 22,
                          width: 222.25,
                          backgroundColor: context.theme.iconTheme.color,
                          color: context.theme.scaffoldBackgroundColor,
                          fontWeight: FontWeight.bold,
                          size: const Size(222.25, 50),
                          text: 'Log In',
                          isLoading: c.isLoading.value,
                          onPressed: () {
                            if (c.desktopKey.currentState?.validate() ??
                                false) {
                              c.onPress();
                            }
                          },
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
