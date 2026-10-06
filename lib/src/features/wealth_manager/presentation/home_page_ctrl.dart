import 'dart:async';

import 'package:private_deals/src/app/routing/session_navigation.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page_ctrl.dart';

class HomePageCtrl extends GetxController {
  RxBool isExpand = true.obs;
  RxBool isLoading = false.obs;
  Rx<WTabBarEnum> currentTab = WTabBarEnum.dashboard.obs;
  RxBool firstTime = false.obs;

  // RxString title = ''.obs;

  Timer? debounce;
  DateTime? lastBackPressTime;
  int backPressCount = 0;
  final GlobalKey<CircularMenuState> circularMenuKey =
      GlobalKey<CircularMenuState>();

  void closeMenu() {
    circularMenuKey.currentState?.reverseAnimation();
  }

  // void onTap(WTabBarEnum index) {
  //   currentTab(index);
  //   currentTab.refresh();
  //   if (currentTab() == WTabBarEnum.primary) {
  //     title("Private Equity");
  //   } else if (currentTab() == WTabBarEnum.secondary) {
  //     title("LP Secondary");
  //   } else if (currentTab() == WTabBarEnum.preIPO) {
  //     title("Unlisted Shares");
  //   }
  // }

  @override
  void onReady() {
    init.forceUpdate();
    super.onReady();
  }

  void setData() {
    final tabFromUrl = WTabBarRouteX.fromSlug(Get.parameters['tab']);
    final routeArg = Get.arguments;
    if (routeArg != null && routeArg is WTabBarEnum) {
      onTap(routeArg);
    } else if (currentTab() != tabFromUrl) {
      currentTab(tabFromUrl);
    }
  }

  void onTap(WTabBarEnum tab) {
    if (SessionNavigation.check('/wealth-manager/${tab.slug}') !=
        AccessResult.allowed) {
      Get.offAllNamed(SessionNavigation.home);
      return;
    }
    final target = '/wealth-manager/${tab.slug}';
    // Keep view state in sync even when the URL already matches (stale tab).
    if (Get.currentRoute == target) {
      if (currentTab() != tab) currentTab(tab);
      return;
    }
    // #region agent log
    agentLog('A', 'home_page_ctrl.dart:onTap', 'tab switch before offNamed', {
      'from': currentTab().name,
      'to': tab.name,
      'route': Get.currentRoute,
      'homeRegistered': Get.isRegistered<HomePageCtrl>(),
      'portfolioRegistered': Get.isRegistered<PortfolioPageCtrl>(),
      'homeHash': identityHashCode(this),
    });
    // #endregion
    currentTab(tab);
    // _updateTitle(tab);
    // if (kIsWeb) {
    Get.offNamed(
      target,
      preventDuplicates: true,
      arguments: null,
    );
    logger.d(Get.currentRoute);
    // }
    // Replaces the URL without pushing a new page onto the stack
  }

  // void _updateTitle(WTabBarEnum tab) {
  //   switch (tab) {
  //     case WTabBarEnum.primary:
  //       title("Private Equity");
  //       break;
  //     case WTabBarEnum.secondary:
  //       title("LP Secondary");
  //       break;
  //     case WTabBarEnum.preIPO:
  //       title("Unlisted Shares");
  //       break;
  //     default:
  //       break;
  //   }
  // }

  @override
  void onInit() {
    setData();
    // #region agent log
    agentLog('A', 'home_page_ctrl.dart:onInit', 'before lazyPut PortfolioPageCtrl', {
      'portfolioRegistered': Get.isRegistered<PortfolioPageCtrl>(),
      'route': Get.currentRoute,
      'tab': currentTab().name,
      'homeHash': identityHashCode(this),
    });
    // #endregion
    // fenix: recreate after SmartManagement deletes the instance on route churn.
    if (!Get.isRegistered<PortfolioPageCtrl>()) {
      Get.lazyPut(() => PortfolioPageCtrl(), fenix: true);
    }
    // #region agent log
    agentLog('A', 'home_page_ctrl.dart:onInit', 'after lazyPut PortfolioPageCtrl', {
      'portfolioRegistered': Get.isRegistered<PortfolioPageCtrl>(),
      'homeHash': identityHashCode(this),
    });
    // #endregion

    super.onInit();
  }

  @override
  void onClose() {
    // #region agent log
    agentLog('B', 'home_page_ctrl.dart:onClose', 'HomePageCtrl disposing', {
      'portfolioRegistered': Get.isRegistered<PortfolioPageCtrl>(),
      'route': Get.currentRoute,
      'tab': currentTab().name,
      'homeHash': identityHashCode(this),
      'stillRegistered': Get.isRegistered<HomePageCtrl>(),
    });
    // #endregion
    debounce?.cancel();
    super.onClose();
  }

  String get appBarName {
    switch (currentTab()) {
      case WTabBarEnum.myInquiries:
        return 'My Inquiries';
      case WTabBarEnum.dashboard:
        return 'Dashboard';
      case WTabBarEnum.investorTransactions:
        return 'Investor Transactions';
      case WTabBarEnum.myEarnings:
        return 'My Earnings';
      case WTabBarEnum.profile:
        return 'Profile';
      case WTabBarEnum.investors:
        return 'Investors';
      case WTabBarEnum.pendingTasks:
        return 'Pending Tasks';
      case WTabBarEnum.sendDocuments:
        return 'Send Documents';
      case WTabBarEnum.channelPartner:
        return 'Channel Partner';
      case WTabBarEnum.notifications:
        return 'Notifications';
      case WTabBarEnum.primary:
        return 'Private Equity';
      case WTabBarEnum.secondary:
        return 'LP Secondary';
      case WTabBarEnum.preIPO:
        return 'Unlisted Shares';
      case WTabBarEnum.logout:
        return "Home";
      case WTabBarEnum.mis:
        return 'MIS';
      case WTabBarEnum.uploadPortfolio:
        return 'Upload Portfolio';
      case WTabBarEnum.changePassword:
        return 'Change Password';
      case WTabBarEnum.portfolio:
        return 'Portfolio';
    }
  }
}
