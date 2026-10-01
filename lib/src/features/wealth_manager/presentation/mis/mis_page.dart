import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/mis/desktop_mis_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/mis/mis_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/mis/phone_mis_view.dart';

class MISPage extends StatelessWidget {
  final MISPageCtrl c = Get.put(MISPageCtrl());

  MISPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneMisView();
    } else {
      return DesktopMisView();
    }
  }
}
