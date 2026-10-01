import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/auth/presentation/change_password/change_password_page_ctrl.dart';

class PhoneChangePasswordView extends StatelessWidget {
  final ChangePasswordPageCtrl c = Get.find<ChangePasswordPageCtrl>();

  PhoneChangePasswordView({super.key});

  final GlobalKey<FormState> phoneKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: CustomCardWidget(
        radius: 12,
        margin: EdgeInsets.all(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Form(
            key: phoneKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeInUp(
                  child: Obx(() {
                    return TitleTextField(
                      isRequired: true,
                      name: "New Password",
                      hintText: "Enter New Password",
                      controller: c.newPasswordCTRL,
                      obscureText: c.newPassObscure.value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        iconSize: 20,
                        splashRadius: 20,
                        onPressed: () => c.newPassObscure.toggle(),
                        icon: Icon(c.newPassObscure.isTrue
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  delay: Duration(milliseconds: 200),
                  child: Obx(() {
                    return TitleTextField(
                      isRequired: true,
                      obscureText: c.confirmPassObscure.value,
                      name: "Confirm Password",
                      hintText: "Enter Confirm Password",
                      controller: c.confirmPasswordCTRL,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != c.newPasswordCTRL.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        iconSize: 20,
                        splashRadius: 20,
                        onPressed: () => c.confirmPassObscure.toggle(),
                        icon: Icon(c.confirmPassObscure.isTrue
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),
                FadeInUp(
                  delay: Duration(milliseconds: 400),
                  child: Obx(() {
                    return CustomElevatedButton(
                      height: context.isPhone ? 36 : 58,
                      width: context.isPhone ? 176 : 279,
                      fontSize: context.isPhone ? 14 : null,
                      fontWeight: context.isPhone ? FontWeight.w500 : null,
                      text: "Change Password",
                      isLoading: c.isLoading.value,
                      onPressed: () {
                        if (phoneKey.currentState?.validate() ?? false) {
                          c.onPress();
                        }
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
