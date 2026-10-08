import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_buy_transaction/phone_pre_ipo_buy_transaction_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/primary/phone_primary_transaction_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/phone_secondary_transaction_view.dart';

class InvestorTransactionPageCtrl extends GetxController
    with GetSingleTickerProviderStateMixin {
  Rx<TransactionTypeEnum> currentIndex = TransactionTypeEnum.preIpoBuy.obs;

  TextEditingController controller = TextEditingController();
  TabController? _tabController;
  TabController get tabController => _tabController!;

  @override
  void onInit() {
    super.onInit();
    setData();
  }

  void setData() {
    if (app.wUser.isPreIpoAccess) {
      currentIndex(TransactionTypeEnum.preIpoBuy);
    } else if (app.wUser.isSecondaryAccess) {
      currentIndex(TransactionTypeEnum.secondary);
    } else {
      currentIndex(TransactionTypeEnum.primary);
    }
    _tabController?.dispose();
    _tabController = TabController(length: tabBarLength, vsync: this);
    _tabController!.addListener(() {
      if (availableTypes.isNotEmpty) {
        currentIndex(availableTypes[_tabController!.index]);
      }
    });
    applyRouteSelection();
  }

  List<TransactionTypeEnum> get availableTypes => [
    if (app.wUser.isPreIpoAccess) TransactionTypeEnum.preIpoBuy,
    if (app.wUser.isSecondaryAccess) TransactionTypeEnum.secondary,
    if (app.wUser.isPrimaryAccess) TransactionTypeEnum.primary,
  ];

  int get tabBarLength => availableTypes.length;

  void applyRouteSelection() {
    if (Get.parameters['asset'] == 'unlisted') {
      changeTab(TransactionTypeEnum.preIpoBuy);
    }
  }

  List<Widget> tabs() {
    List<Widget> tabs = [];
    tabs.addIf(app.wUser.isPreIpoAccess, const Tab(text: 'Unlisted'));
    tabs.addIf(app.wUser.isSecondaryAccess, const Tab(text: 'Secondary'));
    tabs.addIf(app.wUser.isPrimaryAccess, const Tab(text: 'Private Equity'));
    return tabs;
  }

  List<Widget> tabViews() {
    List<Widget> tabs = [];
    tabs.addIf(app.wUser.isPreIpoAccess, PhonePreIPOBuyTransactionView());
    tabs.addIf(app.wUser.isSecondaryAccess, PhoneSecondaryTransactionView());
    tabs.addIf(app.wUser.isPrimaryAccess, PhonePrimaryTransactionView());
    return tabs;
  }

  void changeTab(TransactionTypeEnum type) {
    final index = availableTypes.indexOf(type);
    if (index < 0) return;
    currentIndex(type);
    if (_tabController != null && _tabController!.index != index) {
      _tabController!.index = index;
    }
  }

  @override
  void onClose() {
    controller.dispose();
    _tabController?.dispose();
    super.onClose();
  }
}
