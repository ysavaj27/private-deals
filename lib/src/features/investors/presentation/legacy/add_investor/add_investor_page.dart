import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/investors/presentation/legacy/add_investor/add_investor_page_ctrl.dart';
import 'package:private_deals/src/features/investors/presentation/legacy/add_investor/desktop_add_investor_view.dart';
import 'package:private_deals/src/features/investors/presentation/legacy/add_investor/phone_add_investor_view.dart';

class AddInvestorPage extends StatelessWidget {
  final AddInvestorPageCtrl c = Get.put(AddInvestorPageCtrl());

  AddInvestorPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneAddInvestorView();
    } else {
      return DesktopAddInvestorView();
    }
  }
}
