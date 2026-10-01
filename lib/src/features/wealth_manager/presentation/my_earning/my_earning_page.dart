import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/my_earning/desktop_my_earning_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/my_earning/my_earning_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/my_earning/phone_my_earning_view.dart';

class MyEarningPage extends StatelessWidget {
  final MyEarningPageCtrl c = Get.put(MyEarningPageCtrl());

  MyEarningPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneMyEarningView();
    } else {
      return DesktopMyEarningView();
    }
  }
}
