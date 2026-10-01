import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/auth/presentation/login/desktop_login_view.dart';
import 'package:private_deals/src/features/auth/presentation/login/login_page_ctrl.dart';
import 'package:private_deals/src/features/auth/presentation/login/phone_login_view.dart';

class LoginPage extends StatelessWidget {
  final LoginPageCtrl c = Get.put(LoginPageCtrl());

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneLoginView();
    } else {
      return DesktopLoginView();
    }
  }
}

/*
*     return Scaffold(
      // appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: SizedBox(
          // color: Colors.grey.withValues(alpha: 0.1),
          width: 360,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SVGImage(
                    AppAssets.loginBg,
                    height: 370,
                    width: 370,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Welcome back! Please login to your account.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                        CustomTextField(
                          label: "Enter Mobile",
                          controller: c.mobileNoCTRL,
                          prefixIcon: const Icon(Icons.phone),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
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
                          return CustomTextField(
                            controller: c.passwordCTRL,
                            obscureText: c.isObscure.value,
                            label: "Enter Password",
                            maxLines: 1,
                            prefixIcon: const Icon(Icons.vpn_key, size: 20),
                            suffixIcon: IconButton(
                              iconSize: 20,
                              splashRadius: 20,
                              onPressed: () => c.isObscure.toggle(),
                              icon: Icon(c.isObscure.isTrue
                                  ? Icons.visibility
                                  : Icons.visibility_off),
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
                        const SizedBox(height: 3),

                        const SizedBox(height: 20),
                        Obx(() {
                          return CustomElevatedButton(
                            text: 'Login',
                            isLoading: c.isLoading.value,
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                c.onPress();
                              }
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
*/
