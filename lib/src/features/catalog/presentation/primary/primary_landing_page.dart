import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/primary/desktop_primary_landing_view.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_landing_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/phone_primary_landing_view.dart';

class PrimaryLandingPage extends StatelessWidget {
  final PrimaryLandingPageCtrl c = Get.put(PrimaryLandingPageCtrl());

  PrimaryLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhonePrimaryLandingView();
    } else {
      return DesktopPrimaryLandingView();
    }
  }
}
