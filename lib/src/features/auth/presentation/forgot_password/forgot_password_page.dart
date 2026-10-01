import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/auth/presentation/forgot_password/desktop_forgot_password_view.dart';
import 'package:private_deals/src/features/auth/presentation/forgot_password/forgot_password_page_ctrl.dart';
import 'package:private_deals/src/features/auth/presentation/forgot_password/phone_forgot_password_view.dart';

class ForgotPasswordPage extends StatelessWidget {
  final ForgotPasswordPageCtrl c = Get.put(ForgotPasswordPageCtrl());

  ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneForgotPasswordView();
    } else {
      return DesktopForgotPasswordView();
    }
  }
}
