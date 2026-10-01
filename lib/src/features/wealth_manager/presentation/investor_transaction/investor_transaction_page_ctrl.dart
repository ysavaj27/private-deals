import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/phone_investor_transaction_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/primary/phone_primary_transaction_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/phone_secondary_transaction_view.dart';

class InvestorTransactionPageCtrl extends GetxController
    with GetSingleTickerProviderStateMixin {
  Rx<TransactionTypeEnum> currentIndex = TransactionTypeEnum.primary.obs;

  TextEditingController controller = TextEditingController();
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    setData();
  }

  void setData() {
    if (app.wUser.isPrimaryAccess) {
      currentIndex(TransactionTypeEnum.primary);
    } else if (app.wUser.isSecondaryAccess) {
      currentIndex(TransactionTypeEnum.secondary);
    } else {
      currentIndex(TransactionTypeEnum.preIpoBuy);
    }
    tabController = TabController(length: tabBarLength, vsync: this);
  }

  int get tabBarLength {
    int i = 0;
    if (app.wUser.isPrimaryAccess) i += 1;
    if (app.wUser.isSecondaryAccess) i += 1;
    if (app.wUser.isPreIpoAccess) i += 1;
    return i;
  }

  List<Widget> tabs() {
    List<Widget> tabs = [];
    tabs.addIf(
      app.wUser.isPrimaryAccess,
      const Tab(text: 'Primary'),
    );
    tabs.addIf(
      app.wUser.isSecondaryAccess,
      const Tab(text: 'Secondary'),
    );
    tabs.addIf(
      app.wUser.isPreIpoAccess,
      const Tab(text: 'Unlisted Shares'),
    );
    return tabs;
  }

  List<Widget> tabViews() {
    List<Widget> tabs = [];
    tabs.addIf(
      app.wUser.isPrimaryAccess,
      PhonePrimaryTransactionView(),
    );
    tabs.addIf(
      app.wUser.isSecondaryAccess,
      PhoneSecondaryTransactionView(),
    );
    tabs.addIf(
      app.wUser.isPreIpoAccess,
      NestedTabBar(),
    );
    return tabs;
  }

  void changeTab(TransactionTypeEnum type) {
    currentIndex(type);
  }
}
