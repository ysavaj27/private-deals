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
      switch (c.currentTab()) {
        case WTabBarEnum.myInquiries:
          return const EnquiriesPage();
        case WTabBarEnum.dashboard:
          return DashboardPage();
        // return DashboardPage();
        case WTabBarEnum.investorTransactions:
          return InvestorTransactionPage();
        case WTabBarEnum.myEarnings:
          return MyEarningPage();
        case WTabBarEnum.profile:
          return ProfilePage();
        case WTabBarEnum.investors:
          return InvestorsPage();
        case WTabBarEnum.pendingTasks:
          return KycPendingInvestorPage();
        case WTabBarEnum.sendDocuments:
          return SendDocumentPage();
        case WTabBarEnum.channelPartner:
          return ChannelPartnerPage();
        case WTabBarEnum.notifications:
          return Container();
        case WTabBarEnum.primary:
          return PrimaryLandingPage();
        case WTabBarEnum.secondary:
          return SecondaryLandingPage();
        case WTabBarEnum.preIPO:
          return PreIPOLandingPage();
        case WTabBarEnum.logout:
          return Container();
        case WTabBarEnum.changePassword:
          return ChangePasswordPage();
        case WTabBarEnum.mis:
          return MISPage();
        case WTabBarEnum.uploadPortfolio:
          return UploadPortfolioPage();
        case WTabBarEnum.portfolio:
          return PortfolioPage();
        // case WTabBarEnum.pendingTasks:
        //   return PendingTaskPage();
      }
    });
  }
}
