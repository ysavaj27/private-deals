import 'package:private_deals/src/features/auth/presentation/change_password/change_password_page.dart';
import 'package:private_deals/src/features/account/presentation/profile_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/desktop_home_page_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/investor_transaction_page.dart';
import 'package:private_deals/src/features/investors/presentation/legacy/investors_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/kyc_pending_investor/kyc_pending_investor_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/mis/mis_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/my_earning/my_earning_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/phone_home_page_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/send_document/send_document_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/upload_portfolio/upload_portfolio_page.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_landing_page/pre_ipo_landing_page.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_landing_page.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_landing_page.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiries_page.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/channel_partner/channel_partner_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page.dart';

class HomePage extends StatelessWidget {
  final Widget? child;
  final HomePageCtrl c = Get.put(HomePageCtrl(), permanent: true);

  HomePage({super.key, this.child}) {
    // Defer tab sync — constructor runs during route build, and setData()
    // updates Obx-watched state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<HomePageCtrl>()) c.setData();
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
  final HomePageCtrl c = Get.find<HomePageCtrl>();

  MainWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tab = c.currentTab();
      final Widget page = switch (tab) {
        WTabBarEnum.myInquiries => const EnquiriesPage(),
        WTabBarEnum.dashboard => DashboardPage(),
        WTabBarEnum.investorTransactions => InvestorTransactionPage(),
        WTabBarEnum.myEarnings => MyEarningPage(),
        WTabBarEnum.profile => ProfilePage(),
        WTabBarEnum.investors => InvestorsPage(),
        WTabBarEnum.pendingTasks => KycPendingInvestorPage(),
        WTabBarEnum.sendDocuments => SendDocumentPage(),
        WTabBarEnum.channelPartner => ChannelPartnerPage(),
        WTabBarEnum.notifications => const SizedBox.shrink(),
        WTabBarEnum.primary => PrimaryLandingPage(),
        WTabBarEnum.secondary => SecondaryLandingPage(),
        WTabBarEnum.preIPO => PreIPOLandingPage(),
        WTabBarEnum.logout => const SizedBox.shrink(),
        WTabBarEnum.changePassword => ChangePasswordPage(),
        WTabBarEnum.mis => MISPage(),
        WTabBarEnum.uploadPortfolio => UploadPortfolioPage(),
        WTabBarEnum.portfolio => PortfolioPage(),
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
