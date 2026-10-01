import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/secondary/desktop_secondary_landing_view.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/phone_secondary_landing_view.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_landing_page_ctrl.dart';

class SecondaryLandingPage extends StatelessWidget {
  final SecondaryLandingPageCtrl c = Get.put(SecondaryLandingPageCtrl());

  SecondaryLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneSecondaryLandingView();
    } else {
      return DesktopSecondaryLandingView();
    }
  }
}
