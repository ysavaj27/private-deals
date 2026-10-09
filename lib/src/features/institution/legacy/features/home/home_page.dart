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
import 'package:private_deals/src/shared/theme/app_motion.dart';

class HomePage extends StatelessWidget {
  final Widget? child;
  final SellerHomePageCtrl c = Get.put(SellerHomePageCtrl());

  HomePage({super.key, this.child}) {
    // Defer tab sync — constructor runs during route build, and setData()
    // updates Obx-watched state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<SellerHomePageCtrl>()) c.setData();
    });
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
      final tab = c.currentTab();
      final Widget page = switch (tab) {
        WTabBarEnum.investors => const SizedBox.shrink(),
        WTabBarEnum.dashboard => const DashboardPage(),
        WTabBarEnum.preIPOList =>
          CompanyListPage(key: ValueKey(Get.currentRoute)),
        WTabBarEnum.secondaryList =>
          CompanyListPage(key: ValueKey(Get.currentRoute)),
        WTabBarEnum.transactions => const SizedBox.shrink(),
        WTabBarEnum.sendDocuments => const SizedBox.shrink(),
        WTabBarEnum.profile => ProfilePageView(),
        WTabBarEnum.changePassword => ChangePasswordPage(),
        WTabBarEnum.primaryList => const SizedBox.shrink(),
        WTabBarEnum.sellEnquiries => const SellEnquiriesPage(),
        WTabBarEnum.companyDeals =>
          DealListView(key: ValueKey(Get.currentRoute)),
        WTabBarEnum.secondaryDeals =>
          DealListView(key: ValueKey(Get.currentRoute)),
        WTabBarEnum.priceUpdate => UpdateSharePricePage(),
        WTabBarEnum.manageDeals =>
          DealListView(key: ValueKey(Get.currentRoute)),
        WTabBarEnum.preIPOTransactions => PreIPOTransactionPage(),
        WTabBarEnum.secondaryTransactions => const EmptyView(
          message: 'LP Secondary transactions will be available soon.',
          icon: Icons.receipt_long_outlined,
        ),
      };
      return AnimatedSwitcher(
        duration: AppMotion.duration(context, AppMotion.normal),
        switchInCurve: AppMotion.easeOut,
        switchOutCurve: AppMotion.easeInOut,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            fit: StackFit.expand,
            alignment: Alignment.topCenter,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: KeyedSubtree(key: ValueKey(tab), child: page),
      );
    });
  }
}
