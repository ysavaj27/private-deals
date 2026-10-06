import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/phone_portfolio_view.dart';

class PortfolioPageCtrl extends GetxController
    with GetSingleTickerProviderStateMixin {
  RxBool isLoading = false.obs;
  RxBool isSearching = false.obs;
  RxList<StartupPortfolioListModel> equityList =
      <StartupPortfolioListModel>[].obs;
  RxList<StartupPortfolioListModel> ccpsList =
      <StartupPortfolioListModel>[].obs;
  RxList<StartupPortfolioListModel> ccdList = <StartupPortfolioListModel>[].obs;
  RxList<PreIPOPortfolioListModel> preIpoList =
      <PreIPOPortfolioListModel>[].obs;
  RxList<StartupPortfolioListModel> searchList =
      <StartupPortfolioListModel>[].obs;
  RxList<PreIPOPortfolioListModel> preIpoSearchList =
      <PreIPOPortfolioListModel>[].obs;
  Rx<EquityTypeEnum> currentIndex = EquityTypeEnum.equity.obs;
  TextEditingController controller = TextEditingController();

  RxList<int> selectedInvestor = <int>[].obs;
  RxList<InvestorModel> investorList = <InvestorModel>[].obs;
  RxList<int> selectedStartup = <int>[].obs;
  RxList<StartupLiteModel> startupList = <StartupLiteModel>[].obs;

  late TabController tabController;

  RxList<StartupPortfolioListModel> get startUpList {
    if (isSearching.isTrue) {
      return searchList;
    }
    switch (currentIndex()) {
      case EquityTypeEnum.equity:
        return equityList;
      case EquityTypeEnum.ccps:
        return ccpsList;
      case EquityTypeEnum.ccd:
        return ccdList;
      case EquityTypeEnum.preIpo:
        return <StartupPortfolioListModel>[].obs;
    }
  }

  @override
  void onInit() {
    // #region agent log
    agentLog('C', 'portfolio_page_ctrl.dart:onInit', 'PortfolioPageCtrl created', {
      'route': Get.currentRoute,
      'homeRegistered': Get.isRegistered<HomePageCtrl>(),
    });
    // #endregion
    setData();
    getData();
    super.onInit();
  }

  @override
  void onClose() {
    // #region agent log
    agentLog('B', 'portfolio_page_ctrl.dart:onClose', 'PortfolioPageCtrl disposing', {
      'route': Get.currentRoute,
      'isLoading': isLoading.value,
    });
    // #endregion
    super.onClose();
  }

  void setData() {
    var data = Get.arguments;
    if (data is int) {
      selectedInvestor.value = [data];
    }
  }

  List<EquityTypeEnum> get tabTypes => [
    if (app.wUser.isPreIpoAccess) EquityTypeEnum.preIpo,
    if (app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess) ...[
      EquityTypeEnum.equity,
      EquityTypeEnum.ccps,
      EquityTypeEnum.ccd,
    ],
  ];

  int get tabBarLength {
    int i = 0;
    if (app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess) i += 3;
    // if (app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess) i += 1;
    // if (app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess) i += 1;
    if (app.wUser.isPreIpoAccess) i += 1;
    return i;
  }

  List<Widget> get tabs {
    List<Widget> tab = [];
    tab.addIf(app.wUser.isPreIpoAccess, const Tab(text: 'Unlisted'));
    tab.addIf(
      app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess,
      const Tab(text: 'Equity'),
    );
    tab.addIf(
      app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess,
      const Tab(text: 'CCPS'),
    );
    tab.addIf(
      app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess,
      const Tab(text: 'CCD'),
    );
    return tab;
  }

  List<Widget> get tabViews {
    List<Widget> tab = [];
    tab.addIf(app.wUser.isPreIpoAccess, PreIpoListWidget());
    tab.addIf(
      app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess,
      ListWidget(equityList),
    );
    tab.addIf(
      app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess,
      ListWidget(ccpsList),
    );
    tab.addIf(
      app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess,
      ListWidget(ccdList),
    );
    return tab;
  }

  List<StartupPortfolioListModel> get currentList {
    switch (currentIndex()) {
      case EquityTypeEnum.equity:
        return equityList;
      case EquityTypeEnum.ccps:
        return ccpsList;
      case EquityTypeEnum.ccd:
        return ccdList;
      case EquityTypeEnum.preIpo:
        return [];
    }
  }

  void changeTab(EquityTypeEnum type) {
    currentIndex(type);
    getStartupPortfolio();
    isSearching(false);
    searchList.clear();
    controller.clear();
  }

  void search(String query) {
    if (currentIndex() == EquityTypeEnum.preIpo) {
      if (query.isEmpty) {
        preIpoSearchList.value = preIpoList;
        isSearching(false);
      } else {
        preIpoSearchList.value = preIpoList.where((item) {
          final searchQuery = query.toLowerCase();

          return item.investor.name.toLowerCase().contains(searchQuery) ||
              item.holdings.any(
                (holding) => holding.company.brandName.toLowerCase().contains(
                  searchQuery,
                ),
              );
        }).toList();
        // logger.d("Value :${searchList.length}");
        isSearching(true);
      }
    } else {
      if (query.isEmpty) {
        searchList.value = currentList;
        isSearching(false);
      } else {
        searchList.value = currentList.where((item) {
          final searchQuery = query.toLowerCase();

          return item.investor.name.toLowerCase().contains(searchQuery) ||
              item.holdings.any(
                (holding) => holding.startup.brandName.toLowerCase().contains(
                  searchQuery,
                ),
              );
        }).toList();
        // logger.d("Value :${searchList.length}");
        isSearching(true);
      }
    }
  }

  Future<void> getPreIpoPortfolio() async {
    var res = await PortfolioApi.wPreIpoPortfolioAPi(selectedInvestor);
    if (res.isSuccess) {
      preIpoList(res.r);
    }
  }

  Future<void> getInvestorList() async {
    var res = await WInvestorsApi.investorsList(
      isKyc: FilterTypeEnum.All.name,
      isActive: FilterTypeEnum.All.name,
      isAif: FilterTypeEnum.All.name,
      relationManagerList: [],
    );
    if (res.isSuccess && res.r != null) {
      investorList(res.r);
    } else {
      toast(res.m);
    }
  }

  Future<void> getStartupList() async {
    var res = await LandingPageApi.wLiteStartupList();
    if (res.isSuccess && res.r != null) {
      startupList(res.r);
    } else {
      toast(res.m);
    }
  }

  Future<void> getStartupPortfolio() async {
    if (currentIndex() == EquityTypeEnum.preIpo) {
      await getPreIpoPortfolio();
      return;
    }
    var res = await PortfolioApi.wPortfolioAPi(
      currentIndex().name,
      selectedInvestor,
      selectedStartup,
    );
    if (res.isSuccess) {
      switch (currentIndex()) {
        case EquityTypeEnum.equity:
          equityList(res.r);
          break;
        case EquityTypeEnum.ccps:
          ccpsList(res.r);
          break;
        case EquityTypeEnum.ccd:
          ccdList(res.r);
          break;
        case EquityTypeEnum.preIpo:
          break;
      }
    } else {
      toast(res.m);
    }
  }

  Future<void> getData() async {
    isLoading(true);
    tabController = TabController(length: tabBarLength, vsync: this);
    if (app.wUser.isPreIpoAccess) {
      currentIndex(EquityTypeEnum.preIpo);
    } else {
      currentIndex(EquityTypeEnum.equity);
    }
    tabController.addListener(() {
      if (tabTypes.isNotEmpty &&
          currentIndex() != tabTypes[tabController.index]) {
        changeTab(tabTypes[tabController.index]);
      }
    });
    logger.d(currentIndex.value);
    await Future.wait([
      getStartupPortfolio(),
      getInvestorList(),
      getStartupList(),
    ]);
    isLoading(false);
  }
}
