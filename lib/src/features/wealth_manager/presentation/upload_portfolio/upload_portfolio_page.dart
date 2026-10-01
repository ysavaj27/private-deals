import 'package:private_deals/src/features/wealth_manager/presentation/upload_portfolio/desktop_upload_portfolio_view.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/upload_portfolio/phone_upload_portfolio_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/upload_portfolio/upload_portfolio_ctrl.dart';

class UploadPortfolioPage extends StatelessWidget {
  final UploadPortfolioCtrl c = Get.put(UploadPortfolioCtrl());

  UploadPortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneUploadPortfolioView();
    } else {
      return DesktopUploadPortfolioView();
    }
  }
}
