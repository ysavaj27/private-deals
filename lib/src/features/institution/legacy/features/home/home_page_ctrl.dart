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

  Timer? debounce;
  DateTime? lastBackPressTime;
  int backPressCount = 0;

  void closeMenu() {}

  final unlistedExpanded = false.obs;
  final lpSecondaryExpanded = false.obs;
  final dealOfTheDayExpanded = false.obs;

  bool get isDealOfTheDayTab =>
      currentTab.value == WTabBarEnum.companyDeals ||
      currentTab.value == WTabBarEnum.secondaryDeals;

  bool get isUnlistedSection =>
      currentTab.value == WTabBarEnum.preIPOList ||
      currentTab.value == WTabBarEnum.priceUpdate;

  bool get isLpSecondarySection =>
      currentTab.value == WTabBarEnum.secondaryList ||
      currentTab.value == WTabBarEnum.manageDeals;

  bool get isCompanyTab => isUnlistedSection || isLpSecondarySection;

  // Adjust these property names to match your UserModel.
  bool get canAccessPreIPO => app.wUser.isPreIpoAccess == true;

  bool get canAccessSecondary => app.wUser.isSecondaryAccess == true;

  bool get canAccessTransactions => canAccessPreIPO || canAccessSecondary;

  bool get isTransactionTab =>
      currentTab.value == WTabBarEnum.preIPOTransactions ||
      currentTab.value == WTabBarEnum.secondaryTransactions;

  WTabBarEnum get preferredCompanyTab => WTabBarEnum.preIPOList;

  WTabBarEnum get preferredTransactionTab => WTabBarEnum.preIPOTransactions;

  int get phoneNavIndex {
    switch (currentTab.value) {
      case WTabBarEnum.dashboard:
        return 0;
      case WTabBarEnum.preIPOTransactions:
      case WTabBarEnum.secondaryTransactions:
        return 1;
      case WTabBarEnum.preIPOList:
      case WTabBarEnum.secondaryList:
      case WTabBarEnum.manageDeals:
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

  void setData() {
    final path = Uri.parse(Get.currentRoute).path;
    final tabFromUrl = WTabBarEnum.values.firstWhere(
      (tab) => path == tab.sellerPath,
      orElse: () => WTabBarEnum.dashboard,
    );
    final routeArg = Get.arguments;
    if (routeArg != null && routeArg is WTabBarEnum) {
      onTap(routeArg);
    } else {
      if (currentTab() != tabFromUrl) currentTab(tabFromUrl);
      _syncExpandedMenus(tabFromUrl);
    }
  }

  void _syncExpandedMenus(WTabBarEnum tab) {
    if (tab == WTabBarEnum.preIPOList || tab == WTabBarEnum.priceUpdate) {
      unlistedExpanded.value = true;
    }
    if (tab == WTabBarEnum.secondaryList || tab == WTabBarEnum.manageDeals) {
      lpSecondaryExpanded.value = true;
    }
    if (tab == WTabBarEnum.companyDeals || tab == WTabBarEnum.secondaryDeals) {
      dealOfTheDayExpanded.value = true;
    }
  }

  void onTap(WTabBarEnum tab) {
    if (!canAccessTab(tab)) return;
    if (Uri.parse(Get.currentRoute).path == tab.sellerPath) return;

    _syncExpandedMenus(tab);

    Get.offNamed(tab.sellerPath, preventDuplicates: true, arguments: null);
  }

  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setData();
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
        return 'Investors';
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
        return 'Manage Company';
      case WTabBarEnum.preIPOList:
        return 'Manage Company';
      case WTabBarEnum.primaryList:
        return 'Private Equity';
      case WTabBarEnum.sellEnquiries:
        return 'Inquiry';
      case WTabBarEnum.companyDeals:
        return 'Deal of the Day';
      case WTabBarEnum.secondaryDeals:
        return 'Deal of the Day';
      case WTabBarEnum.priceUpdate:
        return 'Update Share Price';
      case WTabBarEnum.manageDeals:
        return 'Manage Deals';
      case WTabBarEnum.preIPOTransactions:
        return 'Transactions';
      case WTabBarEnum.secondaryTransactions:
        return 'Transactions';
    }
  }
}
