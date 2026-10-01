import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_landing_page/desktop_pre_ipo_landing_view.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_landing_page/phone_pre_ipo_landing_view.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_landing_page/pre_ipo_landing_page_ctrl.dart';

class PreIPOLandingPage extends StatelessWidget {
  final PreIPOLandingPageCtrl c = Get.put(PreIPOLandingPageCtrl());

  PreIPOLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return  PhonePreIPOLandingView();
    } else {
      return  DesktopPreIPOLandingView();
    }
  }
}
