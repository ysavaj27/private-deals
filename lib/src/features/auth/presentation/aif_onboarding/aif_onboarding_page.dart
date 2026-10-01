import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/auth/presentation/aif_onboarding/aif_onboarding_page_ctrl.dart';
import 'package:private_deals/src/features/auth/presentation/aif_onboarding/desktop_aif_onboarding_view.dart';
import 'package:private_deals/src/features/auth/presentation/aif_onboarding/phone_aif_onboarding_view.dart';

class AifOnboardingPage extends StatelessWidget {
  final AifOnboardingPageCtrl c = Get.put(AifOnboardingPageCtrl());

  AifOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneAifOnboardingView();
    } else {
      return DesktopAifOnboardingView();
    }
  }
}
