import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/desktop_portfolio_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/phone_portfolio_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page_ctrl.dart';

class PortfolioPage extends StatelessWidget {
  final PortfolioPageCtrl c;

  PortfolioPage({super.key}) : c = _resolveCtrl();

  static PortfolioPageCtrl _resolveCtrl() {
    // #region agent log
    agentLog('A', 'portfolio_page.dart:resolve', 'PortfolioPage finding ctrl', {
      'portfolioRegistered': Get.isRegistered<PortfolioPageCtrl>(),
      'homeRegistered': Get.isRegistered<HomePageCtrl>(),
      'route': Get.currentRoute,
    });
    // #endregion
    try {
      return Get.find<PortfolioPageCtrl>();
    } catch (e) {
      // #region agent log
      agentLog('A', 'portfolio_page.dart:resolve', 'PortfolioPageCtrl find FAILED', {
        'error': e.toString(),
        'portfolioRegistered': Get.isRegistered<PortfolioPageCtrl>(),
        'homeRegistered': Get.isRegistered<HomePageCtrl>(),
        'route': Get.currentRoute,
      });
      // #endregion
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhonePortfolioView();
    } else {
      return DesktopPortfolioView();
    }
  }
}
