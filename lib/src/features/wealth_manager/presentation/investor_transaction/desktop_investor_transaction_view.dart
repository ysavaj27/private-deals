import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/investor_transaction_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_buy_transaction/desktop_pre_ipo_buy_transaction_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_sell_transaction/desktop_pre_ipo_sell_transaction_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/primary/desktop_primary_transaction_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/desktop_secondary_transaction_view.dart';

class DesktopInvestorTransactionView extends StatelessWidget {
  final InvestorTransactionPageCtrl c = Get.find<InvestorTransactionPageCtrl>();

  DesktopInvestorTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const TitleText("Investor Transaction"),
                const Spacer(),
                Visibility(
                  visible: app.wUser.isPrimaryAccess,
                  child: TabButton(
                    title: "Private Equity",
                    type: TransactionTypeEnum.primary,
                    onTap: () {
                      c.changeTab(TransactionTypeEnum.primary);
                    },
                    currentIndex: c.currentIndex,
                    // size: context,
                  ),
                ),
                Visibility(
                  visible: app.wUser.isPrimaryAccess,
                  child: const SizedBox(width: 10),
                ),
                Visibility(
                  visible: app.wUser.isSecondaryAccess,
                  child: TabButton(
                    title: "Lp Secondary",
                    type: TransactionTypeEnum.secondary,
                    onTap: () {
                      c.changeTab(TransactionTypeEnum.secondary);
                    },
                    currentIndex: c.currentIndex,
                  ),
                ),
                Visibility(
                  visible: app.wUser.isSecondaryAccess,
                  child: const SizedBox(width: 10),
                ),
                Visibility(
                  visible: app.wUser.isPreIpoAccess,
                  child: TabButton(
                    title: "Unlisted Shares Buy",
                    type: TransactionTypeEnum.preIpoBuy,
                    onTap: () {
                      c.changeTab(TransactionTypeEnum.preIpoBuy);
                    },
                    currentIndex: c.currentIndex,
                  ),
                ),
                Visibility(
                  visible: app.wUser.isPreIpoAccess,
                  child: const SizedBox(width: 10),
                ),
                Visibility(
                  visible: app.wUser.isPreIpoAccess,
                  child: TabButton(
                    title: "Unlisted Shares Sell",
                    type: TransactionTypeEnum.preIpoSell,
                    onTap: () {
                      c.changeTab(TransactionTypeEnum.preIpoSell);
                    },
                    currentIndex: c.currentIndex,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(child: MainView()),
          ],
        ),
      ),
    );
  }
}

class MainView extends StatelessWidget {
  final InvestorTransactionPageCtrl c = Get.find<InvestorTransactionPageCtrl>();

  MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        switch (c.currentIndex()) {
          case TransactionTypeEnum.primary:
            return DesktopPrimaryTransactionView();
          case TransactionTypeEnum.secondary:
            return DesktopSecondaryTransactionView();
          case TransactionTypeEnum.preIpoBuy:
            return DesktopPreIPOBuyTransactionView();
          case TransactionTypeEnum.preIpoSell:
            return DesktopPreIPOSellTransactionView();
        }
      },
    );
  }
}
