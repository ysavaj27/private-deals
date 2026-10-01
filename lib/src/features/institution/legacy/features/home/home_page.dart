import 'package:private_deals/src/features/institution/legacy/features/dashboard/dashboard_page.dart';
import 'package:private_deals/src/features/institution/legacy/features/sell_enquiries/sell_enquiries_page.dart';
import 'package:private_deals/src/features/institution/legacy/features/transaction/pre_ipo_transaction/pre_ipo_transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/auth/presentation/change_password/change_password_page.dart';
import 'package:private_deals/src/features/institution/legacy/features/auth/profile/profile_page.dart';
import 'package:private_deals/src/features/institution/companies/presentation/company_list/company_list_page.dart';
import 'package:private_deals/src/features/institution/legacy/features/company/update_share_price/update_share_price_page.dart';
import 'package:private_deals/src/features/institution/deals/presentation/deal_list/deal_list_page.dart';
import 'package:private_deals/src/features/institution/legacy/utils/widgets/empty_view.dart';

import 'package:private_deals/src/features/institution/legacy/features/home/desktop_home_page_view.dart';
import 'package:private_deals/src/features/institution/legacy/features/home/home_page_ctrl.dart';
import 'package:private_deals/src/features/institution/legacy/features/home/phone_home_page_view.dart';

class HomePage extends StatelessWidget {
  final Widget? child;
  final SellerHomePageCtrl c = Get.put(SellerHomePageCtrl());

  HomePage({super.key, this.child}) {
    c.setData();
  }

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneHomePageView(child: child);
    } else {
      return DesktopHomePageView(child: child);
    }
  }
}

class MainWidgets extends StatelessWidget {
  final SellerHomePageCtrl c = Get.find<SellerHomePageCtrl>();

  MainWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (c.currentTab()) {
        case WTabBarEnum.investors:
          return const SizedBox.shrink();
        case WTabBarEnum.dashboard:
          return const DashboardPage();
        case WTabBarEnum.preIPOList:
          return CompanyListPage(key: ValueKey(Get.currentRoute));
        case WTabBarEnum.secondaryList:
          return CompanyListPage(key: ValueKey(Get.currentRoute));
        case WTabBarEnum.transactions:
          return Container();
        case WTabBarEnum.sendDocuments:
          return Container();
        case WTabBarEnum.profile:
          return ProfilePageView();
        case WTabBarEnum.changePassword:
          return ChangePasswordPage();
        case WTabBarEnum.primaryList:
          return Container();
        case WTabBarEnum.sellEnquiries:
          return const SellEnquiriesPage();
        case WTabBarEnum.companyDeals:
          return DealListView(key: ValueKey(Get.currentRoute));
        case WTabBarEnum.secondaryDeals:
          return DealListView(key: ValueKey(Get.currentRoute));
        case WTabBarEnum.priceUpdate:
          return UpdateSharePricePage();
        case WTabBarEnum.preIPOTransactions:
          return PreIPOTransactionPage();
        case WTabBarEnum.secondaryTransactions:
          return const EmptyView(
            message: 'LP Secondary transactions will be available soon.',
            icon: Icons.receipt_long_outlined,
          );
      }
    });
  }
}
