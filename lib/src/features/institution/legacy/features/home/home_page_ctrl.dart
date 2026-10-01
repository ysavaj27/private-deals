import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/legacy/router/routes/routes.dart';
import 'package:private_deals/src/core/session/auth_session.dart';

class SellerHomePageCtrl extends GetxController {
  RxBool isExpand = true.obs;
  RxBool isLoading = false.obs;
  Rx<WTabBarEnum> currentTab = WTabBarEnum.dashboard.obs;
  RxBool firstTime = false.obs;

  // RxString title = ''.obs;

  Timer? debounce;
  DateTime? lastBackPressTime;
  int backPressCount = 0;

  void closeMenu() {}

  final transactionsExpanded = false.obs;
  final hotDealsExpanded = false.obs;

  bool get isHotDealTab =>
      currentTab.value == WTabBarEnum.companyDeals ||
      currentTab.value == WTabBarEnum.secondaryDeals;

  bool get isCompanyTab =>
      currentTab.value == WTabBarEnum.preIPOList ||
      currentTab.value == WTabBarEnum.secondaryList;

  // Adjust these property names to match your UserModel.
  bool get canAccessPreIPO => app.wUser.isPreIpoAccess == true;

  bool get canAccessSecondary => app.wUser.isSecondaryAccess == true;

  bool get canAccessTransactions => canAccessPreIPO || canAccessSecondary;

  bool get isTransactionTab =>
      currentTab.value == WTabBarEnum.preIPOTransactions ||
      currentTab.value == WTabBarEnum.secondaryTransactions;

  WTabBarEnum get preferredCompanyTab => WTabBarEnum.preIPOList;

  WTabBarEnum get preferredTransactionTab {
    if (canAccessPreIPO) return WTabBarEnum.preIPOTransactions;
    if (canAccessSecondary) return WTabBarEnum.secondaryTransactions;
    return WTabBarEnum.preIPOTransactions;
  }

  int get phoneNavIndex {
    switch (currentTab.value) {
      case WTabBarEnum.dashboard:
        return 0;
      case WTabBarEnum.preIPOTransactions:
      case WTabBarEnum.secondaryTransactions:
        return 1;
      case WTabBarEnum.preIPOList:
      case WTabBarEnum.secondaryList:
        return 2;
      case WTabBarEnum.priceUpdate:
        return 3;
      case WTabBarEnum.profile:
      case WTabBarEnum.changePassword:
        return 4;
      default:
        return 0;
    }
  }

  void onPhoneNavTap(int index) {
    switch (index) {
      case 0:
        onTap(WTabBarEnum.dashboard);
      case 1:
        if (!isTransactionTab) onTap(preferredTransactionTab);
      case 2:
        if (!isCompanyTab) onTap(preferredCompanyTab);
      case 3:
        onTap(WTabBarEnum.priceUpdate);
      case 4:
        onTap(WTabBarEnum.profile);
    }
  }

  bool canAccessTab(WTabBarEnum tab) => true;

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
    // init.forceUpdate();
    super.onReady();
  }

  void setData() {
    transactionsExpanded.value = isTransactionTab;
    final path = Uri.parse(Get.currentRoute).path;
    final tabFromUrl = WTabBarEnum.values.firstWhere(
      (tab) => path == tab.sellerPath,
      orElse: () => path.startsWith('/investors')
          ? WTabBarEnum.investors
          : WTabBarEnum.dashboard,
    );
    final routeArg = Get.arguments;
    if (routeArg != null && routeArg is WTabBarEnum) {
      onTap(routeArg);
    } else {
      currentTab(tabFromUrl);
      // _updateTitle(tabFromUrl);
    }
  }

  void onTap(WTabBarEnum tab) {
    if (!canAccessTab(tab)) return;
    if (Uri.parse(Get.currentRoute).path == tab.sellerPath) return;

    if (tab == WTabBarEnum.preIPOTransactions ||
        tab == WTabBarEnum.secondaryTransactions) {
      transactionsExpanded.value = true;
    }

    Get.offNamed(tab.sellerPath, preventDuplicates: true, arguments: null);
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setData();
      // Get.lazyPut(() => PortfolioPageCtrl());
    });

    super.onInit();
  }

  @override
  void onClose() {
    debounce?.cancel();
    super.onClose();
  }

  String get appBarName {
    switch (currentTab()) {
      case WTabBarEnum.investors:
        return 'Investors & CML';
      case WTabBarEnum.dashboard:
        return 'Dashboard';
      case WTabBarEnum.transactions:
        return 'Transactions';
      case WTabBarEnum.profile:
        return 'Profile';
      case WTabBarEnum.changePassword:
        return 'Change Password';
      case WTabBarEnum.sendDocuments:
        return 'Send Documents';
      case WTabBarEnum.secondaryList:
        return 'LP Secondary Companies';
      case WTabBarEnum.preIPOList:
        return 'Unlisted Companies';
      case WTabBarEnum.primaryList:
        return 'Private Equity';
      case WTabBarEnum.sellEnquiries:
        return 'Sell Enquiries';
      case WTabBarEnum.companyDeals:
        return 'Unlisted Hot Deals';
      case WTabBarEnum.secondaryDeals:
        return 'LP Secondary Hot Deals';
      case WTabBarEnum.priceUpdate:
        return 'Update Unlisted Share Price';
      case WTabBarEnum.preIPOTransactions:
        return 'Unlisted Transactions';
      case WTabBarEnum.secondaryTransactions:
        return 'LP Secondary Transactions';
    }
  }
}
