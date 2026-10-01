import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_buy_transaction/phone_pre_ipo_buy_transaction_view.dart'
    show PhonePreIPOBuyTransactionView;
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_sell_transaction/phone_pre_ipo_sell_transaction_view.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/investor_transaction_page_ctrl.dart';

class PhoneInvestorTransactionView extends StatelessWidget {
  final InvestorTransactionPageCtrl c = Get.put(InvestorTransactionPageCtrl());

  PhoneInvestorTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: app.wUser.isPreIPOOnly
            ? NestedTabBar()
            : Column(
                children: [
                  TabBar(
                    controller: c.tabController,
                    splashBorderRadius: BorderRadius.circular(50),
                    // onTap: (v) => c.changeTab(EquityTypeEnum.values[v]),
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

class NestedTabBar extends StatefulWidget {
  const NestedTabBar({super.key});

  @override
  State<NestedTabBar> createState() => _NestedTabBarState();
}

class _NestedTabBarState extends State<NestedTabBar>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Divider(),
        SizedBox(height: 4),
        TabBar.secondary(
          controller: _tabController,
          tabs: const <Widget>[Tab(text: 'Buy'), Tab(text: 'Sell')],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              PhonePreIPOBuyTransactionView(),
              PhonePreIPOSellTransactionView(),
            ],
          ),
        ),
      ],
    );
  }
}
