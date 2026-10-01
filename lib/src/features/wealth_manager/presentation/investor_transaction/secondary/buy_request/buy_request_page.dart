import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/buy_request/buy_request_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/buy_request/desktop_buy_request_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/buy_request/phone_buy_request_view.dart';

class BuyRequestPage extends StatelessWidget {
  final BuyRequestPageCtrl c = Get.put(BuyRequestPageCtrl());

  BuyRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneBuyRequestView();
    } else {
      return DesktopBuyRequestView();
    }
  }
}
