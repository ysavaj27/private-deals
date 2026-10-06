import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/investor_transaction_page_ctrl.dart';

class PhoneInvestorTransactionView extends StatelessWidget {
  final InvestorTransactionPageCtrl c = Get.put(InvestorTransactionPageCtrl());

  PhoneInvestorTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        children: [
          TabBar(
            controller: c.tabController,
            splashBorderRadius: BorderRadius.circular(50),
            tabs: c.tabs(),
          ),
          Expanded(
            child: TabBarView(
              controller: c.tabController,
              children: c.tabViews(),
            ),
          ),
        ],
      ),
    );
  }
}
