import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/desktop_investor_transaction_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/investor_transaction_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/phone_investor_transaction_view.dart';

class InvestorTransactionPage extends StatelessWidget {
  final InvestorTransactionPageCtrl c = Get.put(InvestorTransactionPageCtrl());

  InvestorTransactionPage({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!c.isClosed) c.applyRouteSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneInvestorTransactionView();
    } else {
      return DesktopInvestorTransactionView();
    }
  }
}
