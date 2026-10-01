import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/sell_request/desktop_sell_request_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/sell_request/phone_sell_request_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/sell_request/sell_request_page_ctrl.dart';

class SellRequestPage extends StatelessWidget {
  final SellRequestPageCtrl c = Get.put(SellRequestPageCtrl());

  SellRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneSellRequestView();
    } else {
      return DesktopSellRequestView();
    }
  }
}
