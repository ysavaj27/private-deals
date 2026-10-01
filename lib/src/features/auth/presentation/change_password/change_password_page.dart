import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/auth/presentation/change_password/change_password_page_ctrl.dart';
import 'package:private_deals/src/features/auth/presentation/change_password/desktop_change_password_view.dart';
import 'package:private_deals/src/features/auth/presentation/change_password/phone_change_password_view.dart';

class ChangePasswordPage extends StatelessWidget {
  final ChangePasswordPageCtrl c = Get.put(ChangePasswordPageCtrl());

  ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneChangePasswordView();
    } else {
      return DesktopChangePasswordView();
    }
  }
}

/*  body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(
              maxWidth: 1300, minWidth: 400, minHeight: 600),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Change Password", style: context.textTheme.headlineSmall),
                const SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(
                      width: 300,
                      child: Obx(() {
                        return ProfileTextField(
                          isRequired: false,
                          name: "New Password",
                          hintText: "Enter New Password",
                          controller: c.newPasswordCTRL,
                          obscureText: c.newPassObscure.value,
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
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 300,
                      child: Obx(() {
                        return ProfileTextField(
                          isRequired: false,
                          obscureText: c.confirmPassObscure.value,
                          name: "Confirm Password",
                          hintText: "Enter Confirm Password",
                          controller: c.confirmPasswordCTRL,
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
                SizedBox(height: 20),
                Obx(() {
                  return CustomElevatedButton(
                    width: 200,
                    text: "Change Password",
                    isLoading: c.isLoading.value,
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {}
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),*/
