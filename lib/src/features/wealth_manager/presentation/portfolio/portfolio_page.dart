import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/desktop_portfolio_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/phone_portfolio_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page_ctrl.dart';

class PortfolioPage extends StatelessWidget {
  final PortfolioPageCtrl c;

  PortfolioPage({super.key}) : c = Get.find<PortfolioPageCtrl>();

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhonePortfolioView();
    } else {
      return DesktopPortfolioView();
    }
  }
}
