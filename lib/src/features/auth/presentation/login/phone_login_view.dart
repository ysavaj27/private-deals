import 'package:flutter/gestures.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/auth/presentation/login/login_page_ctrl.dart';

class PhoneLoginView extends StatelessWidget {
  final LoginPageCtrl c = Get.find<LoginPageCtrl>();

  PhoneLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5E2F2),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackground(),
          SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 20),
                  child: Image.asset(
                    AppAssets.newLogo,
                    height: 45,
                  ),
                ),
                Center(
                  child: FadeInUp(
                    child: CustomCardWidget(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 29),
                      color: context.theme.colorScheme.surface
                          .withValues(alpha: 0.94),
                      borderColor:
                          context.theme.dividerColor.withValues(alpha: 0.4),
                      child: Form(
                        key: c.phoneKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Text(
                            'Welcome to Private Deals',
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Manage your business, connect with investors, \nand grow with confidence.',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 35),
                          TitleTextField(
                            isBorder: true,
                            borderColor: context.theme.dividerColor,
                            isAuthFocusBorder: true,
                            fillColor: Colors.transparent,
                            name: 'Mobile Number',
                            // autofocus: true,
                            keyboardType: TextInputType.number,
                            controller: c.mobileNoCTRL,
                            prefixIcon: Icon(Icons.phone,
                                color: context.theme.disabledColor),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp('[0-9+]')),
                            ],
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
                          const SizedBox(height: 20),
                          Obx(() {
                            return TitleTextField(
                              controller: c.passwordCTRL,
                              obscureText: c.isObscure.value,
                              isBorder: true,
                              borderColor: context.theme.dividerColor,
                              isAuthFocusBorder: true,
                              fillColor: Colors.transparent,
                              name: 'Enter Password',
                              // autofocus: true,
                              maxLines: 1,
                              prefixIcon: Icon(Icons.vpn_key,
                                  color: context.theme.disabledColor, size: 20),
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
                            );
                          }),
                          // const SizedBox(height: 3),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.blue,
                                padding:
                                    const EdgeInsets.fromLTRB(10, 5, 0, 10),
                              ),
                              onPressed: () {
                                Get.toNamed(Routes.forgotPasswordPage);
                                // Get.to(() => ForgotPasswordPage());
                              },
                              child: const Text("Forgot Password?"),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Obx(() {
                            return CustomElevatedButton(
                              text: 'Login',
                              height: 38,
                              backgroundColor: context.theme.iconTheme.color,
                              color: context.theme.scaffoldBackgroundColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              isLoading: c.isLoading.value,
                              onPressed: () {
                                if (c.phoneKey.currentState?.validate() ??
                                    false) {
                                  c.onPress();
                                }
                              },
                            );
                          }),
                          const SizedBox(height: 20),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      "You don’t have a partner account yet? ",
                                ),
                                TextSpan(
                                  text: 'Request a new account',
                                  style: TextStyle(
                                    color: AppColors.blue,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.toNamed(Routes.inquiryPage);
                                      // Get.to(() => InquiryPage());
                                    },
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),

                          // Center(
                          //   child: TextButton(
                          //     onPressed: () {
                          //       Get.to(() => InquiryPage());
                          //     },
                          //     child: const Text(
                          //       "Request for new account",
                          //       style: TextStyle(
                          //           color: AppColors.blue,
                          //           fontSize: 12,
                          //           decoration: TextDecoration.underline,
                          //           fontWeight: FontWeight.w400),
                          //     ),
                          //   ),
                          // ),
                          // Text(
                          //   "If you don't have an partner account please request for new account",
                          //   style: TextStyle(
                          //     fontSize: 12,
                          //     color: context.theme.colorScheme.onSurfaceVariant,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }
}
