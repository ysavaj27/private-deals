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
    final tabFromUrl = Get.currentRoute.startsWith('/investors')
        ? WTabBarEnum.investors
        : WTabBarRouteX.fromSlug(Get.parameters['tab']);
    final routeArg = Get.arguments;
    if (routeArg != null && routeArg is WTabBarEnum) {
      onTap(routeArg);
    } else {
      currentTab(tabFromUrl);
      // _updateTitle(tabFromUrl);
    }
  }

  void onTap(WTabBarEnum tab) {
    if (SessionNavigation.check('/wealth-manager/${tab.slug}') !=
        AccessResult.allowed) {
      Get.toNamed('/access-denied');
      return;
    }
    if (Get.currentRoute == '/wealth-manager/${tab.slug}')
      return; // avoid redundant navigation
    currentTab(tab);
    // _updateTitle(tab);
    // if (kIsWeb) {
    Get.offNamed(
      '/wealth-manager/${tab.slug}',
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
    Get.lazyPut(() => PortfolioPageCtrl());

    super.onInit();
  }

  @override
  void onClose() {
    debounce?.cancel();
    super.onClose();
  }

  String get appBarName {
    switch (currentTab()) {
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
