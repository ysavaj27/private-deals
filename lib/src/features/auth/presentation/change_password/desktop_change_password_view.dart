import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/auth/presentation/change_password/change_password_page_ctrl.dart';

class DesktopChangePasswordView extends StatelessWidget {
  final ChangePasswordPageCtrl c = Get.find<ChangePasswordPageCtrl>();

  DesktopChangePasswordView({super.key});

  final GlobalKey<FormState> desktopKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Change Password'), centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),
            CustomCardWidget(
              radius: 12,
              padding: const EdgeInsets.symmetric(vertical: 52, horizontal: 88),
              child: Form(
                key: desktopKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
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
                        const SizedBox(width: 130),
                        Expanded(
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
                      ],
                    ),
                    const SizedBox(height: 100),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() {
                          return CustomElevatedButton(
                            height: 58,
                            width: 279,
                            text: "Change Password",
                            isLoading: c.isLoading.value,
                            onPressed: () {
                              if (desktopKey.currentState?.validate() ??
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
      ),
    );
  }
}
