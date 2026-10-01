import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/investors/presentation/legacy/desktop_investors_view.dart';
import 'package:private_deals/src/features/investors/presentation/legacy/investors_page_ctrl.dart';
import 'package:private_deals/src/features/investors/presentation/legacy/phone_investors_view.dart';

class InvestorsPage extends StatelessWidget {
  final InvestorsPageCtrl c = Get.put(InvestorsPageCtrl());

  InvestorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneInvestorsView();
    } else {
      return DesktopInvestorsView();
    }
  }
}
